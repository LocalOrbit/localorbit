class OrderDeliveryStatusActionsPresenter

  def initialize(user, order, view_context)
    @user = user
    @order = order
    @vc = view_context
  end

  def render
    if Order::DeliveryStatusPolicy.new(user, order).mark_delivered?
      vc.button_tag 'Mark all delivered', class: 'pull-right btn btn--small btn--primary mobile-block', style: 'margin-left: 15px;', id: 'mark-all-delivered', type: 'button'
    elsif Order::DeliveryStatusPolicy.new(user, order).mark_undelivered?
      vc.button_tag 'Undo mark delivery', class: 'pull-right btn btn--small btn--primary mobile-block' , id: 'undo-delivery', type: 'button'
    end
  end

  private

  attr_reader :user, :order, :vc

end