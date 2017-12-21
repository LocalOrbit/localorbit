module LayoutHelper

  def classes(*args)
    args.inject([]) do |memo, arg|
      case arg
      when Hash
        arg.each {|k, v| memo << k if v}
      else
        memo << arg if arg.present?
      end
      memo
    end.join(' ')
  end

end
