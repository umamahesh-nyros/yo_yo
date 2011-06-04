class Yotag < ActiveRecord::Base
  #NOTE for less taxing random stuff
  #Thing.find :first, :offset => rand(Thing.count)
  #--or--
  #./script/plugin install -x http://source.collectiveidea.com/public/rails/plugins/random_finders 
  #:order => :random
  has_one :user
  validates_presence_of :tag

  def self.new_random_tag(amt=25)
    self.find(:all, :conditions => ['active = ?', true], :limit => amt, :order => 'rand()')
  end

  def self.deactivate(id)
    self.find(id).update_attribute('active', false)
  end

  def self.activate(id)
    self.find(id).update_attribute('active', true)
  end

end
