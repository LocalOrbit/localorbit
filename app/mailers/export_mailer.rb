class ExportMailer < BaseMailer
  def export_success(recipients, file)

    puts "In Export Mailer"
    attachments['export.csv'] = {mime_type: 'text/csv', content: file}
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
