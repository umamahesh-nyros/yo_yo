class CachePreferred
  attr_reader :preferred
  def initialize
    @preferred = Community.find(:all, :conditions => ['regex_email is not ? and regex_email != ? and active = ?', nil, String.new,true])
    return nil if @preferred.empty?
    out_with_old
    in_with_new
    true
  end
  def out_with_old
    CachedCommunity.find(:all, :conditions => ['active = ?',true]).each{|comm| comm.update_attribute(:active,false)}
  end
  def in_with_new
    comm = Array.new
    cluster = @preferred.collect{|sp|[sp.id,sp.all_childs]}
    CachedCommunity.transaction do
      cluster.each do |iteration|
	sp = iteration[0]
	for child in iteration[1]
	  for tag in child.tags
	    CachedCommunity.create({:name => tag.tagname, :community_id => tag.community_id, :preferred_parent_id => sp})
	  end
	  CachedCommunity.create({:name => child.name, :community_id => child.id, :preferred_parent_id => sp})
	end 
      end
    end
  end
end
