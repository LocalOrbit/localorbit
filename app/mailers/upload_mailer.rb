class UploadMailer < BaseMailer
  def upload_success(recipients, num_products_loaded, errors)

    @num_products_loaded = num_products_loaded
    @errors = errors
    mail(
      to: recipients,
      subject: "Product upload results"
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
