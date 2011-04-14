class MainController < Ramaze::Controller
  layout '/layout'
  map '/'
  
  def index
  end

  deny_layout :cron
  def cron
    @cron = VRoy::Cron.new( request[:cron] )

    @start = Time.parse( Time.now.strftime("%Y-%m-%d %H:%M:00") )

    @matches = []
    while @matches.size < 20
      @start += 60
  
      if @cron.match?(@start)
        display_time = 
        @matches << {
          :time => @start.strftime('%Y-%m-%d %H:%M:%S'),
          :cmd => @cron.cmd
        }
      end
    end

    return @matches.to_json
  end


end
