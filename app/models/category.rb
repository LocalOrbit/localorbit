class Category < ActiveRecord::Base
  belongs_to :parent, class_name: 'Category'
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'
  has_many :products

  def self.for_select(list = nil, parent_str = nil)
    list ||= where(parent_id: nil)
    output = []
    list.each do |item|
      name = [parent_str, item.name].compact.join(" > ")
      output << [name, item.id]
      output.concat(for_select(item.children, name))
    end
    output
  end
end
