require 'rubygems'
require 'set'
require 'lingua/stemmer'

StopWords = %w{a able about across after all almost also am among an and any are as at be because been but by can cannot could dear did do does either else ever every for from get got had has have he her hers him his how however i if in into is it its just least let like likely may me might most must my neither no nor not of off often on only or other our own rather said say says she should since so some than that the their them then there these they this tis to too twas us wants was we were what when where which while who whom why will with would yet you your}

words_bag = Set.new []
total_num = 0

input, output, words_file = ARGV

File.open(output, 'w') do |file|
  File.foreach(input) do |line|
    data = line.split("\t")
    next if data.length != 4
    text = data[3].downcase.gsub(/https?:\/\/\S+/, '')
    text_arr = text.split(/\W+/).select { |word| word =~ /^[a-zA-Z]/ }
    .map do |word|
      word.gsub(/(\w)\1+/, '\1\1')
    end
    .reject do |word|
      StopWords.include? word
    end
    .map do |word|
      Lingua.stemmer(word)
    end
    total_num += text_arr.length
    words_bag.merge text_arr
    data[3] = text_arr.join(' ')
    file.write(data.join("\t") + "\n") if text_arr.length > 0
  end
end
p total_num
File.open(words_file, 'w') do |file|
  words_bag.each do |word|
    file.write(word + "\n")
  end
end
