class MainController < Ramaze::Controller
  layout '/layout'
  map '/'
  
  def index
  end

  deny_layout :cron
  def cron
    @cron = VRoy::Cron.new( request[:cron] )

    @start = Time.parse( Time.now.strftime("%Y-%m-%d %H:%M:00") )
    start_time = @start.strftime("%Y-%m-%d %H:%M:%S")

    @matches = []
    while @matches.size < 20
      @start += 60
  
      if @cron.match?(@start)
        display_time = 
        @matches << @start.strftime('%Y-%m-%d %H:%M:%S')
      end
    end

    return {
      :times => @matches,
      :cmd => @cron.cmd,
      :start_time => start_time
    }.to_json
  rescue Exception => e
    return { :error => e.message }.to_json
  end


end
