# frozen_string_literal: true

require_relative "../test_helper"

module Prism
  class SourceHashTest < TestCase
    def test_returns_unsigned_64_bit_integer
      source_hash = Prism.parse("foo").source_hash

      assert_kind_of Integer, source_hash
      assert_operator source_hash, :>=, 0
      assert_operator source_hash, :<, 2**64
    end

    def test_same_source_gives_same_hash
      source = "if foo\n  bar\nend\n"
      assert_equal Prism.parse(source).source_hash, Prism.parse(source.dup).source_hash

      source = "foo " * 100
      assert_equal Prism.parse(source).source_hash, Prism.parse(source.dup).source_hash
    end

    def test_different_source_gives_different_hash
      refute_equal Prism.parse("foo").source_hash, Prism.parse("bar").source_hash
    end

    def test_ignores_the_data_section
      assert_equal Prism.parse("foo\n__END__\naaa\n").source_hash, Prism.parse("foo\n__END__\nbbb\n").source_hash
      refute_equal Prism.parse("foo\n__END__\naaa\n").source_hash, Prism.parse("bar\n__END__\naaa\n").source_hash
    end

    def test_same_for_all_result_types
      source = "if foo\n  bar\nend\n"
      source_hash = Prism.parse(source).source_hash

      assert_equal source_hash, Prism.lex(source).source_hash
      assert_equal source_hash, Prism.parse_lex(source).source_hash
    end

    def test_parse_file_matches_parse
      assert_equal Prism.parse(File.binread(__FILE__)).source_hash, Prism.parse_file(__FILE__).source_hash
    end

    def test_independent_of_source_encoding
      source = "foo # bär\n"
      assert_equal Prism.parse(source).source_hash, Prism.parse(source.b).source_hash
    end
  end
end
