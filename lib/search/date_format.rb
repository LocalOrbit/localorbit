module Search
  module DateFormat
    private

    def format_date(date_string)
      date_string.present? ? Date.parse(date_string) : nil
    end
  end
end
