class String
  REPLACEMENTS = []
  REPLACEMENTS << ["â€¦", "…"]           # elipsis
  REPLACEMENTS << ["â€“", "–"]           # long hyphen
  REPLACEMENTS << ["â€”", "–"]
  REPLACEMENTS << ["â€™", "’"]           # curly apostrophe
  REPLACEMENTS << ["â€œ", "“"]           # curly open quote
  REPLACEMENTS << [/â€[[:cntrl:]]/, "”"] # curly close quote

  def clean
    REPLACEMENTS.each do |replacement|
      self.gsub!(replacement[0], replacement[1])
    end
    self
  end
end
