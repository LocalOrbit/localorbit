module ProductImport
  class Transform

    def initialize(source_enum, *args)
      @source_enum
      @args = args
    end

    def check_preconditions(row)
    end

    def transform(row)
    end

    def check_postconditions(row)
    end

    def to_enum
      Enumerator::Lazy.new do |yielder, row|
        failed = false

        unless check_preconditions(row)
          failed = true
        end

        unless failed
          begin
            t = transform(row)
          rescue
            failed = true
          end
        end

        if !failed && check_postconditions(row)
          yielder << t
        else
          failed = true
        end
      end
    end
  end
end

