class Sequence < ActiveRecord::Base
  def self.increment_for(name)
    sequence = find_or_create_by!(name: name)
    find_by_sql(["UPDATE sequences SET value = value + 1 WHERE id=? RETURNING value", sequence.id]).first.value
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def self.decrement_for(name, value)
    sequence = find_by!(name: name)
    if(sequence.value == value.to_i)
      find_by_sql(["UPDATE sequences SET value = value - 1 WHERE id=? RETURNING value", sequence.id]).first.value
    end
  end

  def self.set_value_for!(name, value)
    find_or_create_by(name: name).update_attributes!(value: value)
    value
  end
end
