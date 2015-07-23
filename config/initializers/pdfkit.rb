PDFKit.configure do |config|
  # config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
  # config.default_options[:quiet] = false
  config.default_options[:load_error_handling] = 'ignore'
end
