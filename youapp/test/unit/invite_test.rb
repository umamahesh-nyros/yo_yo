require File.dirname(__FILE__) + '/../test_helper'

class InviteTest < Test::Unit::TestCase
  fixtures :invites, :users, :invited_users
  def setup
    @invite = invites(:four)
  end

  def test_should_create_invite
    cnt = Invite.find(:all).length
    info = {:user_id => 99, :maximum_users => MAXIMUM_USERS_DEFAULT, :expiration_interval => EXP_DEFAULT}
    Invite.create(info)
    assert_equal(cnt + 1, Invite.find(:all).length, 'Didnt create invite')
  end

  def test_should_have_various_stats
    set = @invite.status
    assert(set[:set_min] > 0, "should have tons of minutes")
    assert_equal(2,set[:accepted].length)
    assert_equal(3,set[:maximum])
  end

  def test_should_send_out_some_alert_emails
    invite = invites(:five)
    invite.update_attribute('expires_at', Time.new + 60)
    added_user = users(:two)
    assert(added_user.join_event(invite.id), 'Should have invited user')
    assert(added_user.confirm_invite(invite.id), 'Should have confirmed user')
    test = Invite.all_hands_on_deck
    assert_equal(1, test.length, 'One invite should have been valid')
    assert_equal(5, test.first, '5th invite should have been valid')
  end

  def test_should_not_send_out_some_alert_emails
    test = Invite.all_hands_on_deck
    assert_equal(0, test.length, 'Zero invites should have been valid')
  end

end
