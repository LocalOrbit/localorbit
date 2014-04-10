require "csv"

# Import the taxonomy tree from a csv export
# of the legacy taxonomy data
class ImportLegacyTaxonomy
  def self.run(filename, opts={})
    new(filename, opts).run
  end

  def initialize(filename, opts={})
    @filename       = filename
    @by_cat_id      = {}
    @base_nodes     = []
    @verbose        = opts[:verbose]
    @original_count = Category.count if @verbose
  end

  def run
    load_taxonomy
    build_tree
    store_tree(@base_nodes.sort_by {|n| n[:order_by].to_i }, Category.root || Category.create!(name: "All"))
    finish

    if @verbose
      puts "#{@original_count} Exisiting Categories"
      puts "Created #{Category.count - @original_count} new Categories."
      puts "There were #{@by_cat_id.size} rows detected in the import file"
    end
  end

  def load_taxonomy
    CSV.foreach(@filename, headers: true) do |row|
      next if row["cat_id"] == "1" || row["parent_id"] == "1"

      @by_cat_id[row["cat_id"]] = {name: row["cat_name"], children: [], parent_id: row["parent_id"], order_by: row["order_by"]}
    end
  end

  def build_tree
    @by_cat_id.each_value do |node|
      if parent = @by_cat_id[node[:parent_id]]
        parent[:children] << node
      else
        @base_nodes << node
      end
    end

    @base_nodes.reject! {|node| node[:parent_id] != "2" }
  end

  def store_tree(nodes, parent=nil)
    nodes.each do |node|
      obj = parent.children.find_or_initialize_by(name: node[:name])
      obj.save!
      print "." if @verbose
      store_tree(node[:children].sort_by {|n| n[:name] }, obj)
    end
  end

  def finish
    Category.rebuild! # needed to set proper depths
    puts "" if @verbose
  end
end
