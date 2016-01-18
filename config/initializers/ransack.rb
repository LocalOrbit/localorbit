Ransack.configure do |config|
  config.add_predicate "date_gteq",
    arel_predicate: "gteq",
    formatter: proc { |v| v.to_date.beginning_of_day },
    validator: proc { |v| v.present? },
    type: :string

  config.add_predicate "date_lteq",
    arel_predicate: "lteq",
    formatter: proc { |v| v.to_date.end_of_day },
    validator: proc { |v| v.present? },
    type: :string

  config.add_predicate "nil_in",
    arel_predicate: "in",
    formatter: proc { |v| v },
    validator: proc { |v| v.present? },
    type: :array

  config.add_predicate "nil_eq",
    arel_predicate: "eq",
    formatter: proc { |v| v == "-1" ? nil : v },
    validator: proc { |v| v.present? },
    type: :string
end

# Removes the sort indicator from ransack sort links.
module Ransack
  module Helpers
    module FormHelper
      def order_indicator_for(order); end
    end
  end
end
