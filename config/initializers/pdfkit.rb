PDFKit.configure do |config|
  config.wkhtmltopdf = '/Users/andyb/.rbenv/shims/wkhtmltopdf'
  # config.default_options[:quiet] = false
  config.default_options[:load_error_handling] = 'ignore'
end
