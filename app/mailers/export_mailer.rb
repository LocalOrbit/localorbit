class ExportMailer < BaseMailer
  def export_success(recipients, type, file)

    date = Time.now.strftime("%Y%m%d")
    attachments["#{date}-#{type}-export.csv"] = {mime_type: 'text/csv', content: file}
    mail(
      to: recipients,
      subject: "CSV Export results"
    )
  end

  def export_fail(recipients)

    mail(
      to: recipients,
      subject: "CSV Export failed"
    )
  end
end
