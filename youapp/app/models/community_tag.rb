class CommunityTag < ActiveRecord::Base
  belongs_to :community
  validates_presence_of :community_id, :tagname
end
