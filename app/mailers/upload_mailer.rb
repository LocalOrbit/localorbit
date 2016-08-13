class UploadMailer < BaseMailer
  def upload_success(recipients)

    mail(
      to: recipients,
      subject: "Product upload successful"
    )
  end

  def upload_fail(recipients)

    mail(
      to: recipients,
      subject: "Product upload failed"
    )
  end
end
