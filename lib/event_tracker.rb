
module EventTracker
  cattr_accessor :capture_events, :previously_captured_events
  self.previously_captured_events = []
  self.capture_events = false

  #
  # EVENT TYPES
  #
  EventType = Struct.new(:name)

  ViewedOrder             = EventType.new("viewed-order")
  ViewedInvoices          = EventType.new("viewed-invoices")
  DownloadedPackingLabels = EventType.new("downloaded-packing-labels")
  DownloadedPosters       = EventType.new("downloaded-posters")
  DownloadedTableTents    = EventType.new("downloaded-table-tents")
  PreviewedBatchInvoices  = EventType.new("previewed-batch-invoices")

  #
  # METHODS
  # 
  def self.track_event_for_user(user, event, metadata={})
    if(self.capture_events)
      self.previously_captured_events << {user: user, event: event, metadata: metadata}
    else
      begin
        self.find_or_create_user!(user)
        Intercom::Event.create event_name: event, created_at: Time.now.to_i,
          metadata: metadata, email: user.email
      rescue Exception => ex
        puts ex.message
        puts ex.backtrace.join("\n")
        Honeybadger.notify_or_ignore(ex,
          context: {user: user.inspect, event: event, metadata: metadata})
      end
    end
    nil
  end

  def self.find_or_create_user!(user)
    begin
      intercom_record_of_user = Intercom::User.find(email: user.email)
    rescue Intercom::ResourceNotFound
      intercom_record_of_user = Intercom::User.create(email: user.email)
    end
    intercom_record_of_user
  end

end
