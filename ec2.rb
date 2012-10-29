require File.expand_path(File.dirname(__FILE__) + '/config')

require 'net/http'
#gem 'net-ssh', '~> 2.1.4'
require 'net/ssh'

instance = key_pair = group = nil
region = 'us-east-1'
config_file = File.join(File.dirname(__FILE__), "config.yml")
unless File.exist? config_file
  puts <<EOF
No config file
EOF
  exit 1
end
yconfig = YAML.load(File.read config_file)

begin
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
  image = AWS.memoize do
    amazon_linux = ec2.images.with_owner('099720109477').
      filter("root-device-type", "ebs").
      filter("architecture", "i386").
      filter("name", "*12.04*")
    amazon_linux.to_a.sort_by(&:name).last
  end
  puts "Using AMI: #{image.id}"
  key_pair = ec2.key_pairs.create("#{yconfig["name"]}")
  puts "Generated keypair #{key_pair.name}, fingerprint: #{key_pair.fingerprint}"
# open SSH access
  group = ec2.security_groups.create("#{yconfig["name"]}")
  group.authorize_ingress(:tcp, 22, "0.0.0.0/0")
  group.authorize_ingress(:tcp, 80, "0.0.0.0/0")
  puts "Using security group: #{group.name}"

  # launch the instance
  instance = image.run_instance(:key_pair => key_pair,
                                :security_groups => group,
                                :instance_type => 't1.micro',
                                :user_data => "Name = rails")
  sleep 1 until instance.status != :pending
  puts "Launched instance #{instance.id}, status: #{instance.status}"

  exit 1 unless instance.status == :running

  begin
    Net::SSH.start(instance.ip_address, "ubuntu",
                   :key_data => [key_pair.private_key]) do |ssh|
      puts "IP: \n" + instance.ip_address.to_s
      puts "KEY: \n" + key_pair.private_key.to_s
      puts "Running 'uname -a' on the instance yields:"
      puts ssh.exec!("uname -a")
      puts ssh.exec!("sudo apt-get install -y git-core curl build-essential wget")
      #puts ssh.exec!("sudo apt-get install -y python-software-properties")
      #puts ssh.exec!("sudo apt-add-repository ppa:brightbox/ruby-ng")
      #puts ssh.exec!("sudo apt-get update")
      #puts ssh.exec!("sudo apt-get install -y ruby rubygems ruby-switch ruby1.9.3 nginx")
    end
  rescue SystemCallError, Timeout::Error => e
    # port 22 might not be available immediately after the instance finishes launching
    sleep 1
    retry
  end

ensure
  # clean up
  #,group


  #puts "(press any key to delete the object)"
  #$stdin.getc
  #[instance,
  # key_pair].compact.each(&:delete)
end


