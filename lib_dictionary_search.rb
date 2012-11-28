
require 'pry'

module LibDictionarySearch
  def delete_tiny_words(word_list)
    word_list.reject { |word| word.size <= 2 }
  end

  def select_reversible_suffix_words(word_list)
    word_list.inject([]) do |list, word|
      rev_word = word[0..-3] + word[-2, 2].reverse

      list << [word, rev_word] if (word < rev_word) && (word_list.include? rev_word) && (not rev_word.eql? word)

      list
    end
  end
end
