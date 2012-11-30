
require 'pry'
require 'fiber'

class FiberDictionarySearch
  attr_accessor :fiber_list, :tail_swap_pairs_list

  def initialize(filename)
    @tail_swap_pairs_list  = []

    @fiber_list = {
        :read_seg             => create_read_segments_fiber(filename),
        :delete_short_words   => create_delete_short_words_fiber,
        :tail_swap_pairs      => create_tail_swap_pairs_fiber
    }
  end


  def word_pairs
    if @tail_swap_pairs_list.empty?
      read_seg_fiber              = fiber_list[:read_seg]
      delete_short_words_fiber    = fiber_list[:delete_short_words]
      tail_swap_pairs_fiber       = fiber_list[:tail_swap_pairs]

      while read_seg_fiber.alive?
        dict_seg      = read_seg_fiber.resume
        dict_seg      = delete_short_words_fiber.resume dict_seg

        tail_swap_pairs    = tail_swap_pairs_fiber.resume dict_seg

        tail_swap_pairs.each { |sw_pair| @tail_swap_pairs_list << sw_pair }
      end
    end

    @tail_swap_pairs_list
  end

  #--- fiber: read_segments
  def create_read_segments_fiber(filename)
    dict        = File.readlines(filename).map { |ln| ln.chomp }
    let_list    = ('a'..'z').to_a

    Fiber.new do
      let_list.each do |let|
        puts "create_read_segments_fiber: #{let}"

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
