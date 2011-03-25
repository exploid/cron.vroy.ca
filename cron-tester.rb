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

require "rubygems"
require "time"

# Weekday value in crontab is 0-6 (Sunday=0)
# Weekday value in Time is 0-6 (Sunday=0)
def dayofweek_match?(value, time)
  return true if value == "*"
  return true if value.match(/\*\/(\d+)/) and (time.wday % $1.to_i) == 0
  return true if value.to_i == time.wday
  return false
end

def month_match?(value, time)
  return true if value == "*"
  return true if value.match(/\*\/(\d+)/) and (time.month % $1.to_i) == 0
  return true if value.to_i == time.month
  return false
end

def dayofmonth_match?(value, time)
  return true if value == "*"
  return true if value.match(/\*\/(\d+)/) and (time.day % $1.to_i) == 0
  return true if value.to_i == time.day
  return false
end

def hour_match?(value, time)
  return true if value == "*"
  return true if value.match(/\*\/(\d+)/) and (time.hour % $1.to_i) == 0
  return true if value.to_i == time.hour
  return false
end

def minute_match?(value, time)
  return true if value == "*"
  return true if value.match(/\*\/(\d+)/) and (time.min % $1.to_i) == 0
  return true if value.to_i == time.min
  return false
end

@cron_line = "0 */3 * * * /usr/local/bin"

@min, @hour, @dayofmonth, @month, @dayofweek, @cmd = @cron_line.split(" ")

@start = Time.parse( Time.now.strftime("%Y-%m-%d %H:%M:00") )

@matches = []
while @matches.size < 20
  @start += 60
  
  next unless dayofweek_match?(@dayofweek, @start)
  next unless month_match?(@month, @start)
  next unless dayofmonth_match?(@dayofmonth, @start)
  next unless hour_match?(@hour, @start)
  next unless minute_match?(@min, @start)

  @matches << "#{@start.strftime('%Y-%m-%d %H:%M:%S')}: #{@cmd}"
end

puts @matches
