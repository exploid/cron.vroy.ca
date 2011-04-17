require "time"

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
                :time_value => lambda{|t| t.hour }
              }],

            [ :dayofmonth, {
                :value => @dayofmonth,
                :invalid_message => "Invalid value for day of month.",
                :range => (1..31),
                :time_value => lambda{|t| t.day },
              }],

            [ :month, {
                :value => @month,
                :invalid_message => "Invalid value for month.",
                :range => (1..12),
                :time_value => lambda{|t| t.month },
              }],

            [ :dayofweek, {
                :value => @dayofweek,
                :invalid_message => "Invalid value for day of week.",
                :range => (0..6),
                :time_value => lambda{|t| t.wday },
              }],

           ]
  
  class InvalidFormat < Exception; end

  class Cron
    
    attr_reader :min, :hour, :dayofmonth, :month, :dayofweek, :year, :cmd
    def initialize(cron_string)
      @original_cron_string = cron_string
      
      values = cron_string.split(" ")
      
      raise "Please provide all required fields." if values.size < 6
      
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
        raise InvalidFormat, errors
      end
    end
    
    def valid?
      return errors.empty?
    end

    def errors
      if @errors.nil?
        @errors = []
        
        CronFields.each do |type, info|
          @errors << info[:invalid_message] if !range_match?( @values[type], info[:range] )
        end
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

    private
    
    # Method that determines if the cron_value provided matches with the time_value provided
    def value_match?(cron_value, time_value)
      return true if cron_value == "*"
      return true if cron_value.to_s.match(/\*\/(\d+)/) and (time_value % $1.to_i) == 0
      return true if cron_value.to_i == time_value
      return false
    end
    
    def range_match?(cron_value, range)
      if cron_value.to_s.match(/(\d+)/)
        return range.include?( $1.to_i )
      else
        return true # Not even an int, can't validate.
      end
    end

  end # Cron

end; end # VRoy; Cron

__END__
begin
  @cron = VRoy::Cron::Cron.new( "0 0 0 0 0 /usr/local/bin" )

  p @cron.next_runs( Time.now )
rescue VRoy::Cron::InvalidFormat => e
  p e.message
  p e.methods.sort
end

