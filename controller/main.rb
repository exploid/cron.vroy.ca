class MainController < Ramaze::Controller
  layout '/layout'
  map '/'
  
  def index
  end

  deny_layout :cron
  def cron
    cron = VRoy::Cron::Cron.new( request[:cron] )
    
    start_time = Time.now
    
    return {
      :times => cron.next_runs( start_time ).map{|t| t.strftime("%Y-%m-%d %H:%M:%S") },
      :cmd => cron.cmd,
      :start_time => start_time.strftime("%Y-%m-%d %H:%M")
    }.to_json
  rescue VRoy::Cron::InvalidFormat => e
    return { :error => e.message.join("<br/>") }.to_json
  end


end
