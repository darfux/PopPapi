require_relative 'repeat_checker'
require 'yaml'


doc = File.read("processed.txt")


paragraphs = doc.split(/\n/).reject{ |s| s.strip.empty? }

@checker = RepeatChecker.new(Time.now.to_i.to_s)
@ph_res = nil

def handle_check(str)
  puts "checking #{str}"
  retry_counter = 0
  begin
    ret = @checker.check(str)
  rescue
    retry_counter += 1
    exit if retry_counter > 10
    sleep 10*retry_counter
    retry
  end
  @ph_res << {text: str, state: ret}
  if ret
    puts "repeat! #{ret}"
  else
    puts "ok"
  end

  ret
end

@full_doc = []
paragraphs.each do |ph|
  @ph_res = []
  sentences = ph.split(/[。\n]/).reject{ |s| s.empty? }
  sentences.each do |sent|
    if sent.size > RepeatChecker::MAX_CHECK_LENGTH
      subsents = sent.split("，")
      tmp = ""
      subsents.each do |subsent|
        l = subsent.size
        if tmp.size+l > RepeatChecker::MAX_CHECK_LENGTH
          handle_check(tmp)
          tmp = subsent
          next
        end

        tmp += "，#{subsent}"
      end

      handle_check(tmp) unless tmp.empty?
      next
    end

    handle_check(sent)
  end

  @full_doc << @ph_res
  sleep 10
end

data = YAML.dump(@full_doc)
File.write("data.yaml", data)
