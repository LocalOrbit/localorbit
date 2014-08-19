# -for payments, we need to be able to tell the difference between buyer payments and seller payments

class AuditDecorator < Draper::Decorator
  delegate_all

  def display_date
    created_at.strftime("%Y-%m-%d %_I:%M %p")
  end

  def associated_name
    associated.try(:name)
  end

  def display_action
    if auditable_type == "OrderItem"
      type = try(:name) || "Item"
    else
      type = auditable_type
    end
    "#{type} #{action_name}"
  end

  private

  def action_name
    if action == "destroy"
      "removed"
    else
      "#{action}d"
    end
  end
end