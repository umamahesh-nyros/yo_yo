require 'digest/sha1'
class User < ActiveRecord::Base

  attr_accessor	:password_confirmation
  attr_reader :err

  has_and_belongs_to_many  :friends, 
                                :class_name => 'User', 
                                :join_table => 'user_assigns', 
                                :foreign_key => 'user_alpha_id',
                                :association_foreign_key => 'user_beta_id',
                                :select => 'users.yotag_id, users.email, users.id, users.first_name, 
                                  users.last_name, user_assigns.id as assigns_id, user_assigns.created_at as assigns_created_at, 
                                  user_assigns.updated_at as assigns_updated_at, users.phone, users.college_id, users.sex_id, users.active',
                                :conditions => 'user_assigns.active = true and users.active = true'

  has_one  :photo
  has_one  :preference, :class_name => 'UserPreference'
  has_many :email_invites, :conditions => 'email_invites.active = true'
  has_many :community_assigns, :conditions => 'community_assigns.active = true'
  has_many :communities, :through => :community_assigns, :conditions => 'communities.active = true'
  has_many :invites, :conditions => 'invites.active = true', :order => 'invites.id DESC'#TODO
  has_many :past_invites, 
           :class_name => 'Invite',
           :conditions => 'invites.expires_at is not NULL'
  has_many :invited_users
  #TODO dont include if count(invited_users) >= invites.maximum
  #Helper -- for now skips these cases
  has_many :invitations,
           :through => :invited_users,
           :class_name => 'Invite',
           :source => 'invite',
           :conditions => 'invited_users.active = true and invites.active = true and invites.expires_at > now()'
  belongs_to :user_type
  belongs_to :college
  belongs_to :sex
  belongs_to :yotag
  
  validates_presence_of :terms

  validates_confirmation_of :password,
                            :on => :create
  validates_presence_of   :password, 
                          :on => :create

  validates_presence_of	  :password_confirmation,
                          :on => :create

  validates_length_of	  :password, 
                          :on => :create,
			  :minimum => 5,
			  :message => "needs to have a minimum of 5 characters"
  
  validates_presence_of :first_name,
                        :user_type_id,
			:email
	
  validates_uniqueness_of :email
  validates_format_of :email, :with => EMAIL_VALIDATION, :message => "address seems wrong."

  validates_length_of	:last_name, :within => 2..30, :on => :update, :allow_nil => true
  validates_length_of	:first_name, :within => 1..30

  def name
    ("%s %s" % [first_name,last_name]).strip
  end

  def prefs
    pref = self.preference
    return pref unless pref.nil?
    #UserPreference.create({:user_id => self.id})
    prefs = {:times_up => false, :afirm_out => false, :invite_in => false, :user_id => self.id} 
    UserPreference.create(prefs)
  end

  def preferred_communities
    out = Array.new
    set = Community.find(:all, :conditions => ['regex_email is not ? and regex_email != ?', nil, String.new])
    set.each do |comm|
      if self.email =~ Regexp.new(comm.regex_email)
        out << comm
      end
    end
    out
  end

  def emailed_users(invite_id)
    self.email_invites.find_all{|e|e.invite_id == invite_id}
  end

  def confirm_invite(invite_id)
    begin
      check = Invite.find(invite_id, :conditions => ['active = ?', true])
    rescue => e
      @err = 'No such invitation exists'
      return false
    end
    unless check.expires_at.nil?
      if Time.new > check.expires_at
        @err = 'Invitation has expired'
        return false 
      end
    else
      @err = 'This invite is pending'
      return false
    end
    cnt = check.invited_users.collect{|u| u if u.confirmed }.compact.length
    if check.maximum_users <= cnt
      @err = 'Invitation is closed'
      return false 
    end
    event = check.invited_users.detect {|e| (e.user_id == self.id) and !e.confirmed}
    if event.nil?
      @err = 'Cannot confirm more than once, can only cancel'
      return false
    end
    event.update_attribute('confirmed', true)
    if self.prefs.afirm_out
      InviteNotifier.deliver_confirmation(self, check)
    end
    check
  end

  def unconfirm_invite(invite_id)
    begin
      check = Invite.find(invite_id, :conditions => ['active = ?', true])
    rescue => e
      @err = 'No such invitation exists'
      return false
    end
    event = check.invited_users.detect {|e| (e.user_id == self.id) and e.confirmed}
    if event.nil?
      @err = 'Cannot cancel more than once'
      return false
    end
    event.update_attribute('confirmed', false)
    if self.prefs.afirm_out
      InviteNotifier.deliver_unconfirmation(self, check)
    end
    check
  end

  def kill_invite(invite_id)
    begin
      check = Invite.find(invite_id, :conditions => ['active = ?', true])
    rescue => e
      @err = 'No such invitation exists'
      return false
    end
    event = check.invited_users.detect {|e| (e.user_id == self.id) and e.active}
    if event.nil?
      @err = 'Cannot kill more than once'
      return false
    end
    event.update_attribute('active', false)
    check
  end

  def join_event(invite_id)
    begin
      check = Invite.find(invite_id, :conditions => ['active = ?', true])
    rescue => e
      @err = 'No such invitation is live'
      return false
    end
    if check.user_id == id
      @err = 'Cannot join your own invitation'
      return false 
    end
    cnt = InvitedUser.find(:all, :conditions => ['invite_id = ? and active = ? and user_id = ?',invite_id, true, id]).length
    if cnt > 0
      @err = 'Cannot repeat invitation'
      return false 
    end
    begin 
      old = InvitedUser.find(:first, :conditions => ['invite_id = ? and user_id = ? and active = ?',invite_id, id, false])
      old.update_attribute('active', true)
    rescue
      InvitedUser.create(:user_id => id, :invite_id => invite_id, :active => true)
    end
  end

  def unjoin_event(invite_id)
    event = InvitedUser.find(:first, :conditions => ['invite_id = ? and user_id = ?', invite_id, id])
    if event.nil?
      @err = 'User not associated'
      return false
    else
      event.update_attribute('active',false)
    end
  end

  def join_friend(user_id)
    begin
      check = User.find(user_id, :conditions => ['active = ?', true])
    rescue => e
      @err = 'No such friend'
      return false
    end
    if check.id == id
      @err = 'Cannot add yourself'
      return false 
    end
    if self.friends.collect(&:id).include?(check.id)
      @err = 'Cannot add friend more than once'
      return false 
    end
    #self.friends << check
    hash = {:user_alpha_id => self.id, :user_beta_id => check.id, :active => true}    
    UserAssign.create(hash)
  end

  def unjoin_friend(user_id)
    begin
      self.friends.find(user_id)
    rescue
      @err = 'User not associated'
      return false
    end
    #TODO make better
    UserAssign.find(:first, :conditions => ['user_alpha_id = ? and user_beta_id = ?', self.id, user_id]).update_attribute('active', false)
  end

  def join_community(comm_id, hash = false)
    begin
      unless hash
        new_comm = Community.find(comm_id, :conditions => ['active = ?', true])
      else
        new_comm = Community.find_by_hashed_name(comm_id, :conditions => ['active = ?', true])
      end
    rescue => e
      @err = 'No such community'
      return false
    end
    if new_comm.nil?
      @err = 'No such community'
      return false
    end
    if new_comm.parents.empty?
      @err = 'Cannot join super community'
      return false
    end
    if self.communities.collect(&:id).include?(new_comm.id)
      @err = 'Cannot add a community more than once'
      return false 
    end
    #NOTE add redundancy check... deactivate old parents
    #TODO compact this/add check of arrays b4 open connection
    #TODO access comm_assigns another way
    #TODO breaks for grandchild of diff parents
    current_comm = self.communities.collect(&:id)
    check_parents = new_comm.parents.collect{|par|par.id if par.active}
    CommunityAssign.transaction do
      check_parents.each do |par|
        if current_comm.include?(par)
          #CommunityAssign.find(:first, :conditions  => ['user_id = ? and community_id = ?', self.id, par]).update_attribute('active', false)
          Community.find(par).community_assigns.find(:first, :conditions => ['user_id = ?', self.id]).update_attribute(:active, false)
        end
      end
    end
    self.communities << new_comm
  end

  def unjoin_community(comm_id)
    begin
      self.communities.find(comm_id)
    rescue
      @err = 'User not associated'
      return false
    end
    #TODO make secure
    #CommunityAssign.find(:first, :conditions => ['user_id = ? and community_id = ?', self.id, comm_id]).update_attribute(:active, false)
    Community.find(comm_id).community_assigns.find(:first, :conditions => ['user_id = ?', self.id]).update_attribute(:active, false)
  end

  def self.authenticate(email, password)
    user = self.find(:first, :conditions => ['email = ? and active = ?',email, true])
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
      return user
    else
      return nil
    end
  end

  def self.owner_of_invite?(user_id, invite_id)
    return true if User.find(user_id).invites.collect(&:id).include?(invite_id.to_i)
    false
  end

  def self.user_profile(user_id)
    user = User.find(user_id) 
    out = Hash.new
    if user.photo
      out[:photo] = user.photo
    else
      out[:photo] = false
    end
    out[:id] = user.id
    out[:name] = user.name
    out[:email] = user.email
    if user.phone.to_s.empty?
      out[:phone] = 'n/a'
    else
      out[:phone] = user.phone
    end
    if user.college.to_s.empty?
      out[:college] = 'n/a'
    else
      out[:college] = user.college.name
    end
    if user.sex.to_s.empty?
      out[:sex] = 'n/a'
    else
      out[:sex] = user.sex.name
    end
    if user.yotag.to_s.empty?
      out[:yotag] = 'n/a'
    else
      out[:yotag] = user.yotag.tag
    end
    out[:interests] = Array.new
    out[:interests] << user.interest_1 unless user.interest_1.to_s.empty?
    out[:interests] << user.interest_2 unless user.interest_2.to_s.empty?
    out[:interests] << user.interest_3 unless user.interest_3.to_s.empty?
    return out
  end

  #----------------------------------------------
  # Virtual Attributes
  #----------------------------------------------
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end

  def invited?(invite)
    invite.invited_users.collect(&:user_id).include?(self.id) unless invite.nil?
  end

  def confirm_invited?(invite)
    invited?(invite) and invite.confirmed_users.include?(self)
  end

  #----------------------------------------------
  # Private methods
  #----------------------------------------------

  def validate_on_update
    if password
      errors.add_to_base("Passwords can't be empty") if password.empty? or password_confirmation.empty?
      errors.add_to_base("Passwords must match") unless password == password_confirmation
    end
  end

  #----------------------------------------------
  # Private methods
  #----------------------------------------------

  private

  def self.encrypted_password(password, salt)
    string_to_hash = password + "yywt" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

end
