class CachedCommunity < ActiveRecord::Base
  validates_presence_of :name, :community_id, :preferred_parent_id
end
