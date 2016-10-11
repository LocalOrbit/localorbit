class ExportMailer < BaseMailer
  def export_success(recipients, file)

    attachments['export.csv'] = open(file).read
    puts recipients
    puts attachments['export.csv']
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
