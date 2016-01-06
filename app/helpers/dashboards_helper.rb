module DashboardsHelper

  def last_seven_days(offset: 0)
    range_start = (@time + 1.day).beginning_of_day + offset.days
    range_end = (range_start - 6.days).end_of_day

    range_start..range_end
  end

  def last_thirty_days(offset: 0)
    range_start = (@time + 1.day).beginning_of_day + offset.days
    range_end = (range_start - 29.days).end_of_day

    range_start..range_end
  end

  def today(offset: 0)
    start_of_day = (@time).beginning_of_day + offset.days
    end_of_day = start_of_day.end_of_day

    start_of_day..end_of_day
  end

end