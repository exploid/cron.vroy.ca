class MainController < Ramaze::Controller
  layout '/layout'
  map '/'
  
  def index
  end

  deny_layout :cron
  def cron
    cron = VRoy::Cron::Cron.new( request[:cron] )
    
    begin
      if !request[:time].to_s.empty?
        start_time = Time.parse( request[:time] )
        custom_time = true
      else
        start_time = Time.now
        custom_time = false
      end
    rescue Exception => e
      raise "There was an issue with the time format you provided. Please try again with a time in the YYYY-MM-DD HH:MM format."
    end
    
    return {
      :times => cron.next_runs( start_time ).map{|t| t.strftime("%Y-%m-%d %H:%M:%S") },
      :cmd => cron.cmd,
      :start_time => start_time.strftime("%Y-%m-%d %H:%M"),
      :custom_time => custom_time
    }.to_json
  rescue VRoy::Cron::InvalidFormat => e
    errors = e.message[:errors]
    invalid_types = errors.map{|x| x.first }
    messages = errors.map{|x| x.last }

    cron = e.message[:cron]
    
    _cron = []
    VRoy::Cron::CronFields.each do |type, info|
      if invalid_types.include?( type )
        _cron << "<span class='removed'>#{cron.values[type]}</span>"
      else
        _cron << "<span>#{cron.values[type]}</span>"
      end
    end
    _cron << cron.cmd

    return { :error => messages.join("<br/>"), :invalid_cron => _cron.join(" ") }.to_json
  rescue Exception => e
    return { :error => e.message } .to_json
  end


end
