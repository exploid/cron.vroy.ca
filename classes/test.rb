require "cron"

begin
  puts VRoy::Cron::Cron.new( "10 3 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 2,3 * /usr/local/bin" ).to_human_format
  puts "\n---------\n\n"
  puts VRoy::Cron::Cron.new( "*/1 * * * 1,3 cmd" ).to_human_format
  puts "\n---------\n\n"
  puts VRoy::Cron::Cron.new( "*/5 * 3 1 */4 cmd" ).to_human_format

rescue VRoy::Cron::InvalidFormat => e
  p e.message
end
