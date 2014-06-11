class PromotionDecorator < Draper::Decorator
  delegate_all

  def product
    @decorated_product ||= object.product.decorate(context: context)
  end
end
