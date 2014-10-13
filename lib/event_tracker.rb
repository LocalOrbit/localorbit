
module EventTracker

  def track_event_for_user(user, event, metadata={})
    Intercom::Event.create event_name: event, created_at: Time.now.to_i,
      metadata: metadata, email: user.email
  rescue Exception => ex
    puts ex.message
    puts ex.backtrace.join("\n")
    Honeybadger.notify_or_ignore(ex, 
      context: {user: user.inspect, event: event, metadata: metadata})
  end
end
