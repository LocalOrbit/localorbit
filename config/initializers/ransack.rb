Ransack.configure do |config|
  config.add_predicate 'date_gteq',
  arel_predicate: 'gteq',
  formatter: proc { |v| v.to_date.beginning_of_day },
  validator: proc { |v| v.present? },
  type: :string
end

Ransack.configure do |config|
  config.add_predicate 'date_lteq',
  arel_predicate: 'lteq',
  formatter: proc { |v| v.to_date.end_of_day },
  validator: proc { |v| v.present? },
  type: :string
end
