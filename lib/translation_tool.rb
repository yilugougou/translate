# -*- encoding : utf-8 -*-
# require 'em/pure_ruby'
require 'digest/md5'
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

  def get_tk(q, tkk)
    require "execjs"
    context = ExecJS.compile('''
      function b(a, b) {
        for (var d = 0; d < b.length - 2; d += 3) {
          var c = b.charAt(d + 2)
          c = "a" <= c ? c.charCodeAt(0) - 87 : Number(c)
          c = "+" == b.charAt(d + 1) ? a >>> c : a << c
          a = "+" == b.charAt(d) ? a + c & 4294967295 : a ^ c
        }
        return a
      }
      function tk(TKK, a) {
        for (var e = TKK.split("."), h = Number(e[0]) || 0, g = [], d = 0, f = 0; f < a.length; f++) {
          var c = a.charCodeAt(f);
          128 > c ?
          g[d++] = c : (2048 > c ?
          g[d++] = c >> 6 | 192 : (55296 == (c & 64512) && f + 1 < a.length && 56320 == (a.charCodeAt(f + 1) & 64512) ?
          (c = 65536 + ((c & 1023) << 10) + (a.charCodeAt(++f) & 1023), g[d++] = c >> 18 | 240, g[d++] = c >> 12 & 63 | 128) : g[d++] = c >> 12 | 224, g[d++] = c >> 6 & 63 | 128), g[d++] = c & 63 | 128)
        }
        a = h;
        for (d = 0; d < g.length; d++) a += g[d],a = b(a, "+-a^+6");
        a = b(a, "+-3^+b+-f");
        a ^= Number(e[1]) || 0;
        0 > a && (a = (a & 2147483647) + 2147483648);
        a %= 1E6;
        return a.toString() + "." + (a ^ h)
      }
    ''')
    context.call('tk', tkk.to_s, q)
  end

  def start_google(qss, tl)
    result = ""
    p "qs === #{qss}"
    t = Thread.new do
      tk = get_tk(qss, get_tkk)
      q = URI::escape(qss)
      url = "https://translate.google.cn/translate_a/single?client=webapp&sl=auto&tl=#{tl}&hl=zh-CN&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&source=bh&ssel=0&tsel=0&kc=1&tk=#{tk}&q=#{q}"
      # url = "https://translate.google.cn/translate_a/single"
      p "url ==== #{url}"
      response = HTTParty.post(url)
      if response[0].length > 2
        response[0].each do |res|
          if res[0].present?
            result += res[0]
          end
        end
      else
        result = response[0][0][0]
      end
      # sleep(1)
    end
    t.join
    result.split('||')
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