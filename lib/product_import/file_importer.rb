module ProductImport
  class FileImporter
    class <<self
      def format(type, *args)
      end

      %w(transform_format validate transform).each do |stage|
        define_method stage do |type, *args|
        end
      end
    end


    def import_file(*args)
      source = _source_enum_for_file(*args)
      transformed = _transformed_enum_for(source)
      import_products transformed_enum
    end

    def convert_file_to_lo(filename, io)
      source = _source_enum_for_file(*args)
      transformed = _transformed_enum_for(source)
      write_lo transformed_enum, io
    end

    def import_raw_enum(enum)
      transformed = _transformed_enum_for(source)
      import_products transformed_enum
    end

    def _source_enum_for_file(file)
      # support whatever our format supports
      source_enum = format.enum_for *args
      preprocessed_enum = instatiate_transforms(format_transforms, source_enum)

      if capture?
        preprocessed_enum = Teenum.new(source_enum, "source_data")
      end

      preprocessed_enum
    end

    def _transformed_enum_for(source_enum)
      active_transforms = self.transforms

      if capture?
        capture_transforms = base_transforms.map do |t|
          label = "some function of t"
          [:teenum, label]
        end

        active_transforms = active_transforms.zip(capture_transforms).flatten
      end

      transformed_enum = instatiate_transforms(active_transforms, source_enum)
    end
  end
end
