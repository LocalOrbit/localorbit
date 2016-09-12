class CrossSellingList < ActiveRecord::Base
  audited allow_mass_assignment: true
  include SoftDelete

  attr_accessor :shared_with
  attr_accessor :children_ids
  attr_accessor :suppliers
  attr_accessor :categories

  # KXM Relate X-Sell to Organization and remove polymorphic references...
  # Eventually, a list may reference any Organization of type 'S' or 'M' (supplier orgs or market orgs)
  # belongs_to :organization, -> { where(type: 'S').or(type: 'M') } # ...or something like that

  belongs_to :entity, polymorphic: true

  belongs_to :parent, class_name: "CrossSellingList"
  has_many :children, class_name: "CrossSellingList", foreign_key: "parent_id" do
    def active
      where(deleted_at: nil)
    end
  end

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

  def statuses
    if creator || new_record? then
      {
        Published: "Published",
        Inactive:  "Inactive"
      }
    else
      {
        Active:    "Published",
        Inactive:  "Inactive",
        Declined:  "Declined"
      }
    end
  end

  def manage_status(parent_status)
    update!(status: "Revoked") if parent_status == "Inactive" && status != "Revoked"
    update!(status: "Pending") if parent_status == "Published" && status == "Revoked"
  end

  # Business had some different ideas about status names, 
  # but I like mine better (at least in the database)
  def translate_status(status)
    case status
    when "Revoked" # Revoked is a subscriber-only status
      "Deactivated by Publisher"

    when "Published" # Published is translated only for subscribers
      creator == true ? status : "Active"

    else # All remaining statuses remain intact
      status

    end
  end

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

  def cascade_update?
    creator && (!draft? || children.any?)
  end

  def manage_publication!(params)
    if published?
      unpublish!(status) if status != "Published"
    else
      published_date = params[:published_date] ||= Time.now
      publish!(published_date) if status == "Published"
    end
  end

  def subscribers_list
    children.active.includes(:entity).map{|c| c.entity.name}.join(", ")
  end
end