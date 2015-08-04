module ProductImport

  class ProductLoader
    def update(products_enum)
      batch_update_time = Time.now

      products_enum.each_slice(50) do |batch|
        products = upsert_products(batch, batch_updated_at: batch_updated_at)
      end

      # soft delete all products whose external product batch_updated_at wasn't updated
      # and whose organization id is an organization that was seen
    end

    def upsert_products(product_batch, batch_updated_at: Time.now)

      Product.transaction do

        eps = find_or_create_external_products product_batch
        ep_by_org_and_key = eps.index_by{|ep| [ep.organization_id, ep.contrived_key]}

        products_to_update = Product.where(external_product_id: eps.map(&:id)).
          includes(:prices, :lots).
          to_a
        products_by_ep_id = products_to_update.index_by(&:external_product_id)

        products = product_batch.map {|p|
          ep = ep_by_org_and_key[[p['organization_id'], p['contrived_key']]]
          ep_id = ep.id

          unless product = products_by_ep_id[ep_id]
            product = Product.new
            product.prices.build
            product.lots.build
          end

          product.assign_attributes(
            name: p['name'],
            organization_id: p['organization_id'],
            unit_id: p['unit_id'],
            category_id: p['category_id'],
            code: p['product_code'],
            short_description: p['short_description'],
            long_description: p['long_description'],
            unit_description: p['unit_description'],
            external_product_id: ep_id,
          )

          product.prices.first.assign_attributes(sale_price: p['price'], min_quantity: 1)
          reinfinity! product.lots.first

          product.save!
          product
        }

        ExternalProduct.where(id: eps.map(&:id)).
          update_all(batch_updated_at: batch_updated_at)

        products
      end

    end

    def reinfinity!(lot)
      lot.assign_attributes(quantity: 999_999)
    end

    def find_or_create_external_products(product_batch)
      contrived_keys = product_batch.map{|p|
        p['contrived_key']
      }

      eps = ExternalProduct.where(contrived_key: contrived_keys).to_a
      ep_by_org_and_key = eps.
        index_by{|ep| [ep.organization_id, ep.contrived_key]}

      product_batch.each do |p|
        org_id = p['organization_id']
        contrived_key = p['contrived_key']
        unless ep_by_org_and_key[[org_id, contrived_key]]
          eps << ExternalProduct.create!(
            organization_id: p['organization_id'],
            contrived_key: p['contrived_key'],
            source_data_json: p['source_data'].to_json,
          )
        end
      end

      eps
    end
  end

end
