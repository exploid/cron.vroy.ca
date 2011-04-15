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
      
      raise "Invalid crontab line" if values.size < 6

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
      raise "Invalid value for day of week." if !range_match?( cron_value, (0..6) )
      return value_match?(cron_value, time_obj.wday)
    end

    # month (1 - 12)
    def month_match?(cron_value, time_obj)
      raise "Invalid value for month." if !range_match?( cron_value, (1..12) )
      return value_match?(cron_value, time_obj.month)
    end

    # day of month (1 - 31)
    def dayofmonth_match?(cron_value, time_obj)
      raise "Invalid value for day of month." if !range_match?( cron_value, (1..31) )
      return value_match?(cron_value, time_obj.day)
    end

    # hour (0 - 23)
    def hour_match?(cron_value, time_obj)
      raise "Invalid value for hour." if !range_match?( cron_value, (1..23) )
      return value_match?(cron_value, time_obj.hour)
    end

    # min (0 - 59)
    def minute_match?(cron_value, time_obj)
      raise "Invalid value for minute." if !range_match?( cron_value, (0..59) )
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
      if cron_value.to_s.match(/\d+/)
        return range.include?( $1.to_i )
      else
        return true # Not even an int, can't validate.
      end
    end

  end

end


__END__
@cron = VRoy::Cron.new( "*/2 */3 * * * /usr/local/bin" )

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
