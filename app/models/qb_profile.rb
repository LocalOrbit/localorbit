class QbProfile < ActiveRecord::Base
  belongs_to :organization

  validate :account_ids
  attr_accessor :session

  def account_ids
    if !income_account_name.nil? && !income_account_name.empty?
      result = Quickbooks::Account.query_account(income_account_name, session)
      if result.entries.length > 0
        self.income_account_id = result.entries[0].id
      else
        errors.add(:income_account_name, :invalid)
      end
    end

    if !expense_account_name.nil? && !expense_account_name.empty?
      result = Quickbooks::Account.query_account(expense_account_name, session)
      if result.entries.length > 0
        self.expense_account_id = result.entries[0].id
      else
        errors.add(:expense_account_name, :invalid)
      end
    end

    if !asset_account_name.nil? && !asset_account_name.empty?
      result = Quickbooks::Account.query_account(asset_account_name, session)
      if result.entries.length > 0
        self.asset_account_id = result.entries[0].id
      else
        errors.add(:asset_account_name, :invalid)
      end
    end

    if !ar_account_name.nil? && !ar_account_name.empty?
      result = Quickbooks::Account.query_account(ar_account_name, session)
      if result.entries.length > 0
        self.ar_account_id = result.entries[0].id
      else
        errors.add(:ar_account_name, :invalid)
      end
    end

    if !ap_account_name.nil? && !ap_account_name.empty?
      result = Quickbooks::Account.query_account(ap_account_name, session)
      if result.entries.length > 0
        self.ap_account_id = result.entries[0].id
      else
        errors.add(:ap_account_name, :invalid)
      end
    end

    if !fee_income_account_name.nil? && !fee_income_account_name.empty?
      result = Quickbooks::Account.query_account(fee_income_account_name, session)
      if result.entries.length > 0
        self.fee_income_account_id = result.entries[0].id
      else
        errors.add(:fee_income_account_name, :invalid)
      end
    end

    if !delivery_fee_account_name.nil? && !delivery_fee_account_name.empty?
      result = Quickbooks::Account.query_account(delivery_fee_account_name, session)
      if result.entries.length > 0
        self.delivery_fee_account_id = result.entries[0].id
      else
        errors.add(:delivery_fee_account_name, :invalid)
      end
    end

    if !delivery_fee_item_name.nil? && !delivery_fee_item_name.empty?
      result = Quickbooks::Item.query_item(delivery_fee_item_name, session)
      if result.entries.length > 0
        self.delivery_fee_item_id = result.entries[0].id
      else
        errors.add(:delivery_fee_item_name, :invalid)
      end
    end

    if !consolidated_supplier_item_name.nil? && !consolidated_supplier_item_name.empty?
      result = Quickbooks::Item.query_item(consolidated_supplier_item_name, session)
      if result.entries.length > 0
        self.consolidated_supplier_item_id = result.entries[0].id
      else
        errors.add(:consolidated_supplier_item_name, :invalid)
      end
    end

    if !consolidated_buyer_item_name.nil? && !consolidated_buyer_item_name.empty?
      result = Quickbooks::Item.query_item(consolidated_buyer_item_name, session)
      if result.entries.length > 0
        self.consolidated_buyer_item_id = result.entries[0].id
      else
        errors.add(:consolidated_buyer_item_name, :invalid)
      end
    end

  end
end