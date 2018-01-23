if Rails.env.development?
  Rails.application.configure do
    config.after_initialize do
      Bullet.enable = false
      Bullet.bullet_logger = true
      Bullet.console = true
    end
  end
end
