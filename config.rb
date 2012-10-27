require 'yaml'
require 'aws-sdk'

config_file = File.join(File.dirname(__FILE__), "config.yml")
unless File.exist? config_file
  puts <<EOF
To run the samples, put your credentials in config.yml as follows:

access_key_id: YOUR_ACCESS_KEY_ID
secret_access_key: YOUR_SECRET_ACCESS_KEY
EOF
  exit 1
end

