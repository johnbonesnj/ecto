
require File.expand_path(File.dirname(__FILE__) + './ecto/config')
require 'securerandom'

bucket_name =ARGV[1]
file_name = ARGV[0]
#bucket_name &&
unless file_name
  puts "Usage: upload_file.rb  <FILE_NAME> <BUCKET_NAME>"
  exit 1
end
unless bucket_name
  bucket_name = SecureRandom.urlsafe_base64(8).downcase
end
# get an instance of the S3 interface using the default configuration
s3 = AWS::S3.new

# create a bucket
b = s3.buckets.create(bucket_name)

# upload a file
basename = File.basename(file_name)
o = b.objects[basename]
o.write(:file => file_name)

puts "Uploaded #{file_name} to:"
puts o.public_url

# generate a presigned URL
puts "\nUse this URL to download the file:"
puts o.url_for(:read)

puts "(press any key to delete the object)"
$stdin.getc

# o.delete #file delete
          #b.delete - deletes bucket
b.delete! #.delete! - deletes all files then bucket
