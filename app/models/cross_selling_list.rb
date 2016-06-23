class CrossSellingList < ActiveRecord::Base
  audited allow_mass_assignment: true
  include SoftDelete

  attr_accessor :shared_with

  # Entity may reference a supplier org or a market org
  belongs_to :entity, polymorphic: true

  belongs_to :parent, class_name: "CrossSellingList"
  has_many :children, class_name: "CrossSellingList", foreign_key: "parent_id"
  has_many :active_children, -> { where(deleted_at: nil) }, class_name: "CrossSellingList", foreign_key: "parent_id"

  has_many :products, through: :cross_selling_list_products
  has_many :cross_selling_list_products

  # Basic validation
  validates :name, presence: true, length: {maximum: 255}
  validates :entity_id, presence: true, numericality: {only_integer: true}
  validates :entity_type, presence: true, length: {maximum: 255}
  validates :status, presence: true, length: {maximum: 255}

  # KXM flesh this out... may it reference the existing :children relation?
  # scope :active_children, -> { where("#{self.class.table_name}.") }

  # Can this specify only_integer without mandating presence: true?
  # validates :parent_id, numericality: {only_integer: true}

  def published?
  	status == 'Published' && published_at.past?
  end

  def publish!(published_date = nil)
    as_of = published_date ||= Time.now
    update!(staus: "Published", published_at: as_of)
  end

  def is_master_list?
  	parent_id.nil?
  end

  def active?
  	# Master lists are active if published and not deleted
    return true if parent_id.blank? && deleted_at.blank? && status == "Published"

  	# Sublists are active if published and not deleted AND master list is active
    return true if parent_id.present? && deleted_at.blank? && parent.active? && status == "Active"

    false
  end

  def pending?
    status == "Pending"
  end

  def subscribers
    active_children.includes(:entity).map{|c| c.entity.name}.join(", ")
  end
end