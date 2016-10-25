module CSVExport
  class CSVReportExportJob < Struct.new(:user, :params) # pass in the datafile like is done right now in uploadcontroller, i.e.

    def enqueue(job)
    end

    def success(job)
    end

    def error(job, exception)
      puts exception
    end

    def failure(job)
    end

    def perform
      presenter = ReportPresenter.report_for(params)
      csv = CSV.generate do |f|
        # Include Market if it's shown in either a column or as a filter
        all_fields = (ReportPresenter::REPORT_MAP[presenter.report].fetch(:fields, []) + ReportPresenter::REPORT_MAP[presenter.report].fetch(:filters, [])).uniq.compact
        include_market = all_fields.include?(:market_name)

        headers = include_market ? ["Market"] : []

        ReportPresenter::REPORT_MAP[presenter.report].fetch(:fields, []).each do |field|
          headers << ReportPresenter::FIELD_MAP[field][:display_name]
          headers << "Order Number" if field == :placed_at
        end

        f << headers

        presenter.items.decorate.each do |item|
          data = include_market ? [item.market_name] : []

          presenter.fields.each do |field|
            if field == :placed_at
              data << item.placed_at
              data << item.order_number
              #elsif field == :unit_price
              #  data << "#{item.unit_price}"
            else
              data << item.send(field)
            end
          end

          f << data
        end
      end

      # Send via email
      ExportMailer.delay.export_success(user.email, csv)
    end

  end
end