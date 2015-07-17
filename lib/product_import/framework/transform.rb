require 'fiber'

module ProductImport
  module Framework
    class Transform
      attr_accessor :stage, :desc, :spec, :opts, :importer

      def initialize(opts={})
        @opts = opts

        @stage = opts[:stage]
        @desc = opts[:desc]
        @spec = opts[:spec]
        @importer = opts[:importer]
      end

      def transform_enum(enum)
        failed = []
        success = Enumerator::Lazy.new(enum) {|yielder, value|
          transform_value(value) do |status, payload|
            case status
            when :success
              yielder << payload
            when :failure
              failed << payload
            end
          end
        }

        [success.to_a, failed]
      end

      def transform_value(value, &block)
        fiber = Fiber.new{ transform_step(value); nil }
        while fiber.alive?
          status, payload = fiber.resume
          case status
          when :success
            yield status, payload
          when :failure
            yield status, payload.merge(raw: value)
          else
            break
          end
        end
      end

      public

      ###############################
      # Hooks - override these in your subclasses.
      def check_preconditions(row)
        # unless row.key? :foo
        #   reject "Must have a :key"
        # end
      end

      def transform_step(row)
      end

      def check_postconditions(row)
      end

      private

      def continue value
        Fiber.yield(:success, value)
      end

      def reject reason
        Fiber.yield :failure,
          reason: reason,
          stage: stage,
          transform: desc
      end


    end

  end

end
