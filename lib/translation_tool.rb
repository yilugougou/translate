# -*- encoding : utf-8 -*-
require 'em/pure_ruby'
require 'digest/md5'
require 'pry'
class TranslationTool
  def start query
    @result = ''
    url = 'http://api.fanyi.baidu.com/api/trans/vip/translate'
    app_id = '20191215000366378'
    sec_key = 'NFOGBuq8_3gBhrKudO88'
    from = 'auto'
    to = 'fra'
    EventMachine.run {
      salt = rand(10000..99999)
      http = EventMachine::HttpRequest.new(url).post :body => {'q' => query,  'appid' => app_id, 'salt' => salt,
                                                               'from' => from, 'to' => to, 'sign' =>  buildSign(query, app_id, salt, sec_key),
                                                               'Content-Type' => 'application/x-www-form-urlencoded'}
      http.callback {
        @result = JSON.parse(http.response)
        EventMachine.stop
      }
    }
    @result
  end

  def get_tkk
    url = "https://translate.google.cn"
    response = HTTParty.get(url, :headers => {
        "User-Agent":"Mozilla/5.0 (Windows NT 6.1; rv:53.0) Gecko/20100101 Firefox/53.0"
    })
    res = response.body
    res.match('tkk:').post_match.split(',').first.split("'").last
  end

  # def start_google(qss, tk, tl)
  #   tl = 'en'
  #   tk = "920387.571398|650730.1007279|161193.313068|718651.803966|757973.861072"
  #   qss = "你好|朋友|今天|天气|如何"
  #
  #   qs = qss.split('|')
  #   tks = tk.split('|')
  #   results = []
  #   p "qs === #{qs}"
  #   p "tks === #{tks}"
  #   EventMachine.run {
  #     qs.each_with_index do |query, index|
  #       q = URI::escape(query)
  #       # url = "https://translate.google.cn/translate_a/single?client=webapp&sl=auto&tl=#{tl}&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&source=bh&ssel=0&tsel=0&kc=1&tk=#{tks[index]}&q=#{q}"
  #       url = "https://translate.google.cn/translate_a/single"
  #
  #       p "url ==== #{url}"
  #       # response = HTTParty.post(url)
  #       salt = rand(10000..99999)
  #       http = EventMachine::HttpRequest.new(url).post :body => {'salt' => salt, 'client' => 'webapp', 'sl' => 'auto', 'tl'=> tl, 'hl' => 'zh-CN', 'dt' => 'at',
  #                                                                'dt' => 'bd', 'dt' => 'ex', 'dt' => 'ld', 'dt' => 'md', 'dt' => 'qca', 'dt' => 'rw', 'dt' => 'rm',
  #                                                                'dt' => 'ss', 'dt' => 't', 'source' => 'bh', 'ssel' => '0', 'tsel' => '0', 'kc' => '1',
  #                                                                'tk' => tks[index], 'q' => q}
  #       http.callback {
  #         result = ""
  #         response = http.response
  #         if response[0].length > 2
  #           response[0].each do |res|
  #             if res[0].present?
  #               result += res[0]
  #             end
  #           end
  #         else
  #           result = response[0][0][0]
  #         end
  #         results.push(result)
  #         binding.pry
  #         EventMachine.stop
  #       }
  #     end
  #   }
  #   binding.pry
  #   results
  # end


  def b(a, b)
    require "execjs"
    d = 0
    while(d < b.length - 2) do
      b = b.to_s
      c = b[d + 2]
      # c = 'a' <= c ? c[0].ord  - 87 : c.to_i
      if 'a' <= c
        c = c[0].ord  - 87
      else
        c = c.to_i
      end
      # c = '+' == b[d + 1] ? a >> c : a << c
      if '+' == b[d + 1]
        # c = a >> c
        c = ExecJS.eval("#{a} >> #{c}")

      else
        # c = a << c
        c = ExecJS.eval("#{a} << #{c}")
      end
      if '+' == b[d]
        a = a.to_i + c.to_i
      else
        a = a ^ c
      end
      # a = '+' == b[d] ? a.to_i + c.to_i & 4294967295 : a ^ c
      d += 3
    end
    a
  end

  def tk(tkk, a)
    e = tkk.split('.')
    h = e[0].to_i || 0
    g = []
    d = 0
    f = 0
    while(f < a.length) do
      c = a[f].ord
      if 128 > c
        g[d+=1] = c
      else
        if 2048 > c
          g[d+=1] = c >> 6 | 192
        else

          if 55296 == (c & 64512) && f + 1 < a.length && 56320 == (a[f + 1].ord & 64512)
            c = 65536 + ((c & 1023) << 10) + (a[f+=1].ord & 1023)
            g[d+=1] = c >> 18 | 240
            g[d+=1] = c >> 12 & 63 | 128
          else
            g[d+=1] = c >> 12 | 224
            g[d+=1] = c >> 6 & 63 | 128
            g[d+=1] = c & 63 | 128
          end
        end
      end
      f += 1
    end
    g.delete(nil)
    a = h
    while(d < g.length) do
      a += g[d]
      a = b(a, "+-a^+6")
      d+=1
    end
    binding.pry
    a = b(a, "+-3^+b+-f")
    a ^= e[1].to_i || 0
    0 > a && (a = (a & 2147483647) + 2147483648)
    a %= 1E6
    binding.pry
    a.to_i.to_s + "." + (a.to_i ^ h.to_i).to_s
  end

  def start_google(qss, tk, tl)
    # b(439116, "+-3^+b+-f")
    require "execjs"

    binding.pry
    tk('439119.2376008464', '朋友')
    binding.pry
    # tl = 'en'
    # tk = "920387.571398|650730.1007279|161193.313068|718651.803966|757973.861072"
    # qss = "你好|朋友|今天|天气|如何"
    qs = qss.split('|')
    tks = tk.split('|')
    results = []
    p "qs === #{qs}"
    p "tks === #{tks}"
    t = Thread.new do
      qs.each_with_index do |query, index|
        q = URI::escape(query)
        url = "https://translate.google.cn/translate_a/single?client=webapp&sl=auto&tl=#{tl}&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&source=bh&ssel=0&tsel=0&kc=1&tk=#{tks[index]}&q=#{q}"
        # url = "https://translate.google.cn/translate_a/single"

        p "url ==== #{url}"
        response = HTTParty.post(url)
        result = ""
        if response[0].length > 2
          response[0].each do |res|
            if res[0].present?
              result += res[0]
            end
          end
        else
          result = response[0][0][0]
        end
        results.push(result)
      end
      sleep(1)
    end
    t.join
    results
  end

  def start_bing(query)
    # url = "https://cn.bing.com/translator/?h_text=msn_ctxt&setlang=zh-cn"
    #url = "https://translate.google.cn/translate_a/single?client=webapp&sl=auto&tl=en&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=gt&otf=1&ssel=0&tsel=0&kc=1&tk=643372.1008181"
    # q = URI::escape(query)
    # url = "https://translate.google.cn/translate_a/single?client=webapp&sl=auto&tl=en&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dt=gt&pc=1&otf=1&ssel=0&tsel=0&kc=1&tk=108939.465554&q=#{q}"
    # response = HTTParty.get(url)
    # url = "https://google-translate-proxy.herokuapp.com/api/translate"
    url = "https://translate.google.cn"
    # response = HTTParty.post(url, {
    #   :body => {"query": query,"sourceLang": "auto","targetLang": "en"}.to_json
    # })
    # binding.pry

    response = HTTParty.get(url, :headers => {
        "User-Agent":"Mozilla/5.0 (Windows NT 6.1; rv:53.0) Gecko/20100101 Firefox/53.0"
    })
    res = response.body
    res.match('tkk:').post_match.split(',').first.split("'").last
    require 'mechanize'
    Mechanize.start do |agent|
      agent.get(url) do |page|
      end
    end
  end

  def buildSign(query, app_id, salt,  sec_key)
    str = "#{app_id}#{query}#{salt}#{sec_key}"
    Digest::MD5.hexdigest(str)
  end
end