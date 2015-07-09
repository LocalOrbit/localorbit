module DavesQuickPrompt
  def quick_prompt(binding)
    prompt =  -> {
      print "QUICK PROMPT> "; $stdout.flush
      line = $stdin.gets
      if line
        line.strip
      else
        nil
      end
    }
    line = prompt.call
    while line and line != 'q'
      begin
        x = eval(line, binding)
        p x
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end

      line = prompt.call
    end
  end
end

RSpec.configure do |c| 
  c.include DavesQuickPrompt
end
