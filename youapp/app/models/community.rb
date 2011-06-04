#TODO REMOVE require 'digest/sha1'
class Community < ActiveRecord::Base

  attr_reader :err

  belongs_to :community_type
  has_one    :cached_populace_count, :class_name => 'CachedPopulaceCommunity', :conditions => 'cached_populace_communities.active = true'
  has_many   :community_assigns, :conditions => 'community_assigns.active = true'
  has_many   :users, :through => :community_assigns, :conditions => 'users.active = true and users.user_type_id = 1'
  has_many   :tags, :class_name => 'CommunityTag', :conditions => 'community_tags.active = true'

  validates_presence_of :name
 
  def user_count
    begin
      self.cached_populace_count.population
    rescue
      0
    end
  end

  #NOTE old uncached version
  def self.old_name_search(string, user_id)
    user = User.find(user_id)
    set = user.preferred_communities
    return Array.new if set.empty?
    matches = Array.new
    cluster = set.collect{|sp|sp.all_childs}
    cluster.each do |children|
      for child in children
        begin 
          matches << child if child.name =~ Regexp.new(string,true)
	rescue RegexpError
	  return Array.new
	end
	child.tags.each do |tag|
          matches << tag.community if tag.tagname =~ Regexp.new(string,true)
	end
      end
    end
    return matches.uniq
  end

  def self.name_search(string, user_id)
    user = User.find(user_id)
    set = user.preferred_communities
    return Array.new if set.empty?
    matches = Array.new
    ##TODO move to user model
    if set.length > 1
      cond = ['preferred_parent_id IN (?)',set.collect(&:id)]
    else
      cond = ['preferred_parent_id = ?',set.collect(&:id)]
    end
    cluster = CachedCommunity.find(:all, :conditions => cond)
    cluster.each do |comm|
      begin 
	matches << comm.community_id if comm.name =~ Regexp.new(string,true)
      rescue RegexpError
	return Array.new
      end
    end
    return Community.find(matches.uniq)
  end

  def self.user_search(string, user_id)
    user = User.find(user_id)
    set = user.communities
    return Array.new if set.empty?
    matches = Array.new
    for comm in set
      begin 
	matches << comm if comm.name =~ Regexp.new(string,true)
      rescue RegexpError
	return Array.new
      end
      comm.tags.each do |tag|
	matches << tag.community if tag.tagname =~ Regexp.new(string,true)
      end
    end
    return matches.uniq
  end
  
  def self.good_hash?(hash)
    comm = Community.find(:first, :conditions => ['active = ? and hashed_name = ?', true, hash])
    return false if comm.nil? or comm.parents.empty?
    comm.parents << comm
  end

  def parents
    heap = Array.new
    return heap if self.parent.to_s.empty?
    next_parent_id = self.parent
    loop do
      begin
        parent = Community.find(next_parent_id, :conditions => ['active = ?', true])
      rescue
        return heap.reverse
      end
      heap << parent
      if parent.parent.to_s.empty?
        return heap.reverse
      else
        next_parent_id = parent.parent
      end
    end
  end
 
  def self.taggify(comm_id, string)
    return if string == String.new
    set = string.split(',').collect{|t|t if t.strip != String.new}.compact
    CommunityTag.transaction do
      set.each do |t|
        CommunityTag.create({:tagname => t, :community_id => comm_id})
      end
    end
  end

  def self.standard_users(id, banned = Array.new)
    Community.find(id).users.collect{|u| u unless banned.include?(u.id)}.compact
  end

  def self.all_child_users(id, banned = Array.new)
    begin
      users = User.find(Community.find(id).all_childs.collect{|c|c.users}.compact)
    rescue 
      users = Array.new
    end
    users.collect{|a| a unless banned.include?(a.id)}.compact
  end
   
  def admin_childs
    Community.find(:all, :conditions => ['parent = ? and active = ?', self.id, true])
  end

  def all_childs
    childs = Array.new
    already = Array.new
    done = false
    max = 10
    new_ids = [id]
    until done do
      search = Community.find(new_ids).collect{|c|c.child_ids}.flatten
      if search.empty?
        done = true
      else
        childs << Community.find(search)
        new_ids = search
      end
    end
    childs.flatten
  end

  def child_ids
    Community.find(:all, :conditions => ['active = ? and parent = ?', true, self.id]).collect(&:id)
  end

  #----------------------------------------------
  # Protected methods
  #----------------------------------------------
  
  protected

  def before_create
    self.hashed_name = encrypted_name
  end

  #----------------------------------------------
  # Private methods
  #----------------------------------------------

  private

  def encrypted_name
    #TODO remove hash version
    #Digest::SHA1.hexdigest(created_at.to_i.to_s)
    created_at.to_i.to_s(36)
  end

end
