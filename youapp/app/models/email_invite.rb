class EmailInvite < ActiveRecord::Base
  attr_reader :already

  belongs_to :user
  belongs_to :invite
  
  validates_presence_of :user_id, :invite_id, :email
  validates_format_of :email, :with => EMAIL_VALIDATION, :message => "address seems wrong."

  def self.new_account_invites(email)
    set = EmailInvite.find(:all, :conditions => ['active = ? and email = ?', true, email])
    return false if set.empty?
    none_expired = true
    new_user = User.find_by_email(email)
    set.each do |i|
      a = Invite.find(i.invite_id)
      if a.expired?
        none_expired = false
      end
      old_user = User.find(i.user_id)
      old_user.join_friend(new_user.id)
      new_user.join_friend(old_user.id)
      new_user.join_event(i.invite_id)
      i.update_attribute('active', false)
    end
    return none_expired
  end

  #TODO remove -- part of Invite.publish now
  #def after_create
  #  invite = Invite.find(invite_id)
  #  user = User.find(user_id)
  #  InviteNotifier.deliver_invite(user, email, invite)
  #end

  protected

  def validate
    errors.add(:email, 'already added for this invitation') if EmailInvite.find(:all, :conditions => ['active = ? and email = ? and invite_id = ?', true, email, invite_id]).length > 0 
    dup = User.find(:first, :conditions => ['active = ? and email = ?', true, email])
    unless dup.nil?
      errors.add(:email, 'is your own') if dup.id == user_id
    end
    if errors.empty?
      rec = User.find(:first, :conditions => ['active = ? and email = ? and user_type_id = ?', true, email, 1])
      unless rec.nil?
        @already = rec.id
      end
    end
  end

end
