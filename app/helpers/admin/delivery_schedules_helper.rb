module Admin
  module DeliverySchedulesHelper
    def weekday_options
      DeliverySchedule::WEEKDAYS.each_with_index.to_a
    end

    def quarter_hour_select_options
      @quarter_hour_select_options ||= begin
        t = Time.parse('2014-02-02 12:00 AM')
        t_end = 24.hours.from_now(t)
        options = []
        while(t < t_end)
          options << t.strftime('%_I:%M %p').strip
          t = 15.minutes.from_now(t)
        end
        options
      end
    end
  end
end
