class DescriptiveError < StandardError
  attr_reader :data

  def initialize(message:nil, data:nil, root:nil)
    @message = message || "Error"
    @data = data
    @root = root
    if @root
      self.set_backtrace(root.backtrace || [])
    end
  end

  def message
    str = "#{@message}"
    if @data
      str += ": #{@data.to_json}"
    end
    str
  end
end
