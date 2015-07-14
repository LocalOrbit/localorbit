require 'fiber'
require 'product_import/transform'

module ProductImport

  class TransformPipeline < Transform
    attr_accessor :transforms

    def transform_step v
      raw = v.deep_dup
      run_transform v, 0, raw
    end

    def run_transform v, cur_depth, raw
      if cur_depth == transforms.size
        continue v
      else
        t = transforms[cur_depth]
        successes, failures = t.transform_enum([v])
        successes.each do |v2|
          run_transform v2, cur_depth + 1, raw
        end
        failures.each do |fail|
          Fiber.yield [:failure, fail]
        end
      end
    end
  end
end
