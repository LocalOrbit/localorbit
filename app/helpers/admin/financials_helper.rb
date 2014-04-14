module Admin::FinancialsHelper
  def display_due_date(date)
    date = date.to_date unless date.is_a?(Date)
    if date < Date.current
      days = Date.current - date
      "#{days.to_i} #{"Day".pluralize(days)} Overdue"
    else
      date.strftime("%m/%d/%Y")
    end
  end
end
