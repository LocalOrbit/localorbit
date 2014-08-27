if Rails.env.development?
  # Use MailCatcher to see the emails in development mode
  ActionMailer::Base.smtp_settings = {
    address: "localhost",
    port: 1025
  }

elsif Figaro.env.smtp_username
  ActionMailer::Base.smtp_settings = {
    address: "smtp.mandrillapp.com",
    port: 587,
    domain: "localorb.it",
    authentication: :login,
    user_name: Figaro.env.smtp_username,
    password: Figaro.env.smtp_password,
    enable_starttls_auto: true
  }
end
