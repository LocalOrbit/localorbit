module ImageUpload
  class ImageUploadJob  < Struct.new(:product) # pass in the datafile like is done right now in uploadcontroller, i.e.

    def enqueue(job)
    end

    def success(job)
    end

    def error(job, exception)
    end

    def failure(job)
    end

    def perform
      img = Dragonfly.app.fetch_url(product.aws_image_url)
      image_uid = img.store
      product.general_product.image_uid = image_uid
      product.save
    end

  end
end