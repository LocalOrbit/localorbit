class CrossSellingList < ActiveRecord::Base
  audited allow_mass_assignment: true
  include SoftDelete

  attr_accessor :shared_with
  attr_accessor :children_ids
  attr_accessor :suppliers
  attr_accessor :categories

  # KXM This is so February, 2016 - isn't X-Selling exclusively related to Organizations (albeit of types 'M' or 'S')?
  # Entity may reference a supplier org or a market org
  belongs_to :entity, polymorphic: true

  belongs_to :parent, class_name: "CrossSellingList"
  has_many :children, class_name: "CrossSellingList", foreign_key: "parent_id" do
    def active
      where(deleted_at: nil)
    end
  end

  has_many :active_children, -> { where(deleted_at: nil) }, class_name: "CrossSellingList", foreign_key: "parent_id"

  has_many :cross_selling_list_products, inverse_of: :cross_selling_list
  has_many :products, through: :cross_selling_list_products do
    def active
      where("cross_selling_list_products.active = ?", true)
    end
  end

  accepts_nested_attributes_for :cross_selling_list_products

  # Basic validation
  validates :name, presence: true, length: {maximum: 255}
  validates :entity_id, presence: true, numericality: {only_integer: true}
  validates :entity_type, presence: true, length: {maximum: 255}
  validates :status, presence: true, length: {maximum: 255}

  scope :subscribed, -> { where(creator: false) }
  scope :published, -> { where("published_at IS NOT NULL", "status = Published") }

  # KXM flesh this out... may it reference the existing :children relation?
  # scope :active_children, -> { where("#{self.class.table_name}.") }

  # Can this specify only_integer without mandating presence: true?
  # validates :parent_id, numericality: {only_integer: true}

  def published?
    status == 'Published' && published_at && published_at.past?
  end

  def publish!(published_date = nil)
    as_of = published_date ||= Time.now
    update!(status: "Published", published_at: as_of)
  end

  # Triggered by UI action.  Parent unpublish triggers 'Inactive' status in children
  def unpublish!(status = nil)
    new_status = status ||= "Unpublished"
    update!(status: new_status, published_at: nil)
  end

  def is_master_list?
  	parent_id.nil?
  end

  # KXM Active? is likely without good use, at least in this implementation
  def active?
  	# Master lists are active if published and not deleted
    return parent_id.blank? && deleted_at.blank? && published?

  	# Sublists are active if published and not deleted AND master list is active
    return parent_id.present? && deleted_at.blank? && parent.active? && published?

    false
  end

  def pending?
    status == "Pending"
  end

  def draft?
    status == "Draft"
  end

  # KXM Manage publication automatically (after save)?
  def manage_publication!(params)
    if published?
      unpublish!(status) if status != "Published"
    else
      published_date = params[:published_date] ||= Time.now
      publish!(published_date) if status == "Published"
    end
  end

  def subscribers
    children.active.includes(:entity).map{|c| c.entity.name}.join(", ")
  end
end