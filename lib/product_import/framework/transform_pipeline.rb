require 'fiber'
require 'product_import/framework/transform'

module ProductImport
  module Framework

    class TransformPipeline < Transform
      attr_accessor :transforms

      def initialize(opts={})
        super
        self.transforms = opts[:transforms] || []
      end

      def transform_step v
        raw = v.deep_dup
        run_transform v, 0, raw
      end

      def run_transform v, cur_depth, raw
        if cur_depth == transforms.size
          continue v
        else
          t = transforms[cur_depth]
          t.transform_value v do |status, payload|
            if status == :success
              run_transform payload, cur_depth + 1, raw
            else
              Fiber.yield [status, payload]
            end
          end
        end
      end
    end
  end
end
