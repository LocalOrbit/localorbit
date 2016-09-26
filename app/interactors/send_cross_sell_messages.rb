class SendCrossSellMessages
  include Interactor

  def perform
    # Get the main context items...
    publisher = context[:publisher]
    subscriber_list = context[:subscriber_list]

    # ...as well as the optional one(s)
    starting_status = context[:starting_status] || ""
    current_status = lower(subscriber_list.status)

    case current_status
    when "revoked"
      # Publisher action - message sent to subscribers
      subject = "Cross Selling List '#{@list_in_question.name}' is no longer available"
       sender = publisher
         list = subscriber_list

    when "pending"
      # Publisher action - message sent to subscribers
      subject = "#{@sender.name} has shared a new Cross Selling List"
       sender = publisher
         list = subscriber_list

    when "published"
      # Subscriber action - message sent to Publisher
      subject = "#{@subscriber.name} has activated your Cross Selling List"
       sender = subscriber_list.entity
         list = subscriber_list.parent

    when "declined"
      # Subscriber action - message sent to Publisher
      subject = "#{@subscriber.name} has declined your Cross Selling List"
       sender = subscriber_list.entity
         list = subscriber_list.parent

    when "inactive"
      # Subscriber action - message sent to Publisher
      subject = "#{@subscriber.name} has deactivated your Cross Selling List"
       sender = subscriber_list.entity
         list = subscriber_list.parent

    else
      # There is no 'else'... MUAHAAHAAHAAHAAAAAA!
    end

    MarketMailer.delay.cross_selling_list_message(sender, list, subject, current_status) unless starting_status == "Pending"
  end

  # def perform
  #   # Get the main context items...
  #   publisher = context[:publisher]
  #   subscriber_list = context[:subscriber_list]

  #   # ...as well as the optional one(s)
  #   starting_status = context[:starting_status] || ""

  #   case subscriber_list.status
  #   when "Revoked"
  #     MarketMailer.delay.revoked_cross_selling_list(publisher, subscriber_list)

  #   when "Pending"
  #     case starting_status
  #     when "Draft"
  #       # update action - announce an already created, but not yet published list (this is the horse)
  #       MarketMailer.delay.pending_cross_selling_list(publisher, subscriber_list)

  #     when "Pending"
  #       # update action ...again (this is a different horse)
  #       # If the starting status is 'Pending' then the list publication should have already been
  #       # announced above. This condition happens for any pending list whenever a published list
  #       # is edited (including product management).  Consequently, drop through...

  #     else
  #       # create action - announce a new, published list (this is the zebra)
  #       MarketMailer.delay.pending_cross_selling_list(publisher, subscriber_list)
  #     end

  #   when "Published"
  #     MarketMailer.delay.activated_cross_selling_list(subscriber_list.entity, subscriber_list.parent) if !subscriber_list.creator

  #   when "Declined"
  #     MarketMailer.delay.declined_cross_selling_list(subscriber_list.entity, subscriber_list.parent)

  #   when "Inactive"
  #     MarketMailer.delay.deactivated_cross_selling_list(subscriber_list.entity, subscriber_list.parent)

  #   else
  #     # There is no 'else'... MUAHAAHAAHAAHAAAAAA!
  #   end
  # end

  def rollback
  end
end
