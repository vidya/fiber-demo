require 'pry'

require 'minitest/autorun'
require './fiber_dictionary_search'

class TestDictionarySearch < MiniTest::Unit::TestCase
  attr_accessor :dict_search

  def setup
    @dict_search = FiberDictionarySearch.new('wordsEn.txt')
  end

  def test_that_dictionary_is_available
    dict = @dict_search.dict

    refute_empty dict, '--- error: dictionary is not available'
  end

  def test_that_first_segment_is_available
    puts "test: test_that_first_segment_is_available"
    first_seg = @dict_search.run.first
    assert first_seg.size > 6000
  end

  def test_that_second_segment_is_available
    puts "test: test_that_second_segment_is_available"
    seg_list = @dict_search.run
    second_seg = seg_list[1]
    assert second_seg.size > 6000
  end

  def test_that_third_segment_is_available
    puts "test: test_that_third_segment_is_available"
    seg_list = @dict_search.run
    third_seg = seg_list[2]
    assert third_seg.size > 8000
  end

  def test_that_segment_a_has_no_tiny_words
    seg_list = @dict_search.run
    seg_a = seg_list[0]
    dirty_seg_a = seg_a.select { |w| w.size < 3 }
    #binding.pry
    dirty_seg_a.must_be_empty
  end
  #---------------------------------------------
  #def test_that_dictionary_is_split_into_segments
  #  letter_segment_keys = dict_search.letter_segment.keys
  #
  #  assert_equal letter_segment_keys, ('a'..'z').to_a, '--- error: unexpected letter segment keys'
  #end
  #
  #def test_select_reversible_suffix_words
  #  rev_words = dict_search.select_reversible_suffix_words ['abc', 'acb', 'man']
  #  assert_equal [['abc', 'acb']], rev_words, '--- error: cannot select reversible suffix words'
  #
  #  rev_words = dict_search.select_reversible_suffix_words ['abc', 'acb', 'man', 'mna']
  #  assert_equal [['abc', 'acb'], ['man', 'mna']], rev_words, '--- error: cannot select reversible suffix words'
  #
  #  rev_words = dict_search.select_reversible_suffix_words ['abc', 'acb', 'man', 'mna', 'bee']
  #  assert_equal [['abc', 'acb'], ['man', 'mna']], rev_words, '--- error: cannot select reversible suffix words'
  #end
end

