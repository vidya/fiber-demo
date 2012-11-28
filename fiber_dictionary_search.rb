
require 'pry'
require 'fiber'

require './lib_dictionary_search'

class FiberDictionarySearch
  include LibDictionarySearch

  attr_accessor :dict, :fiber_list, :letter_segment, :alphabet_list, :reversible_suffix_words

  def initialize(filename)
    @dict = File.readlines(filename).map { |ln| ln.chomp }
    @alphabet_list    = ('a'..'z').to_a

    @fiber_list = {
        :read_seg           => create_read_segments_fiber(filename),
        :delete_tiny_words  => create_delete_tiny_words_fiber
    }
  end

  def run
    read_seg_fiber            = fiber_list[:read_seg]
    delete_tiny_words_fiber   = fiber_list[:delete_tiny_words]

    first_seg   = read_seg_fiber.resume
    first_seg   = delete_tiny_words_fiber.resume first_seg
    puts 'after first_seg'

    second_seg  = read_seg_fiber.resume
    second_seg  = delete_tiny_words_fiber.resume second_seg
    puts 'after second_seg'

    third_seg   = read_seg_fiber.resume
    third_seg   = delete_tiny_words_fiber.resume third_seg
    puts 'after second_seg'

    [first_seg, second_seg, third_seg]
  end

  #--- fiber: read_segments
  def create_read_segments_fiber(filename)
    dict = File.readlines(filename).map { |ln| ln.chomp }
    let_list    = ('a'..'z').to_a

    Fiber.new do
      let_list.each do |let|
        puts "fiber: create_read_segments_fiber --- let: #{let} --- in let_list loop"
        let_seg = dict.select { |word| word.start_with? let }

        Fiber.yield let_seg
      end
    end
  end

  #--- fiber: delete_tiny_words
  def create_delete_tiny_words_fiber
    Fiber.new do |word_list|
      while true
        puts "fiber: create_delete_tiny_words_fiber --- first_word = #{word_list.first} --- in while not loop"
        result_word_list = word_list.reject { |w| w.size < 3 }

        next_word_list = Fiber.yield result_word_list
        word_list = next_word_list
      end
    end
  end
end


class OldFiberDictionarySearch
  include LibDictionarySearch

  attr_accessor :dict, :letter_segment, :alphabet_list, :reversible_suffix_words

  def initialize(file_path)
    @dict             = read_data file_path

    @alphabet_list    = ('a'..'z').to_a

    @letter_segment   = get_letter_segments

    @reversible_suffix_words = []
  end

  def word_pairs
    if reversible_suffix_words.empty?
      fw1 = create_fiber
      fw2 = create_fiber
      fw3 = create_fiber

      list1 = ('a'..'h').to_a
      list2 = ('i'..'r').to_a
      list3 = ('s'..'z').to_a

      while true
        list1, rv1 = fw1.resume(list1) if fw1.alive?
        list2, rv2 = fw2.resume(list2) if fw2.alive?
        list3, rv3 = fw3.resume(list3) if fw3.alive?

        append_rv_list rv1 unless rv1.nil?
        append_rv_list rv2 unless rv2.nil?
        append_rv_list rv3 unless rv3.nil?

        break unless (rv1 || rv2 || rv3)
      end
    end

    reversible_suffix_words
  end

  #--- private ------------------------------------------------------------------------------
  private
  def read_data(filename)
    File.readlines(filename).map { |ln| ln.chomp }
  end

  def get_letter_segments
    alphabet_list.inject({}) do |let_seg_hash, let|
      let_seg_hash[let] = dict.select { |word| word.start_with? let }

      let_seg_hash
    end
  end

  def append_rv_list(rv_list)
    rv_list.each { |rv| reversible_suffix_words << rv }
  end

  def create_fiber
    Fiber.new do |list|
      until list.empty?
        let = list.pop
        puts "let = #{let}"

        Fiber.yield list[0..-1], select_reversible_suffix_words(delete_tiny_words @letter_segment[let])
      end
    end
  end
end
