class Invite < ActiveRecord::Base

  attr_reader :err

  belongs_to :user  
  has_many :email_invites, :conditions => 'email_invites.active = true'
  has_many :invited_users, :conditions => 'invited_users.active = true'
  has_many :users, :through => :invited_users, :conditions => 'invited_users.active = true'
  has_many :confirmed_users, 
           :class_name => 'User',
           :through => :invited_users, 
           :source => :user, 
           :conditions => 'invited_users.active = true and invited_users.confirmed = true'

  validates_presence_of :user_id
  validates_presence_of :maximum_users 
  validates_presence_of :expiration_interval 
  #validates_presence_of :expires_at, :on => :update

  #validates_each :expires_at, :on => :update do |record, attr, value|
  #  record.errors.add attr, 'must be later than now.' unless value > Time.new
  #end

  validates_each :maximum_users do |record, attr, value|
    record.errors.add attr, 'must be greater than 0.' unless value > 0
  end

  def trunc_content(len = 25)
    return content[0..len] + "..." if content.length > len
    content
  end
 
  def self.most_recent(num = 5)
    #Invite.find(:all, :conditions => ['active = ? and expires_at > ?', true, Time.new], :limit => num, :order => 'id DESC')
    Invite.find(:all, :conditions => ['active = ? and expires_at is not ?', true, nil], :limit => num, :order => 'id DESC')
  end

  def expired?
    return true if Invite.find(:first, :conditions => ['id = ? and active = ? and expires_at > ?', self.id, true, Time.new]).nil?
    false
  end

  def self.all_hands_on_deck(duration = 300)
    cond = ['active = ? and expires_at >= ? and expires_at <= ?', true, Time.new, Time.new + duration]
    find = Invite.find(:all, :conditions => cond) 
    good = Array.new
    find.each do |inv|
      users = inv.confirmed_users.collect{|u|u if u.prefs.times_up}.compact
      next if users.length == 0
      user = inv.user
      InviteNotifier.deliver_itinerary(user, users, inv)
      inv.update_attribute('active', false)
      good << inv.id
    end
    good
  end

  def publish
    if self.content.to_s.empty?
      @err = 'Content of invite can\'t be blank'
      return false
    end
    if self.users.length > 0 or self.email_invites.length > 0
      self.email_invites.each do |evite|
        InviteNotifier.deliver_invite(self.user, evite.email, self)
      end
      self.users.each do |evite|
        next unless evite.prefs.invite_in
        InviteNotifier.deliver_invite(self.user, evite.email, self)
      end
      time = (Time.new + self.expiration_interval * 60)
      self.update_attribute('expires_at', time)
      return true
    else
      @err = 'You havn\'t invited anyone'
      return false
    end
  end

  def status
    if expires_at.to_s.empty?
      time = -1
    else
      time = (expires_at - Time.new).div(60).to_i
      if time < 1
        time = 0
      end
    end
    accepted = self.confirmed_users
    invited = self.users + self.email_invites
    {:maximum => maximum_users, :set_min => expiration_interval, 
     :remaining_min => time, :accepted => accepted, 
     :content => content, :invited => invited }
  end

end
