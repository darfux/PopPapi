require 'net/http'
require "nokogiri"
require "pry"

class String
  def word_count
    en_word = self.scan(/[a-zA-Z0-9\_\.\/\-\{\}\:]+/).size
    zh_cha = self.scan(/\p{Han}/).size

    punctuation = self.scan(/[，。（）]/).size
    en_word + zh_cha + punctuation
  end
end

class RepeatChecker
  MIN_REPEAT_NUM = 13
  MAX_CON_TEXT_LEN = 4
  MAX_CHECK_LENGTH = 38

  def initialize(dir="default")
    @counter = 0
    @dir = "tmp/#{dir}"

    if Dir.exists? @dir
      puts "Warning, output directory #{@dir} already exists."
    else
      Dir.mkdir(@dir)
    end
  end

  def check(sentence)
    return false if sentence.chomp.strip.empty?
    doc = Nokogiri::HTML(search(sentence))

    res_items = doc / '.resitem'

    # p res_items.size

    repeat_res = []
    res_items.each do |ri|
      rtabs = ri / '.result_title_abs'

      ret = process_rtabs(rtabs)
      repeat_res << ri if ret
    end


    return false if repeat_res.empty?


    File.open "#{@dir}/#{@counter}.html", "w" do |f|
      #f.puts "<style>em{color: red;} div{text-decoration: none;}</style>"
      repeat_res.each do |res|
        f.puts process_res(res)
      end
    end

    ret = @counter
    @counter+=1

    ret
  end
private
  def search(kw)
    # return File.read("example.html")

    url = "https://m.baidu.com/pu=sz%401321_1001/s"

    key_word = kw
    uri = URI(url)

    params = { :word => key_word }
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)

    unless res.is_a?(Net::HTTPSuccess)
      p res
      raise "Net Error"
    end

    res.body
  end

  def check_repeat(pdar)
    pdar.collect{ |e| e.text }.join.word_count >= MIN_REPEAT_NUM
  end

  def process_rtabs(v)
    itor = v.children.to_a.each

    pending_em = nil
    pre = nil
    pending_ar = []
    loop do
      c = itor.next


      case c.name
      when "text"
        next unless pre == :em
        pre == :text
        if c.text.size <= MAX_CON_TEXT_LEN
          pending_ar << c
        else
          flag = check_repeat(pending_ar)
          return true if flag
          pending_ar = []
        end
      when "em"
          pending_ar << c
          pre = :em
      end

    end

    check_repeat(pending_ar)
  end

  def process_res(res)
    # binding.pry
    res
  end

end



# p str
