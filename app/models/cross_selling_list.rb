class CrossSellingList < ActiveRecord::Base
  audited allow_mass_assignment: true
  include SoftDelete

  # KXM pre_delete anticipates Admin cross sell orphaned lists... to be continued...
  # before_destroy :pre_delete

  attr_accessor :shared_with
  attr_accessor :children_ids
  attr_accessor :suppliers
  attr_accessor :categories

  # KXM Relate X-Sell to Organization and remove polymorphic references...
  # Eventually, a list may reference any Organization of type 'S' or 'M' (supplier orgs or market orgs)
  # belongs_to :organization, -> { where("type IN ?", ('S','M') } # ...or something like that

  belongs_to :entity, polymorphic: true

  belongs_to :parent, class_name: "CrossSellingList"
  has_many :children, class_name: "CrossSellingList", foreign_key: "parent_id"

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

  scope :subscriptions, -> { where("creator <> ? AND status <> ?", true, 'Draft') }
  scope :published, -> { where("published_at IS NOT NULL", "status = Published") }
  scope :pending, -> { where(creator: false, status: "Pending") }
  scope :creator, -> { where(creator: true) }
  scope :active, -> { where(deleted_at: nil) }

  def statuses
    if creator || new_record? then
      statuses = {
        Draft:     "Draft",
        Published: "Published",
        Inactive:  "Inactive"
      }

      if status == "Draft" then
        statuses.except!(:Inactive)
      else
        # You can't revert to 'Draft'
        statuses.except!(:Draft)
      end

    else
      statuses = {
        Active:    "Published",
        Declined: "Declined",
        Inactive:  "Inactive"
      }

      if status == "Pending" then
        # This may not be as expected by Kate, et al...
        statuses.except!(:Inactive)
      else
        statuses.except!(:Declined)
      end
    end

    statuses
  end

  def manage_status(parent_status)
    update!(status: "Revoked") if parent_status == "Inactive" && status != "Revoked"
    update!(status: "Pending") if parent_status == "Published" && (status == "Revoked" || status == "Draft")
  end

  def manage_dates(status)
    case status
    when "Revoked"
      update!(deleted_at: Time.now) if deleted_at.nil?
    when "Published"
      update!(published_at: Time.now) if published_at.nil?
    else
      update!(deleted_at: nil)
    end

  end

  # Business had some different ideas about status names, 
  # but I like mine better (at least in the database)
  def translate_status(status)
    case status
    when "Revoked" # Revoked is a subscriber-only status
      "Deactivated by Publisher"

    when "Published" # Published is translated only for subscribers
      creator == true ? status : "Active"

    when "Draft" # Draft is translated for Subscribers, though the translation ought only appear on Publishers index page
      creator == false ? "Unreleased" : status

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

  def pending?
    status == "Pending"
  end

  def draft?
    status == "Draft"
  end

  def locked?
    status == 'Revoked'
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

  def display_product_overview?
    creator if creator
    status if statuses.to_a.include?(status)
  end

  def display_subscribers?
    creator || new_record?
  end

  def subscribers_list
    children.active.includes(:entity).map{|c| c.entity.name}.join(", ")
  end

  def pre_delete
    # This triggers 'Revoked' for subscribers
    manage_status("Inactive") if !creator
  end
end
