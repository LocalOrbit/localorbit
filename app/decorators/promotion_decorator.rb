class PromotionDecorator < Draper::Decorator
  delegate_all

  def product
    @decorated_product ||= object.product.decorate(context: context)
  end

  def image
    if object.image_uid.present?
      object.image.thumb("75x").url
    elsif object.product.image_uid.present?
      object.product.image.thumb("75x").url
    else
      "default-product-image.png"
    end
  end
end
