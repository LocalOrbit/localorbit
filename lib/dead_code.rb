module DeadCode
  NotDeadCodeError = Class.new(StandardError)

  def dead_code!
    error = NotDeadCodeError.new("NOT dead code: #{caller.first.inspect}")

    if Rails.env.development?
      raise error
    else
      Rollbar.notify(error)
    end
  end
end
