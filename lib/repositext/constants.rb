class Repositext

  APOSTROPHE = "’"
  D_QUOTE_CLOSE = "”"
  D_QUOTE_OPEN = "“"
  ELIPSIS = "…"
  EM_DASH = "—"
  S_QUOTE_CLOSE = "’"
  S_QUOTE_OPEN = "‘"

  ALL_TYPOGRAPHIC_CHARS = [
    APOSTROPHE,
    D_QUOTE_CLOSE,
    D_QUOTE_OPEN,
    ELIPSIS,
    EM_DASH,
    S_QUOTE_CLOSE,
    S_QUOTE_OPEN,
  ]

  # We use this character to delimit sentences, e.g., in Lucene exported plain
  # text proximity
  # 0x256B - Box Drawings Vertical Double And Horizontal Single
  SENTENCE_DELIMITER = "╫"
  SENTENCE_TERMINATOR_CHARS = ['.', '!', '?']

  US_STATES = {
    'AK' => 'Alaska',
    'AL' => 'Alabama',
    'AR' => 'Arkansas',
    'AS' => 'American Samoa',
    'AZ' => 'Arizona',
    'CA' => 'California',
    'CO' => 'Colorado',
    'CT' => 'Connecticut',
    'DC' => 'District of Columbia',
    'DE' => 'Delaware',
    'FL' => 'Florida',
    'GA' => 'Georgia',
    'GU' => 'Guam',
    'HI' => 'Hawaii',
    'IA' => 'Iowa',
    'ID' => 'Idaho',
    'IL' => 'Illinois',
    'IN' => 'Indiana',
    'KS' => 'Kansas',
    'KY' => 'Kentucky',
    'LA' => 'Louisiana',
    'MA' => 'Massachusetts',
    'MD' => 'Maryland',
    'ME' => 'Maine',
    'MI' => 'Michigan',
    'MN' => 'Minnesota',
    'MO' => 'Missouri',
    'MS' => 'Mississippi',
    'MT' => 'Montana',
    'NC' => 'North Carolina',
    'ND' => 'North Dakota',
    'NE' => 'Nebraska',
    'NH' => 'New Hampshire',
    'NJ' => 'New Jersey',
    'NM' => 'New Mexico',
    'NV' => 'Nevada',
    'NY' => 'New York',
    'OH' => 'Ohio',
    'OK' => 'Oklahoma',
    'OR' => 'Oregon',
    'PA' => 'Pennsylvania',
    'PR' => 'Puerto Rico',
    'RI' => 'Rhode Island',
    'SC' => 'South Carolina',
    'SD' => 'South Dakota',
    'TN' => 'Tennessee',
    'TX' => 'Texas',
    'UT' => 'Utah',
    'VA' => 'Virginia',
    'VI' => 'Virgin Islands',
    'VT' => 'Vermont',
    'WA' => 'Washington',
    'WI' => 'Wisconsin',
    'WV' => 'West Virginia',
    'WY' => 'Wyoming',
  }

end
