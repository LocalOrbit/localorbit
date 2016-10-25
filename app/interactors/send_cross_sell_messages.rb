class SendCrossSellMessages
  include Interactor

  def perform
    # Get the main context items...
    publisher = context[:publisher]
    subscriber_list = context[:subscriber_list]

    # ...as well as the optional one(s)
    starting_status = context[:starting_status] || ""
    current_status = subscriber_list.status.downcase

    case current_status
    when "revoked"
      # Publisher action - message sent to subscribers
       sender = publisher
         list = subscriber_list
      subject = "Cross Selling List '#{list.name}' is no longer available"

    when "pending"
      # Publisher action - message sent to subscribers
       sender = publisher
         list = subscriber_list
      subject = "#{sender.name} has shared a new Cross Selling List"

    when "published"
      # Subscriber action - message sent to Publisher
       sender = subscriber_list.entity
         list = subscriber_list.parent
      subject = "#{sender.name} has activated your Cross Selling List"

    when "declined"
      # Subscriber action - message sent to Publisher
       sender = subscriber_list.entity
         list = subscriber_list.parent
      subject = "#{sender.name} has declined your Cross Selling List"

    when "inactive"
      # Subscriber action - message sent to Publisher
       sender = subscriber_list.entity
         list = subscriber_list.parent
      subject = "#{sender.name} has deactivated your Cross Selling List"

    else
      # There is no 'else'... MUAHAAHAAHAAHAAAAAA!
    end

    MarketMailer.delay.cross_selling_list_message(sender, list, subject, current_status) unless (current_status == "draft" || (starting_status.downcase == "pending" && current_status == "pending"))
  end

  def rollback
  end
end
