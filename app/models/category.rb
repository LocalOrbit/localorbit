class Category < ActiveRecord::Base
  belongs_to :parent, class_name: 'Category'
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'
  has_many :products

  # Returns select list options with root Cateogries as option groups
  def self.for_select
    list = where(parent_id: nil).order(:name).includes(:children => {:children => {:children => {:children => :children}}})
    list.inject({}) {|out,item| out[item.name] = for_select_children(item.children); out }
  end

  # Returns select list options for the given list of categories
  def self.for_select_children(list, parent_str = nil)
    output = []
    list.each do |item|
      name = [parent_str, item.name].compact.join(" / ")
      output << [name, item.id] if item.children.empty?
      output.concat(for_select_children(item.children, name))
    end
    output.sort {|a,b| a[0] <=> b[0] }
  end
end
