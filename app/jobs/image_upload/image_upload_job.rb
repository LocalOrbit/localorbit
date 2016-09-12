module ImageUpload
  class ImageUploadJob < Struct.new(:product) # pass in the datafile like is done right now in uploadcontroller, i.e.

    def enqueue(job)
    end

    def success(job)
      puts "success"
    end

    def error(job, exception)
      puts exception
    end

    def failure(job)
      puts "failed"
    end

    def perform
      img = Dragonfly.app.fetch_url(product.aws_image_url)
      img_orient = img.convert('-auto-orient')
      thumb = img_orient.thumb("150x150#")
      image_uid = img_orient.store
      thumb_uid = thumb.store

      product.general_product.image_uid = image_uid
      product.general_product.thumb_uid = thumb_uid
      product.save
    end

  end
end