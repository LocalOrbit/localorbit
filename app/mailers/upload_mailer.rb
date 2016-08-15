class UploadMailer < BaseMailer
  def upload_success(recipients, num_products_loaded)

    @num_products_loaded = num_products_loaded
    mail(
      to: recipients,
      subject: "Product upload successful"
    )
  end

  def upload_fail(recipients, errors)

    @errors = errors
    mail(
      to: recipients,
      subject: "Product upload failed"
    )
  end
end
