require "rubygems"

gem "ramaze", "2009.03"
require "ramaze"

class MainController < Ramaze::Controller
  map '/'
  
  def index
    "Cron Tester"
  end
end
