require 'csv'

# Import the taxonomy tree from a csv export
# of the legacy taxonomy data
module ImportLegacyTaxonomy
  def self.run(filename)
    flattened  = {}
    base_nodes = []

    CSV.foreach(filename, headers: true) do |row|
      next if row['cat_id'] == '1' || row['parent_id'] == '1'

      flattened[row['cat_id']] = {name: row['cat_name'], children: [], parent_id: row['parent_id']}
    end

    flattened.each_value do |node|
      if parent = flattened[node[:parent_id]]
        parent[:children] << node
      else
        base_nodes << node
      end
    end

    store_tree(base_nodes)
  end

  def self.store_tree(nodes, parent = nil)
    nodes.each do |node|
      scope = Category.where(name: node[:name], parent_id: parent.try(:id))
      obj = scope.first || scope.create
      store_tree(node[:children], obj)
    end
  end
end
