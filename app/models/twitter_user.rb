class TwitterUser
  def self.dump(value)
    clean_username(value.to_s)
  end

  def self.load(value)
    value.to_s
  end

  def self.clean_username(username)
    username.sub(/^@/, "")
  end
end
