require "rubygems"
require "time"
require "date"
require "active_support/all"

module VRoy; module Cron

=begin
  *    *    *    *    *   *    command to be executed
  -    -    -    -    -   -
  |    |    |    |    |   |
  |    |    |    |    |   +- Year (optional)
  |    |    |    |    +----- day of week (0 - 6) (Sunday=0)
  |    |    |    +---------- month (1 - 12)
  |    |    +--------------- day of month (1 - 31)
  |    +-------------------- hour (0 - 23)
  +------------------------- min (0 - 59)
=end

  CronFields = [
            [ :minute, {
                :value => @minute,
                :invalid_message => "Invalid value for minute.",
                :range => (0..59),
                :time_value => lambda{|t| t.min }
              }],

            [ :hour, {
                :value => @hour,
                :invalid_message => "Invalid value for hour.",
                :range => (1..23),
                :time_value => lambda{|t| t.hour },
                :human_string => "of"
              }],

            [ :dayofmonth, {
                :value => @dayofmonth,
                :invalid_message => "Invalid value for day of month.",
                :range => (1..31),
                :time_value => lambda{|t| t.day },
                :human_string => "on the",
                :human_value => lambda{|v|
                  v.to_i.ordinalize
                }
              }],

            [ :month, {
                :value => @month,
                :invalid_message => "Invalid value for month.",
                :range => (1..12),
                :time_value => lambda{|t| t.month },
                :human_value => lambda{|v| Date::MONTHNAMES[ v.to_i ] },
                :human_string => "of",

              }],

            [ :dayofweek, {
                :value => @dayofweek,
                :invalid_message => "Invalid value for day of week.",
                :range => (0..6),
                :time_value => lambda{|t| t.wday },
                :human_value => lambda{|v| Date::DAYNAMES[v.to_i] },
                :human_string => "on"
              }],

           ]
  
  class InvalidFormat < Exception; end

  Patterns = {
    :all => /^\*$/,
    :increments => /\*\/(\d+)$/,
    :integer => /^(\d+)$/,
    :list => /(\d+),?/,
  }

  class Cron
    
    attr_reader :min, :hour, :dayofmonth, :month, :dayofweek, :year, :cmd
    attr_reader :values
    def initialize(cron_string)
      @original_cron_string = cron_string
      
      values = cron_string.split(" ")
      
      raise "Please provide all required crontab fields." if values.size < 6
      
      @values = {}
      @values[:minute] = values.shift
      @values[:hour] = values.shift
      @values[:dayofmonth] = values.shift
      @values[:month] = values.shift
      @values[:dayofweek] = values.shift
      
      @cmd = values.join(" ")
      @values[:cmd] = @cmd

      #TODO: Add support for optional year

      if !valid?
        raise InvalidFormat, { :cron => self, :errors => errors }
      end
    end
    
    def valid?
      return errors.empty?
    end

    def errors
      if @errors.nil?
        @errors = []
        
        CronFields.each do |type, info|
          @errors << [ type, info[:invalid_message] ] if !range_match?( @values[type], info[:range] )
          @errors << [ type, info[:invalid_message] ] if !valid_format?( @values[type] )
        end
        @errors.uniq!
      end

      return @errors
    end
    
    def match?(time)
      CronFields.each do |type, info|
        return false if !value_match?( @values[type], info[:time_value].call(time) )
      end
      return true
    end
    
    # @start_at - Time object that specifies where to start to get the next runs
    # @limit - How many results do you need
    def next_runs(start_at, limit=20)
      time = Time.parse( start_at.strftime("%Y-%m-%d %H:%M:00") )

      matches = []
      while matches.size < limit
        if self.match?(time)
          matches << time
        end

        time += 60
      end

      return matches
    end

    def to_s
      return @original_cron_string
    end

    def to_human_format
      strings = []
      
      CronFields.reverse.each do |field, info|

        if @values[field].match( Patterns[:all] )
          strings << [field, "every #{field}s"] if field == :minute

        elsif @values[field].match( Patterns[:increments] )
          if field == :dayofweek
            days = []

            info[:range].each do |i|
              if i % $1.to_i == 0
                days << info[:human_value].call(i)
              end
            end
            last = days.pop
            if days.empty?
              strings << [field, "#{last}"]
            else
              strings << [field, "#{days.join(', ')} and #{last}"]
            end

          else
            if $1.to_i == 1
              strings << [field, "every #{field}s"]
            else
              strings << [field, "every #{$1} #{field}s"]
            end
          end

        elsif @values[field].match( Patterns[:integer] )
          val = (info[:human_value]) ? info[:human_value].call($1) : $1
          strings << [field, "#{info[:human_string]||field} #{val}"]

        elsif @values[field].match( Patterns[:list] )
          # When the crontab field is a list, loop through every value of that
          # list and run it through the human_value call.
          list = @values[field].scan( Patterns[:list] ).flatten.map do |value|
            (info[:human_value]) ? info[:human_value].call(value) : value
          end
          
          # Separate the last element of a list with 'and' instead of a comma.
          last = list.pop
          
          strings << [field, "#{info[:human_string]||field} #{list.join(', ')} and #{last}"]
        end
      end
      
      # Convert the dayofweek parameter to "on the 3rd or Sunday" because of: 
      # 
      # If both the dom and dow are specified, the command will be executed when
      # either of the events happen. 
      # e.g.
      # * 12 16 * Mon root cmd
      # Will run cmd at midday every Monday and every 16th, and will produce the 
      # same result as both of these entries put together would:
      # * 12 16 * * root cmd
      # * 12 * * Mon root cmd
      if strings.select{|field,s| [:dayofmonth, :dayofweek].include? field }.size > 1
        strings.map! do |field, string|
          if field == :dayofweek
            [ field, "or #{string}" ]
          else
            [ field, string ]
          end
        end
      end
      
      # Remove the field parameter as it's not necessary anymore
      strings.map! {|field, string| string }

      # The initial loop is done in reverse to have an easy way to ensure that
      # we don't include unnecessary 'every' at the end of the string.
      strings.reverse!

      # If the minute and hour are both specific integers, convert the strings to 'at hh:mm'
      if @values[:minute].match( Patterns[:integer] ) and @values[:hour].match( Patterns[:integer] )
        strings[0] = nil
        strings[1] = "at %02d:%02d" % [@values[:hour], @values[:minute]]
      end
      strings.delete(nil)
      
      # prepend the command
      strings.unshift( "Run `#{@values[:cmd]}`" )
      
      # Join all of the strings in spaces and return
      return strings.join(", ")
    end

    private
    
    # Method that determines if the cron_value provided matches with the time_value provided
    def value_match?(cron_value, time_value)
      return true if cron_value.to_s.match( Patterns[:all] )
      return true if cron_value.to_s.match( Patterns[:increments] ) and (time_value % $1.to_i) == 0
      return true if cron_value.to_s.match( Patterns[:integer] ) and time_value.to_i == $1.to_i
      return false
    end
    
    def valid_format?(cron_value)
      cron_value = cron_value.to_s.strip
      
      Patterns.each do |name, pattern|
        return true if cron_value.match( pattern )
      end
      
      return false
    end
    
    def range_match?(cron_value, range)
      if cron_value.to_s.match( Patterns[:integer] )
        return range.include?( $1.to_i )
      else
        return true # Not even an int, can't validate.
      end
    end

  end # Cron
  
end; end # VRoy; Cron

__END__
minute
*     => every minutes
*/2   => every [2] minutes
1,2,3 => at the 1, 2 and 3 minutes
1     => at minute 1

hour
*     => every hour
*/2   => every 2 hours
1,2,3 => of the 1, 2 and 3 hours
1     => of hour 1

Examples
* *     => every minutes of every hours
* */2   => every minutes of every 2 hours
*/2 *   => every 2 minutes of every hours
*/2 */2 => every 2 minutes of every hours


* * * * * => every minutes
* * 2 * * => every minutes on the 2 of the month
* 1,3,4 * * => every minutes of hours 1, 3 and 4
* * * 1 * => every minutes of the month 1
0 * 1 * * => at minute 0 of every hour on the day 1
* * * * 2012 => every minutes of year 2012
* 1,2,3 1,2,3 1 2013 => every minutes of the hours 1, 2 and 3 of the days 1, 2 and 3 of the month 1 of year 2013
* * 1 * * => every minutes of the day 1
