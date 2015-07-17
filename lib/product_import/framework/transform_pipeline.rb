require 'fiber'
require 'product_import/framework/transform'

module ProductImport
  module Framework

    class TransformPipeline < Transform
      class_attribute :transform_specs
      attr_accessor :transforms

      class <<self
        def transform(*name_and_args)
          self.transform_specs ||= []
          transform_specs << ::ProductImport::Transforms.build_spec(*name_and_args)
        end
      end

      def initialize(opts={})
        super
        @transforms = opts[:transforms] if opts.key?(:transforms)
      end

      def transforms
        @transforms ||= self.class.transform_specs.map.with_index{|spec, index|
          ::ProductImport::Transforms.instantiate_spec(spec).tap{|t|
            t.stage = stage
            t.desc = "#{desc} - substep #{index+1} - #{spec[:name]}"
            t.importer = importer
          }
        }
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
