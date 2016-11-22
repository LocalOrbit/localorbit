module CSVExport
  class CSVImportProductExportJob < Struct.new(:user, :subdomain, :ids) # pass in the datafile like is done right now in uploadcontroller, i.e.

    def enqueue(job)
    end

    def success(job)
    end

    def error(job, exception)
      puts exception
    end

    def failure(job)
    end

    def perform
      products = Product.where(id: ids).order(:name)
      csv = CSV.generate do |f|
        f << ["Organization","Market Subdomain","Product Name","Category Name","Short Description","Product Code","Unit Name","Unit Description","Price","Current Inventory","New Inventory","Product ID"]

        products.decorate.each do |product|
          f << [
              product.organization_name,
              subdomain,
              product.name,
              product.second_level_category.name,
              product.short_description,
              product.code,
              product.unit.singular,
              product.unit_description,
              product.prices.view_sorted_export.decorate.map(&:min_1_qty)[0],
              product.use_simple_inventory && product.lots.count == 1 ? product.lots[0].quantity : "N/A",
              "",
              product.id
          ]
        end
      end

      # Send via email
      ExportMailer.delay.export_success(user.email, 'product', csv)
    end

  end
end