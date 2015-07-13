module ProductImport
  module Formats
    class Xls
      def enum_for(filename:)
        Enumerator.new do |yielder|
          require 'spreadsheet'

          workbook = Spreadsheet.open(filename)

          worksheet = workbook.worksheet 0

          worksheet.each do |row|
            values = (0...row.size).map{|i| row[i]}
            yielder << values
          end
        end
      end
    end
  end
end
