S3DirectUpload.config do |c|
  c.access_key_id =     Figaro.env.uploads_access_key_id       # your access key id
  c.secret_access_key = Figaro.env.uploads_secret_access_key   # your secret access key
  c.bucket =            Figaro.env.uploads_bucket              # your bucket name
  c.region =            Figaro.env.uploads_region              # region prefix of your bucket url. This is _required_ for the non-default AWS region, eg. "s3-eu-west-1"
  c.url =               nil                                    # S3 API endpoint (optional), eg. "https://#{c.bucket}.s3.amazonaws.com/"

  module S3DirectUpload
    module UploadHelper
      class S3Uploader
        def url
          "http#{@options[:ssl] ? 's' : ''}://#{@options[:bucket]}.#{@options[:region]}.amazonaws.com/"
        end
      end
    end
  end
end