module Admin
  module DeliverySchedulesHelper
    def weekday_options
      %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday).each_with_index.to_a
    end

    def quarter_hour_select_options
      @quarter_hour_select_options ||= begin
        t = Time.parse('2014-02-02 12:00 AM')
        t_end = 24.hours.from_now(t)
        options = []
        while(t < t_end)
          options << t.strftime('%I:%M %p')
          t = 15.minutes.from_now(t)
        end
        options
      end
    end
  end
end
