module DragonflyBackgroundResize
  # Sets up a background task to resize the upload to a suitable max size
  # Optionally setup smaller images to generate after upload
  #
  # accessor: the main dragonfly attachment
  # max_width: used to resize upload if needed
  # max_height: used to resize upload if needed
  # thumbs: hash of dimension hashes to define the smaller images that should be generated off this image
  #
  # example:
  # define_after_upload_resize(:photo, 1200, 1200, photo_small: {width: 150, height: 150})
  def define_after_upload_resize(accessor, max_width, max_height, thumbs = {})
    class_eval <<-EOS
      around_save :post_process_#{accessor}, prepend: true

      def resize_#{accessor}
        return true unless #{accessor}.width > #{max_width} || #{accessor}.height > #{max_height}
        self.#{accessor} = #{accessor}.thumb('#{max_width}x#{max_height}>')
        save(validate: false)
      end

      def post_process_#{accessor}
        if #{accessor}_changed?
          yield
          if #{accessor}_stored? && (#{accessor}.width > #{max_width} || #{accessor}.height > #{max_height})
            delay.resize_#{accessor}
          end
        else
          yield
        end
      end
    EOS

    thumbs.each do |thumb_accessor, dimensions|
      class_eval <<-EOS
        around_save :generate_#{thumb_accessor}_for_#{accessor}, prepend: true

        def generate_#{thumb_accessor}_from_#{accessor}
          self.#{thumb_accessor} = #{accessor}.thumb('#{dimensions[:width]}x#{dimensions[:height]}>')
          save(validate: false)
        end

        def generate_#{thumb_accessor}_for_#{accessor}
          if #{accessor}_changed?
            self.#{thumb_accessor} = nil
            yield
            # We have an image and it doesn't need to be resized
            if #{accessor}_stored? && !(#{accessor}.width > #{max_width} || #{accessor}.height > #{max_height})
              delay.generate_#{thumb_accessor}_from_#{accessor}
            end
          else
            yield
          end
        end
      EOS
    end
  end
end
