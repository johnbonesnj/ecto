require 'yaml'
require 'aws-sdk'

# config_file = File.join(File.dirname(__FILE__), "config.yml")
# unless File.exist? config_file
#   puts <<EOF
# To run the samples, put your credentials in config.yml as follows:

# access_key_id: YOUR_ACCESS_KEY_ID
# secret_access_key: YOUR_SECRET_ACCESS_KEY
# EOF
#   exit 1
# end
# config = YAML.load(File.read config_file)

ACCESS_KEY_ID = ENV['EC2_ACCESS_KEY']
SECRET_KEY_ID = ENV['EC2_SECRET_KEY']
config = {"access_key_id" => ACCESS_KEY_ID, "secret_access_key" => SECRET_KEY_ID}

unless config.kind_of? Hash
  puts <<EOF
config.yml is formatted incorrectly.  Please use the following format:

access_key_id: YOUR_ACCESS_KEY_ID
secret_access_key: YOUR_SECRET_ACCESS_KEY
EOF
 exit 1
end

AWS.config config


