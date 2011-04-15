require "time"

module VRoy

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

  class Cron
    
    attr_reader :min, :hour, :dayofmonth, :month, :dayofweek, :year, :cmd
    def initialize(cron_string)
      @original_cron_string = cron_string
      
      values = cron_string.split(" ")
      
      raise "Please provide all required fields." if values.size < 6

      @min = values.shift
      @hour = values.shift
      @dayofmonth = values.shift
      @month = values.shift
      @dayofweek = values.shift
      
      @cmd = values.join(" ")
      
      #TODO: @cmd = the rest of the string.
      # if values.size == 7
        # @min, @hour, @dayofmonth, @month, @dayofweek, @year, @cmd = values
      # else
      # @min, @hour, @dayofmonth, @month, @dayofweek, @cmd = values
      # end

      if !valid?
        raise errors.join("<br/>")
      end
    end
    
    def valid?
      return errors.empty?
    end
    
    # Runs a quick validation through each type of value and returns an array with all of the error messages.
    def errors
      if @errors.nil?
        @errors = []
        @errors << "Invalid value for day of week." if !range_match?( @dayofweek, (0..6) )
        @errors << "Invalid value for month." if !range_match?( @month, (1..12) )
        @errors << "Invalid value for day of month." if !range_match?( @dayofmonth, (1..31) )
        @errors << "Invalid value for hour." if !range_match?( @hour, (1..23) )
        @errors << "Invalid value for minute." if !range_match?( @min, (0..59) )
      end
      return @errors
    end

    # Method that confirms if all of the crontab values matches or not.
    def match?(time_obj)
      return false unless dayofweek_match?(@dayofweek, time_obj)
      return false unless month_match?(@month, time_obj)
      return false unless dayofmonth_match?(@dayofmonth, time_obj)
      return false unless hour_match?(@hour, time_obj)
      return false unless minute_match?(@min, time_obj)
      
      return true
    end
    
    # day of week (0 - 6) (Sunday=0)
    # Weekday value in Time is 0-6 (Sunday=0)    
    def dayofweek_match?(cron_value, time_obj)
      return value_match?(cron_value, time_obj.wday)
    end

    # month (1 - 12)
    def month_match?(cron_value, time_obj)
      return value_match?(cron_value, time_obj.month)
    end

    # day of month (1 - 31)
    def dayofmonth_match?(cron_value, time_obj)
      return value_match?(cron_value, time_obj.day)
    end

    # hour (0 - 23)
    def hour_match?(cron_value, time_obj)
      return value_match?(cron_value, time_obj.hour)
    end

    # min (0 - 59)
    def minute_match?(cron_value, time_obj)
      return value_match?(cron_value, time_obj.min)
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

  end

end


__END__
@cron = VRoy::Cron.new( "0 0 0 2 0 /usr/local/bin" )

@start = Time.parse( Time.now.strftime("%Y-%m-%d %H:%M:00") )

@matches = []
while @matches.size < 20
  @start += 60
  
  if @cron.match?(@start)
    display_time = @start.strftime('%Y-%m-%d %H:%M:%S')
    @matches << "#{display_time}: #{@cron.cmd}"
  end
end

puts @matches
