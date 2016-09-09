class Repositext
  class Utils

    # Utility class to convert numbers to words: 17 => seventeen
    # This is inspired by https://github.com/taimur-akhtar/to_words gem
    class NumberToWordConverter

      UNDER_HUNDRED = {
        0 => "zero",
        1 => "one",
        2 => "two",
        3 => "three",
        4 => "four",
        5 => "five",
        6 => "six",
        7 => "seven",
        8 => "eight",
        9 => "nine",
        10 => "ten",
        11 => "eleven",
        12 => "twelve",
        13 => "thirteen",
        14 => "fourteen",
        15 => "fifteen",
        16 => "sixteen",
        17 => "seventeen",
        18 => "eighteen",
        19 => "nineteen",
        20 => "twenty",
        21 => "twenty one",
        22 => "twenty two",
        23 => "twenty three",
        24 => "twenty four",
        25 => "twenty five",
        26 => "twenty six",
        27 => "twenty seven",
        28 => "twenty eight",
        29 => "twenty nine",
        30 => "thirty",
        31 => "thirty one",
        32 => "thirty two",
        33 => "thirty three",
        34 => "thirty four",
        35 => "thirty five",
        36 => "thirty six",
        37 => "thirty seven",
        38 => "thirty eight",
        39 => "thirty nine",
        40 => "forty",
        41 => "forty one",
        42 => "forty two",
        43 => "forty three",
        44 => "forty four",
        45 => "forty five",
        46 => "forty six",
        47 => "forty seven",
        48 => "forty eight",
        49 => "forty nine",
        50 => "fifty",
        51 => "fifty one",
        52 => "fifty two",
        53 => "fifty three",
        54 => "fifty four",
        55 => "fifty five",
        56 => "fifty six",
        57 => "fifty seven",
        58 => "fifty eight",
        59 => "fifty nine",
        60 => "sixty",
        61 => "sixty one",
        62 => "sixty two",
        63 => "sixty three",
        64 => "sixty four",
        65 => "sixty five",
        66 => "sixty six",
        67 => "sixty seven",
        68 => "sixty eight",
        69 => "sixty nine",
        70 => "seventy",
        71 => "seventy one",
        72 => "seventy two",
        73 => "seventy three",
        74 => "seventy four",
        75 => "seventy five",
        76 => "seventy six",
        77 => "seventy seven",
        78 => "seventy eight",
        79 => "seventy nine",
        80 => "eighty",
        81 => "eighty one",
        82 => "eighty two",
        83 => "eighty three",
        84 => "eighty four",
        85 => "eighty five",
        86 => "eighty six",
        87 => "eighty seven",
        88 => "eighty eight",
        89 => "eighty nine",
        90 => "ninety",
        91 => "ninety one",
        92 => "ninety two",
        93 => "ninety three",
        94 => "ninety four",
        95 => "ninety five",
        96 => "ninety six",
        97 => "ninety seven",
        98 => "ninety eight",
        99 => "ninety nine",
        100 => "one hundred"
      }.freeze

      DIVISIONS = [
        "",
        "thousand",
        "million",
        "billion",
        "trillion",
        "quadrillion",
        "quintrillion"
      ].freeze

      def self.convert(a_number)
        raise ArgumentError.new("Invalid number: #{ a_number.inspect }")  unless a_number.is_a?(Integer)

        num, sign = check_sign(a_number)
        return (sign + UNDER_HUNDRED[num]) if num <= 100

        counter = 0
        result = []

        while num != 0
          num, remaining = num.divmod(1000)
          temp_result = result_below_one_thousand(remaining, counter)
          result << temp_result + " " + DIVISIONS[counter] + " " if temp_result
          counter += 1
        end
        sign + result.reverse.join("").rstrip
      end

      def self.check_sign(num)
        num < 0 ? [num.abs, "negative "] : [num, ""]
      end

      def self.result_below_one_thousand(num, counter)
        hundred, remaining = num.divmod(100)

        return higher_than_hundred(hundred, remaining, counter) if hundred != 0
        UNDER_HUNDRED[remaining] if hundred == 0 && remaining != 0
      end

      def self.higher_than_hundred(hundred, remaining, counter)
        century = UNDER_HUNDRED[hundred]
        if remaining != 0
          return century + " hundred " + UNDER_HUNDRED[remaining] if counter != 0
          return century + " hundred and " + UNDER_HUNDRED[remaining]
        end
        return century + " hundred " if remaining == 0
      end

    end
  end
end
