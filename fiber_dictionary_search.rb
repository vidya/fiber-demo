
require 'pry'
require 'fiber'

class FiberDictionarySearch
  attr_accessor :dict, :fiber_list, :reversible_suffix_words

  def initialize(filename)
    @dict = File.readlines(filename).map { |ln| ln.chomp }
    @alphabet_list    = ('a'..'z').to_a

    @fiber_list = {
        :read_seg             => create_read_segments_fiber(filename),
        :delete_short_words   => create_delete_short_words_fiber,
        :tail_swap_pairs      => create_tail_swap_pairs_fiber
    }
  end

  def run
    read_seg_fiber              = fiber_list[:read_seg]
    delete_short_words_fiber    = fiber_list[:delete_short_words]
    tail_swap_pairs_fiber       = fiber_list[:tail_swap_pairs]

    swap_pairs_list = []
    while read_seg_fiber.alive?
      dict_seg      = read_seg_fiber.resume
      dict_seg      = delete_short_words_fiber.resume dict_seg

      swap_pairs    = create_tail_swap_pairs_fiber.resume dict_seg
      swap_pairs.each { |sw_pair| swap_pairs_list << sw_pair }
    end

    binding.pry
    swap_pairs_list
  end


  #--- fiber: read_segments
  def create_read_segments_fiber(filename)
    dict        = File.readlines(filename).map { |ln| ln.chomp }
    let_list    = ('a'..'z').to_a

    Fiber.new do
      let_list.each do |let|
        puts "fiber: create_read_segments_fiber --- let: #{let} --- in let_list loop"

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
        swap_pairs = word_list.inject([]) do |list, word|
          rev_word = word[0..-3] + word[-2, 2].reverse

          list << [word, rev_word] if (word < rev_word) && (word_list.include? rev_word) && (not rev_word.eql? word)

          list
        end

        next_word_list  = Fiber.yield swap_pairs
        word_list       = next_word_list
      end
    end
  end
end
