require 'pry'
require 'fiber'

class FiberDictionarySearch
  attr_accessor :word_pairs

  def initialize(filename)
    puts "=== swift pelican ==========="

    @word_pairs = compute_word_pairs(filename)
  end

  #---------------------------------------------------------------------------------------
  private
  def compute_word_pairs(filename)
    read_seg_fiber             = create_read_segments_fiber(filename)
    delete_short_words_fiber   = create_delete_short_words_fiber
    tail_swap_pairs_fiber      = create_tail_swap_pairs_fiber
    
    tail_swap_pairs = []

    while read_seg_fiber.alive?
      word_list            = read_seg_fiber.resume
      word_list            = delete_short_words_fiber.resume(word_list)

      swap_pairs = tail_swap_pairs_fiber.resume(word_list)
      swap_pairs.each { |pair| tail_swap_pairs << pair }
    end

    tail_swap_pairs
  end

  #--- fiber: read_segments
  def create_read_segments_fiber(filename)
    Fiber.new do
      all_words = File.readlines(filename).map { |ln| ln.chomp }

      ('a'..'z').each do |letter|
        puts "let: #{letter}"

        letter_words = all_words.select { |word| word.start_with? letter }

        Fiber.yield(letter_words)
      end
    end
  end

  #--- fiber: delete_short_words
  def create_delete_short_words_fiber
    Fiber.new do |word_list|
      while true
        long_words  = word_list.reject { |w| w.size < 3 }

        next_word_list  = Fiber.yield(long_words)
        word_list       = next_word_list
      end
    end
  end

  #-- fiber: list_tail_swap_pairs
  def create_tail_swap_pairs_fiber
    Fiber.new do |word_list|
      while true
        tail_swap_pairs = []

        word_list.each do |word|
          rev_word = word[0..-3] + word[-2, 2].reverse

          if (word < rev_word)  && (not rev_word.eql? word)
            tail_swap_pairs << [word, rev_word] if (word_list.include? rev_word)
          end
        end

        next_word_list  = Fiber.yield(tail_swap_pairs)
        word_list       = next_word_list
      end
    end
  end
end
