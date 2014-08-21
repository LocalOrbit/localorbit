# -for payments, we need to be able to tell the difference between buyer payments and seller payments

class AuditDecorator < Draper::Decorator
  delegate_all

  def user_name_or_email
    if username
      username
    elsif user
      user.name.present? ? user.name : user.email
    end
  end

  def display_date
    created_at.strftime("%Y-%m-%d %_I:%M %p")
  end

  def associated_name
    associated.try(:name)
  end

  def display_action
    "#{display_type} #{action_name}"
  end

  private

  def action_name
    if action == "destroy"
      "removed"
    elsif auditable_type == "Order" && action == "create"
      "placed"
    else
      "#{action}d"
    end
  end

  def display_type
    if auditable_type == "OrderItem"
      type = try(:name) || "Item"
    else
      type = auditable_type
    end
  end
end
