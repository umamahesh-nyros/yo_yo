class InvitedUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :invite

  validates_presence_of :user_id
  validates_presence_of :invite_id
end
