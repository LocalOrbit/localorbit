module ProductImport
  module Formats
    class Xlsx
      def enum_for(filename:, **rest)
        Enumerator.new do |yielder|
          require 'rubyXL'

          begin
            workbook = RubyXL::Parser.parse(filename)
          rescue Zip::Error => e
            raise e, "XLSX file format error: #{e}", e.backtrace
          end
          raise ArgumentError, "No worksheets found in this workbook" if workbook.count < 1

          worksheet = workbook[0]

          (0...worksheet.count).each do |i|
            row = worksheet[i]
            if row
              values = (0...row.size).map{|i| row[i] && row[i].value}
              # binding.pry
              yielder << values
            end
          end
        end
      end
    end
  end
end
