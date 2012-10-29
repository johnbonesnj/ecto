require File.expand_path(File.dirname(__FILE__) + './ecto/config')

region = 'us-east-1'
ec2 = AWS::EC2.new
if region = ARGV.first
  region = ec2.regions[region]
  unless region.exists?
    puts "Requested region '#{region.name}' does not exist. Valid regions:"
    puts "  " + ec2.regions.map(&:name).join("\n ")
    exit 1
  end
  ec2 = region
end
groups = ec2.security_groups
a = groups.to_a
a.each do |i|
   if i.name == "default"
     puts "Safe - #{i.name}"
   elsif i.name == "quick-start-1"
     puts "Safe - #{i.name}"
   else
     puts "Gone - #{i.name}"
     i.delete
   end
 end
