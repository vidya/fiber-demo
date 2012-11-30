require 'pry'
require 'fiber'

class FiberDictionarySearch
  attr_accessor :word_pairs

  def initialize(filename)
    puts "=== crane ==========="

    @word_pairs = compute_word_pairs(filename)
  end

  #---------------------------------------------------------------------------------------
  private
  def compute_word_pairs(filename)
    read_seg_fiber             = create_read_segments_fiber(filename)
    delete_short_words_fiber   = create_delete_short_words_fiber
    tail_swap_pairs_fiber      = create_tail_swap_pairs_fiber
    
    tail_swap_pairs_list = []

    while read_seg_fiber.alive?
      dict_seg            = read_seg_fiber.resume
      dict_seg            = delete_short_words_fiber.resume dict_seg

      #tail_swap_pairs     = tail_swap_pairs_fiber.resume dict_seg

      #tail_swap_pairs.each { |sw_pair| tail_swap_pairs_list << sw_pair }
      tail_swap_pairs_fiber.resume(dict_seg).each { |sw_pair| tail_swap_pairs_list << sw_pair }
    end

    tail_swap_pairs_list
  end

  #--- fiber: read_segments
  def create_read_segments_fiber(filename)
    Fiber.new do
      dict = File.readlines(filename).map { |ln| ln.chomp }

      ('a'..'z').each do |let|
        puts "let: #{let}"

        let_seg = dict.select { |word| word.start_with? let }

        Fiber.yield let_seg
      end
    end
  end

  #--- fiber: delete_short_words
  def create_delete_short_words_fiber
    Fiber.new do |word_list|
      while true
        long_word_list  = word_list.reject { |w| w.size < 3 }

        next_word_list  = Fiber.yield long_word_list
        word_list       = next_word_list
      end
    end
  end

  #-- fiber: list_tail_swap_pairs
  def create_tail_swap_pairs_fiber
    Fiber.new do |word_list|
      while true
        tail_swap_pairs = []

        word_list.inject(tail_swap_pairs) do |list, word|
          rev_word = word[0..-3] + word[-2, 2].reverse

          list << [word, rev_word] if (word < rev_word) && (word_list.include? rev_word) && (not rev_word.eql? word)

          list
        end

        next_word_list  = Fiber.yield tail_swap_pairs
        word_list       = next_word_list
      end
    end
  end
end
