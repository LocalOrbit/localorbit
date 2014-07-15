module IncludingDeleted
  def including_deleted
    unscope(market_organizations: :deleted_at)
  end
end
