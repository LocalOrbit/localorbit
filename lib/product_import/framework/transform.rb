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


      # Given an enum, return two arrays of the successful conversions and hashes of failure info
      # Note that this is not lazy and designed for testing.
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

      # Pass a single value through this transform and yield all successes/failures to
      # the passed-in block. This is the core implementation that of transform handling
      # and is used by all other invocation mechanisms.
      def transform_value(value, &block)
        fiber = Fiber.new{ transform_step(value); nil }
        while fiber.alive?
          status, payload = fiber.resume
          case status
          when :success
            yield status, payload
          when :failure
            yield status, payload.reverse_merge(raw: value)
          else
            # we got the return value of the block - We're done.
            break
          end
        end
      end

      public

      ###############################
      # Hooks - override these in your subclasses.

      # Given a value, pass along one or more successful conversions or
      # reject the value.
      def transform_step(row)
      end

      ################################

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
