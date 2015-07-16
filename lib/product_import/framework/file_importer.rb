module ProductImport
  module Framework
    class StageDsl
      def initialize(data)
        @data = data
      end

      def transform(*name_and_args)
        @data[:transforms] << ::ProductImport::Transforms.build_spec(*name_and_args)
      end
    end


    class ImportStage
      attr_reader :name

      def initialize(importer, name)
        @importer = importer
        @name = name
        @spec = importer.stage_spec_map[name]
      end

      def transforms
        @spec[:transforms].map do |tspec|
          t = ::ProductImport::Transforms.instantiate_spec(tspec).tap{|t|
            t.importer = @importer}
        end
      end

      def transform
        ::ProductImport::Framework::TransformPipeline.new(
          stage: @spec[:name],
          desc: "#{@spec[:name]} stage transform",
          spec: @spec,
          transforms: transforms,
          importer: @importer
        )
      end
    end


    class FileImporter
      ALLOWED_STAGES = [:extract, :canonicalize, :resolve]

      class_attribute :format_spec, :stage_spec_map

      class <<self

        # pass a format name (and optional args) to set
        # Otherwise, this is just an accessor for the format name
        def format(*name_and_args)
          unless name_and_args.empty?
            self.format_spec = ::ProductImport::Formats.build_spec(*name_and_args)
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

      def initialize(opts={})
        @stages ||= {}
      end

      def format
        format ||= ::ProductImport::Formats.instantiate_spec(self.class.format_spec)
      end

      def stage_named(key)
        raise ArgumentError unless ALLOWED_STAGES.include? key

        @stages[key] ||= ImportStage.new self, key
      end

      def stages
        stage_spec_map.keys.map{|k| stage_named(k)}
      end

      def transform_for_stages(*stages)
        # If passed a single Range argument, create a transform for 
        # all stages between the range's begin and end.
        #
        # Use this to test a sequence of stages in a way that won't blow up if
        # we insert new stages later.
        if stages.size == 1 and stages[0].is_a? Range
          range = stages[0]
          i1 = ALLOWED_STAGES.index range.begin
          i2 = ALLOWED_STAGES.index range.end
          raise ArgumentError, "Invalid stages in range #{range.inspect}" if i1.nil? || i2.nil?

          index_range = Range.new i1, i2, range.exclude_end?
          stages = ALLOWED_STAGES.slice index_range
        end

        transforms = stages.map{|sn| stage_named(sn).transform}

        ::ProductImport::Framework::TransformPipeline.new(
          stage: stages,
          desc: "transform for stages: #{stages.join(", ")}",
          transforms: transforms
        )
      end


      def run_through_stage(stage, format_args)
        raise ArgumentError unless ALLOWED_STAGES.include? stage

        check_format_validity!(format_args)

        source_enum = format.enum_for(format_args)
        transform = transform_for_stages(ALLOWED_STAGES.first..stage)
        transform.transform_enum(source_enum)
      end

      # ensure the file is readable and nothing is rejected during extract
      # Does a full pass through the entire file.
      def check_format_validity!(format_args)
        extract_transform = stage_named(:extract).transform

        got_a_row = false

        format.enum_for(format_args).each do |row|
          got_a_row = true
          extract_transform.transform_value row do |status, payload|
            if status == :failure
              raise ArgumentError, "A transform failed during the extract phase. Assuming file is invalid and bailing out"
            end
          end
        end

        unless got_a_row
          raise ArgumentError, "Got zero rows when reading from source file"
        end
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
        subclass.stage :resolve
      end

    end
  end
end
