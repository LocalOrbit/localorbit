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
      thumb = img.thumb("150x150>")
      image_uid = img.store
      thumb_uid = thumb.store

      product.general_product.image_uid = image_uid
      product.general_product.thumb_uid = thumb_uid
      product.save
    end

  end
end