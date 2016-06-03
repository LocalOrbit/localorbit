class CrossSellingListProducts < ActiveRecord::Base
  audited allow_mass_assignment: true
  
  belongs_to :product
  belongs_to :cross_sell_list

  # Manual disambiguation, YO!
  scope :active, -> { where("#{self.class.table_name}.active", true) }

end