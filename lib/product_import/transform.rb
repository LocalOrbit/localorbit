require 'fiber'





module ProductImport
  class Transform
    attr_accessor :stage, :desc

    def initialize(opts={})
      @opts = opts
    end

    def transform_enum(enum)
      failed = []
      success = Enumerator::Lazy.new(enum) {|yielder, value|
        raw = value.deep_dup
        transform_value(value) do |status, payload|
          case status
          when :success
            yielder << payload
          when :failure
            failed << payload.merge("raw" => raw)
          end
        end
      }

      [success.to_a, failed]
    end

    def transform_value(value, &block)
      fiber = Fiber.new{ transform_step(value); nil }
      while fiber.alive?
        status, payload = fiber.resume
        if status.nil?
          break
        else
          yield status, payload
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
      # row[:foo] += "bar"
    end

    def check_postconditions(row)
    end

    private

    def continue value
      Fiber.yield(:success, value)
    end

    def reject reason
      Fiber.yield :failure,
        "reason" => reason,
        "stage" => stage,
        "transform" => desc
    end


  end


end
