if %w(development test).include?(Rails.env)
  ActiveRecordQueryTrace.enabled = true
end
