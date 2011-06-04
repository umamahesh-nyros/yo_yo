class Search < ValidatingBase
 
  validates_length_of :string, :within => 2..255

  attr_accessor	:string
  attr_accessor	:user_id
  attr_reader	:users
  #attr_reader	:communities
  
  def construct
    @search = string
    @users = Array.new
    #@communities = Array.new
    @user_id = user_id
  end

  def validate
    construct
    unless errors.empty?
      return
    end
    ##NOTE perhaps use name_search once cached
    ##res = Community.name_search(@search, @user_id)
    #res = Community.user_search(@search, @user_id)
    #if res.empty?
    #  errors.add_to_base("No communities matched '%s'" % @search)
    #else
    #  @communities = res
    #end
    if @search.split.length > 1
      first, last = @search.split.first, @search.split.last
      users = User.find(:all, 
		    :conditions => ['user_type_id = ? and first_name like ? and last_name like ? and active = ?', 1, "%#{first}%", "%#{last}%", true])
      if users.length == 0
	errors.add_to_base("No such user: #{first} #{last}")
      else
        errors.clear
	@users = users
      end
    else
      #NOTE email
      if EMAIL_VALIDATION.match(@search) 
	users = User.find(:all, :conditions => ['user_type_id = ? and email like ? and active = ?', 1, "%#{@search}%", true])
	if users.length == 0
	  errors.add_to_base("Nobody with that email: #{@search}") 
	else
	  errors.clear
	  @users = users
	end
      #NOTE first name, last name
      else
	string = 'user_type_id = ? and (first_name like ? or last_name like ?) and active = ?'
	users = User.find(:all, :conditions => [string, 1, "%#{@search}%", "%#{@search}%", true])
	#NOTE yotags
	if users.length == 0
	  unless errors.empty?
	    errors.add_to_base("No users matched") 
	  end
=begin
	  string = 'user_type_id = ? and active = ?'
	  users = User.find(:all, :conditions => [string, 1, true])
	  if users.length > 0
	    users = users.select{|f|f.yotag != nil and f.yotag.tag == @search}
	    if users.length > 0
	      errors.clear
	      @users = users
	    else
	      errors.add_to_base("No users matching: %s" % @search) 
	    end
	  else
	    errors.add_to_base("No users") 
	  end
=end
	else
	  errors.clear
	  @users = users
	end
      end
    end
  end

end
