class CrossSellingList < ActiveRecord::Base
  audited allow_mass_assignment: true
  include SoftDelete

  # Entity may reference a supplier org or a market org
  belongs_to :entity, polymorphic: true

  belongs_to :parent, class_name: "CrossSellingLists", foreign_key: "parent_id"
  has_many :products, through: :cross_selling_list_products

  # Basic validation
  validates :name, presence: true, length: {maximum: 255}
  validates :entity_id, presence: true, numericality: {only_integer: true}
  validates :entity_type, presence: true, length: {maximum: 255}
  validates :status, presence: true, length: {maximum: 255}

  # Can this specify only_integer AND presence: false?
  # validates :parent_id, numericality: {only_integer: true}

  def published?
  	status == 'Published' && published_at.past?
  end

  def is_master_list?
  	parent_id.nil?
  end

  def active?
  	# Master lists are active if published and not deleted
  	# Sublists are active if published and not deleted AND master list is active

  	# For now, though, let's just let everything pass...
  	true 
  end

end