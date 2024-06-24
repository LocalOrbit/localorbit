S3DirectUpload.config do |c|
  c.access_key_id =     ENV.fetch('UPLOADS_ACCESS_KEY_ID')       # your access key id
  c.secret_access_key = ENV.fetch('UPLOADS_SECRET_ACCESS_KEY')   # your secret access key
  c.bucket =            ENV.fetch('UPLOADS_BUCKET')              # your bucket name
  c.region =            ENV.fetch('UPLOADS_REGION')              # region prefix of your bucket url. This is _required_ for the non-default AWS region, eg. "s3-eu-west-1"
  c.url =               "https://#{c.bucket}.s3.amazonaws.com/"# S3 API endpoint (optional), eg. "https://#{c.bucket}.s3.amazonaws.com/"

  module S3DirectUpload
    module UploadHelper
      class S3Uploader
        def url
          "http#{@options[:ssl] ? 's' : ''}://#{@options[:bucket]}.#{@options[:region]}.s3.amazonaws.com/"
        end
      end
    end
  end
end