module ProductImport
  module Framework
    class StageDsl
      def initialize(data)
        @data = data
      end

      def transform(name, *args)
        @data[:transforms] << {
          name: name,
          class: ::ProductImport::Transforms.lookup_class(name),
          initialize_args: args
        }
      end
    end


    class ImportStage
      attr_reader :name

      def initialize(importer, name)
        @importer = importer
        @name = name
        @spec = importer.stage_spec_map[name]
        @transforms = nil
      end

      def transforms
        @transforms ||= @spec[:transforms].map do |tspec|
          t = tspec[:class].new(*tspec[:initialize_args])
        end
      end

      def transform
        ::ProductImport::Framework::TransformPipeline.new(
          stage: @spec[:name],
          desc: "#{@spec[:name]} stage transform",
          transforms: transforms
        )
      end
    end


    class FileImporter
      ALLOWED_STAGES = [:extract, :canonicalize]

      class_attribute :format_spec, :stage_spec_map

      class <<self

        # pass a format name (and optional args) to set
        # Otherwise, this is just an accessor for the format name
        def format(*name_and_args)
          unless name_and_args.empty?
            name, *args = name_and_args
            self.format_spec = {
              name: name,
              class: ::ProductImport::Formats.lookup_class(name),
              initialize_args: args,
            }
          end

          format_spec[:name]
        end

        def stage(name)
          raise ArgumentError unless ALLOWED_STAGES.include? name

          stage_hash = stage_spec_map[name]
          stage_hash[:name] = name
          yield StageDsl.new(stage_hash) if block_given?
        end
      end

      def initialize
        @stages ||= {}
      end

      def stage_named(key)
        raise ArgumentError unless ALLOWED_STAGES.include? key

        @stages[key] ||= ImportStage.new self, key
      end

      def stages
        stage_spec_map.keys.map{|k| stage_named(k)}
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



      ################################################
      # Private API

      def self.inherited(subclass)
        subclass.format_spec = {}
        subclass.stage_spec_map = Hash.new do |h,k|
          h[k] = {
            name: nil, # set in self.stage
            transforms: []
          }
        end
        subclass.stage :extract
        subclass.stage :canonicalize
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
end
