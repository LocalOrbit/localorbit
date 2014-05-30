class InvoiceSearchPresenter
  include Search::DateFormat

  attr_reader :start_date, :end_date
  def initialize(opts)
    search = opts[:q] || {}

    @start_date = format_date(search[:invoice_due_date_date_gteq])
    @end_date = format_date(search[:invoice_due_date_date_lteq])
  end
end
