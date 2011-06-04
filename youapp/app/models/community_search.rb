class CommunitySearch < ValidatingBase

  validates_length_of :string, :within => 2..255

  attr_accessor	:string
  attr_accessor	:user_id
  attr_reader	:results
  
  def construct
    @results = Array.new
    @search = string
    @user_id = user_id
  end

  def validate
    construct
    res = Community.name_search(@search, @user_id)
    if res.empty?
      errors.add_to_base("No matches found for '%s'" % @search)
    else
      @results = res
    end
  end

end
