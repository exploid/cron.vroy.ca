require "rubygems"

gem "ramaze", "2009.03"
require "ramaze"

require "json"

Ramaze::acquire("controller/*")

require "classes/cron"
