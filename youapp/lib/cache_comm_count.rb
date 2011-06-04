class CacheCommCount
  def initialize
    @list = Community.find(:all, :conditions => ['active = ?',true])
    return nil if @list.empty?
    out_with_old
    in_with_new
    true
  end
  def out_with_old
    CachedPopulaceCommunity.find(:all, :conditions => ['active = ?',true]).each{|comm| comm.update_attribute(:active,false)}
  end
  def in_with_new
    comm = Array.new
    @list.each do |c|
      if Community.all_child_users(c.id).length > 0
        comm << [c.id, Community.all_child_users(c.id).length]
      else
        comm << [c.id, Community.standard_users(c.id).length]
      end
    end
    CachedPopulaceCommunity.transaction do
      comm.each do |iteration|
        CachedPopulaceCommunity.create({:community_id => iteration[0], :population => iteration[1]})
      end
    end
  end
end

