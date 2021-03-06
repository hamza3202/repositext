# -*- coding: utf-8 -*-
require_relative '../helper'

describe String do

  let(:s) { "word1 word2 word3 word4 word5 word6 word7" }

  describe '#split_into_two' do
    [
      [
        'Default case',
        'word1 word2 word3',
        ['word1 ', 'word2 word3']
      ],
      [
        'No word boundaries',
        'word1word2word3word4',
        ["word1word2word3word4", ""]
      ],
      [
        'With punctuation at boundary',
        'word1 word2. word3 word4 word5.',
        ["word1 word2. ", "word3 word4 word5."]
      ],
      [
        'Single word',
        'word',
        ["word", ""]
      ],
      [
        'Empty string',
        '',
        ["", ""]
      ],
      [
        'Single subtitle mark',
        '@',
        ["@", ""]
      ],
      [
        'HTML encoded char',
        'word &#x8820; word',
        ["word ", "&#x8820; word"]
      ],
      [
        "Split point in front of space",
        "word word word word",
        ['word word ', 'word word']
      ],
      [
        "Multibyte chars",
        "word òé af word word",
        ['word òé ', 'af word word']
      ],
    ].each do |description, test_string, xpect|
      it "handles #{ description }" do
        test_string.split_into_two.must_equal(xpect)
      end
    end
  end

  describe '#truncate_in_the_middle' do
    [
      [[5], "wor [...] d7"],
      [[1_000], "word1 word2 word3 word4 word5 word6 word7"],
    ].each do |(args, xpect)|
      it "handles args #{ args.inspect }" do
        s.truncate_in_the_middle(*args).must_equal(xpect)
      end
    end
  end

  describe '#truncate_from_beginning' do
    [
      [[5], "…ord7"],
      [[1_000], "word1 word2 word3 word4 word5 word6 word7"],
      [[5, omission: '%%%'], "%%%d7"],
      [[20, separator: ' '], "…word5 word6 word7"],
      [[11, separator: ' ', omission: ''], "word6 word7"],
      [[20, separator: 'x'], "…4 word5 word6 word7"],
    ].each do |(args, xpect)|
      it "handles args #{ args.inspect }" do
        s.truncate_from_beginning(*args).must_equal(xpect)
      end
    end
  end

  describe '#unicode_downcase' do
    [
      ["WORD", "word"],
      ["WÊRD", "wêrd"],
    ].each do |test_string, xpect|
      it "handles #{ test_string.inspect }" do
        test_string.unicode_downcase.must_equal(xpect)
      end
    end
  end

  describe '#unicode_upcase' do
    [
      ["word", "WORD"],
      ["wêrd", "WÊRD"],
    ].each do |test_string, xpect|
      it "handles #{ test_string.inspect }" do
        test_string.unicode_upcase.must_equal(xpect)
      end
    end
  end

end
