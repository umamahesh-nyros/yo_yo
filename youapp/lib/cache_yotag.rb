class CacheYotag

  attr_reader :set

  def initialize
    @set = create_new_set
  end

  def create_new_set
    slice_yywt(clean_set)
  end

  def clean_set
    set = Array.new
    ('AAAA').upto('ZZZZ') {|x| set << x}
    return set
  end

  def slice_yywt(set)
    set.slice!(set.index("YYWT")) 
    return set
  end

end
