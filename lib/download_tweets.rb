require 'rubygems'
require 'nokogiri'
require 'typhoeus'
require 'json'
require 'pry'
require 'pry-debugger'

input, output = ARGV

cache = {}

File.open(output, 'w') do |file|
File.foreach(input) do |line|
  fields = line.rstrip.split("\t")
  sid, uid = fields

  tweet = nil
  text = 'Not Available'

  if cache.has_key?(sid)
    text = cache[sid]
  else
    begin
      url = "https://twitter.com/#{uid}/status/#{sid}"
      page = Nokogiri::HTML(Typhoeus.get(url).body)

      tweets = page.css('p.js-tweet-text').map(&:content).uniq
      p tweets
      next if tweets.length != 1

      text = tweets[0].strip
      p text
      cache[sid] = tweets[0]

      page.css('input.json-data#init-data').each do |j|
        js = JSON(j.attributes['value'].value)
        if js && js.has_key?('embedData')
          tweet = js["embedData"]["status"]
          text  = js["embedData"]["status"]["text"]
          cache[sid] = text
          break
        end
      end
    end
  end

  if tweet != nil && tweet['id_str'] != sid
    text = "Not Available"
    cache[sid] = "Not Available"
  end

  next if fields.length == 0
  fields.delete_at(2)
  text = text.gsub(/\s+/, ' ')
  file.write (fields << text).join("\t") + "\n"
end
end
