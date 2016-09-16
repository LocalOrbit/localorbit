class SendCrossSellMessages
  include Interactor

  def perform
    # Get the main context items...
    publisher = context[:publisher]
    subscriber_list = context[:subscriber_list]

    # ...as well as the optional one(s)
    starting_status = context[:starting_status] || ""

    case subscriber_list.status
    when "Revoked"
      MarketMailer.delay.revoked_cross_selling_list(publisher, subscriber_list)

    when "Pending"
      case starting_status
      when "Draft"
        # update action - announce an already created, but not yet published list (this is the horse)
        MarketMailer.delay.pending_cross_selling_list(publisher, subscriber_list)

      when "Pending"
        # update action ...again (this is a different horse)
        # If the starting status is 'Pending' then the list publication should have already been
        # announced above. This condition happens for any pending list whenever a published list
        # is edited (including product management).  Consequently, drop through...

      else
        # create action - announce a new, published list (this is the zebra)
        MarketMailer.delay.pending_cross_selling_list(publisher, subscriber_list)
      end

    when "Published"
      MarketMailer.delay.activated_cross_selling_list(subscriber_list.entity, subscriber_list.parent) if !subscriber_list.creator

    when "Declined"
      MarketMailer.delay.declined_cross_selling_list(subscriber_list.entity, subscriber_list.parent)

    when "Inactive"
    else
    end
  end

  def rollback
  end
end
