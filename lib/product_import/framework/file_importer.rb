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
        @spec[:transforms].map.with_index do |tspec, index|
          t = ::ProductImport::Transforms.instantiate_spec(tspec).tap{|t|
            t.stage = @spec[:name]
            t.desc = "transform #{index + 1} - #{tspec[:name]}"
            t.importer = @importer
          }
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


      ######################################################
      # Class-level meta api
      class <<self

        # Specify the format (and optional format configuration) for this file importer
        # Can be any symbol which is the name of a class in ProductImport::Formats.
        #
        # Example: format :csv
        def format(*name_and_args)
          unless name_and_args.empty?
            self.format_spec = ::ProductImport::Formats.build_spec(*name_and_args)
          end

          format_spec[:name]
        end

        # Configure the stage named `name`. Yields a Dsl object which can be used to
        # declare transformations.
        def stage(name)
          raise ArgumentError unless ALLOWED_STAGES.include? name

          # stages don't accumulate. Delete the existing value, forcing
          # reinitialization
          stage_spec_map.delete name
          stage_hash = stage_spec_map[name]
          stage_hash[:name] = name
          yield StageDsl.new(stage_hash) if block_given?
        end
      end

      attr_reader :opts

      def initialize(opts={})
        @opts = opts
        @stages ||= {}
      end

      # The Format object which can be used to load files given the declared format.
      def format
        format ||= ::ProductImport::Formats.instantiate_spec(self.class.format_spec)
      end

      # Get a stage object representing a stage.
      def stage_named(key)
        raise ArgumentError unless ALLOWED_STAGES.include? key

        @stages[key] ||= ImportStage.new self, key
      end

      # Get an array of stage objects representing every stage.
      def stages
        stage_spec_map.keys.map{|k| stage_named(k)}
      end

      # Get a single transform that combines all of the transforms in the provided stages.
      # Can take a single stage or a range of stages, such as (:extract..:canonicalize),
      # which runs all of the transforms in extract and canonicalize, as well as any future
      # stages which might be added in between.
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


      # Given a stage and a hash for loading a file using this importer's format,
      # load and validate the source data and run it through the transforms
      # in all stages up to and including `stage`.
      #
      # Designed to be used in testing to e.g. ensure a file importer correctly
      # reads and produces canonical data
      def run_through_stage(stage, format_args=nil)
        raise ArgumentError unless ALLOWED_STAGES.include? stage
        format_args ||= opts

        check_format_validity!(format_args)

        source_enum = format.enum_for(format_args)
        transform = transform_for_stages(ALLOWED_STAGES.first..stage)
        transform.transform_enum(source_enum)
      end

      def load_products(format_args=nil)
        format_args ||= opts

        check_format_validity!(format_args)

        source_enum = format.enum_for(format_args)
        transform = transform_for_stages(ALLOWED_STAGES)
        successes, failures = transform.transform_enum(source_enum)

        product_loader = ProductLoader.new
        product_loader.update successes

        _each_success_redirecting_failures(source_enum, transform) do |payload|
          product_loader.update_product payload
        end
      end


      def write_to_lodex(io, format_args=nil)
        format_args ||= opts

        check_format_validity!(format_args)

        source_enum = format.enum_for(format_args)
        transform = transform_for_stages(ALLOWED_STAGES.first..:canonicalize)

        CSV(io) do |csv|

          headers = nil

          _each_success_redirecting_failures(source_enum, transform) do |payload|
            unless headers
              headers = payload.keys
              if payload.key? 'source_data'
                headers.delete 'source_data'
                headers.concat payload['source_data'].keys
              end
              csv << headers
            end
            csv << headers.map{|h| payload[h] || payload['source_data'][h] }
          end
        end
      end

      def _each_success_redirecting_failures(source_enum, transform)
        seen_error = false

        source_enum.each do |row|
          transform.transform_value(row) do |status, payload|
            case status
            when :success
              yield payload
            else
              unless seen_error
                type = self.class.name.underscore
                $stderr.puts "# This file contains details about failures to convert data to lodex"
                $stderr.puts "# The source file importer type was #{type}"
                $stderr.puts "# You can fix the extract stage and rerun against the source data"
                $stderr.puts "# or fix the canonicalize stage and run against the raw values below"
                seen_error = true
              end
              $stderr.puts payload.to_yaml
            end
          end
        end
      end

      # Ensure the file is readable and nothing is rejected during extract
      # Does a full pass through the entire file. Used to ensure a file is
      # largely sane before we start putting anything in the database.
      def check_format_validity!(format_args)
        extract_transform = stage_named(:extract).transform

        got_a_row = false

        format.enum_for(format_args).each do |row|
          extract_transform.transform_value row do |status, payload|
            got_a_row = true
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
        subclass.stage :resolve do |s|
          _setup_resolve_stage(s)
        end
      end

      def self._setup_resolve_stage(s)
        # Default resolve stage implementation

        s.transform :look_up_category

        s.transform :set_keys_to_importer_option_values, map: {
          "market_id" => :market_id
        }

        s.transform :look_up_organization

        s.transform :validate_keys_are_present,
          keys: %w(organization_id market_id category_id)

      end

    end
  end
end
