class PromotionDecorator < Draper::Decorator
  delegate_all

  def product
    @decorated_product ||= object.product.decorate(context: context)
  end

  def image
    if object.image_stored?
      object.image.thumb("150x").url
    elsif object.product.thumb_stored?
      object.product.thumb.url
    elsif object.product.image_stored?
      object.product.image.thumb("150x").url
    else
      "default-product-image.png"
    end
  end
end
