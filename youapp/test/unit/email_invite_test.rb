require File.dirname(__FILE__) + '/../test_helper'

class EmailInviteTest < Test::Unit::TestCase
  fixtures :email_invites, :users, :invites, :invited_users

  def test_should_add_record
    hash = {:email => 'test@test.net', :user_id => users(:one).id,
            :invite_id => invites(:one).id}
    assert(EmailInvite.create(hash), 'should have created record')
  end

  def test_should_not_add_record
    hash = {:email => 'test@test', :user_id => users(:one).id,
            :invite_id => invites(:one).id}
    record = EmailInvite.new(hash)
    assert(!record.save, 'should not have created record')
    hash = {:email => 'test@test.net', :user_id => nil,
            :invite_id => invites(:one).id}
    record = EmailInvite.new(hash)
    assert(!record.save, 'should not have created record')
    hash = {:email => 'test@test.net', :user_id => users(:one).id,
            :invite_id => nil}
    record = EmailInvite.new(hash)
    assert(!record.save, 'should not have created record')
  end

end
