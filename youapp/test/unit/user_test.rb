require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users, :invites, :invited_users, :user_assigns, :communities, :community_assigns, :user_preferences

  ################## Friends ####################

  def test_should_have_friends
    user = users(:one)
    assert_equal(1, user.friends.length, "User has wrong friends")
    user = users(:two)
    assert_equal(1, user.friends.length, "User has wrong friends")
  end

  def test_should_have_no_friends
    user = users(:three)
    assert_equal(0, user.friends.length, "User has friend and shouldnt")
  end

  def test_should_not_join_himself
    user3 = users(:three)
    assert(!user3.join_friend(user3.id), 'friend added and shouldnt') 
    assert_equal('Cannot add yourself', user3.err, "Err message wrong")
  end

  def test_should_add_one_friend_but_not_twice
    user3 = users(:three)
    user4 = users(:four)
    assert(user3.join_friend(user4.id), 'friend didnt add right') 
    check = User.find(user3.id)
    assert_equal(1, check.friends.length, "Friends dont amount to one")
    assert(!check.join_friend(user4.id), 'friend added right but shouldnt') 
    assert_equal('Cannot add friend more than once', check.err, "Err message wrong")
    assert_equal(1, check.friends.length, "Friends dont amount to one")
  end

  def test_should_unjoin_a_friend
    user = users(:one)
    cnt = user.friends.length
    assert(user.unjoin_friend(users(:two).id), 'User wasnt unjoined from his friend')
    assert_equal(cnt - 1, User.find(users(:one).id).friends.length, "User has friend and shouldnt")
  end

  def test_should_not_unjoin_a_friend
    user = users(:three)
    assert(!user.unjoin_friend(999), 'User should not be associated')
    assert_equal("User not associated", user.err)
  end


  ################## Signup ####################

  def test_should_create_user
    num = User.find(:all).length 
    user = {:terms => true, :user_type_id => 1, :last_name => 'newman', :first_name => 'frank', :email => 'newman@donkey.net', :password => 'scatter', :password_confirmation => 'scatter'}
    User.create(user)
    new_num = User.find(:all).length 
    assert_equal(num + 1, new_num, "user not created")
  end

  def test_should_not_create_bad_confirm_pass
    num = User.find(:all).length 
    user = {:user_type_id => 1, :last_name => 'newman', :first_name => 'frank', :email => 'newman@donkey.net', :password => 'scatter', :password_confirmation => 'brain'}
    User.create(user)
    new_num = User.find(:all).length 
    assert_equal(num, new_num, "user created but password confirm was diff")
  end

  def test_should_not_create_based_on_same_email
    num = User.find(:all).length 
    x = 0
    loop do
      break if x == 2
      user = {:terms => true, :user_type_id => 1, :last_name => 'newman', :first_name => 'frank', :email => 'newman@donkey.net', :password => 'scatter', :password_confirmation => 'scatter'}
      User.create(user)
      x += 1
    end
    new_num = User.find(:all).length 
    assert_equal(num + 1, new_num, "user was created and shouldn't have been (same email)")
  end

  ################## Join Invite ####################
  
  def test_should_join_event
    user = users(:two)
    assert(user.join_event(invites(:two).id), "User could not join and should have")
  end

  def test_should_confirm_event
    user = users(:two)
    assert(user.confirm_invite(invites(:three).id), 'User failed to confirm his event')
  end

  def test_should_not_confirm_event_too_many_peeps
    #user = users(:two)
    #assert(user.join_event(invites(:four).id), "didnt insert good user")
    #user = users(:four)
    #assert(!user.join_event(invites(:four).id), 'User added, shouldnt have been--too many peeps')
    #assert_equal("Invitation is closed", user.err)
  end

  def test_should_not_join_invite_he_is_not_invited
  end

  def test_should_not_joined_expired_event
  end

  def test_should_not_joint_pending_event
  end

  def test_should_not_join_non_exsisting_event
    user = users(:two)
    assert(!user.join_event(999), "User joined and should not have have")
    assert_equal("No such invitation is live", user.err)
  end

  def test_should_not_join_event_he_already_has
    user = users(:four)
    assert(user.join_event(invites(:four).id), "didnt insert good user")
    user = users(:four)
    assert(!user.join_event(invites(:four).id), 'User added, shouldnt have been--already has')
  end

  def test_should_not_join_user_is_joinging_his_own
    user = users(:one)
    assert(!user.join_event(invites(:three).id), 'User added, shouldnt have been--joined his own')
    assert_equal("Cannot join your own invitation", user.err)
  end

  def test_should_not_join_twice
    user = users(:three)
    assert(!user.join_event(invites(:four).id), 'User added, shouldnt have been--already joined')
    assert_equal("Cannot repeat invitation", user.err)
  end
  
  ################## Unjoin Invite ####################

  def test_should_unjoin_an_event
    user = users(:three)
    assert(user.unjoin_event(invites(:four).id), 'User wasnt unjoined from event')
  end

  def test_should_not_unjoin_an_event
    user = users(:three)
    assert(!user.unjoin_event(999), 'User should not be associated')
    assert_equal("User not associated", user.err)
  end

  ################## Invites  ####################

  def test_should_own
    user = users(:one)
    invite = invites(:four)
    assert(User.owner_of_invite?(user.id, invite.id), 'should have been owner of invite')
  end
  
  def test_should_not_own
    user = users(:one)
    assert(!User.owner_of_invite?(user.id, 999), 'should not have been owner of invite')
  end

  ################## Community ####################

  def test_should_add_community
    user = users(:one)
    assert_equal(1, user.communities.length, 'User should have Penn')
    assert(user.join_community(communities(:three).id), 'User should have joined community')
  end

  def test_should_not_add_super_community
    user = users(:one)
    assert_equal(1, user.communities.length, 'User should have one')
    assert(!user.join_community(communities(:two).id), 'User should not have joined community')
  end

  def test_should_not_add_community
    user = users(:one)
    assert(!user.join_community(999), 'User shouldnt join non existsing community')
    assert_equal('No such community', user.err, 'Wrong error 1')
    assert(!user.join_community(communities(:seven).id), 'User shouldnt join inactive community')
    assert_equal('No such community', user.err, 'Wrong error 2')
  end

  def test_should_not_join_twice
    user = users(:one)
    assert(user.join_community(communities(:three).id), 'User should have joined community')
    assert(!user.join_community(communities(:three).id), 'User should not have joined community twice')
    assert_equal('Cannot add a community more than once', user.err, 'Wrong error')
  end

  def test_should_unjoin_community
    user = users(:one)
    cnt = user.communities.length
    assert(user.unjoin_community(users(:one).id), 'User wasnt unjoined from his community')
    assert_equal(cnt - 1, User.find(users(:one).id).communities.length, "User has community and shouldnt")
  end

  def test_should_deal_with_redundant_tree
    #NOTE deactivate any lower community -- keep comm 1, 6, kick out 2
    user = users(:one)
    assert(user.join_community(communities(:three).id), 'User should have joined community 1')
    assert(user.join_community(communities(:six).id), 'User should have joined community 2')
    assert_equal(2, User.find(user.id).communities.length, 'User should have no redundant communities')
  end

  ################# Community Hash ###################

  def test_should_add_community_with_hash
    user = users(:one)
    assert_equal(1, user.communities.length, 'User should have Penn')
    assert(user.join_community(communities(:three).hashed_name, true), 'User should have joined community')
    assert_equal(2, User.find(user.id).communities.length, 'User should have Penn and class')
  end

  def test_should_have_preferred_community
    user = users(:one)
    assert_equal(1,user.preferred_communities.length,"Should have one prefered Community")
  end

  def test_should_not_have_preferred_community
    user = users(:two)
    assert_equal(0,user.preferred_communities.length,"Should have no prefered Community")
  end

  ################# Prefs ###################

  def test_prefs_should_have_some
    user = users(:one)
    assert_equal(true, user.prefs.afirm_out, 'Should have default pref true')
    assert_equal(true, user.prefs.invite_in, 'Should have default pref true 2')
    assert_equal(true, user.prefs.times_up, 'Should have default pref true 3')
  end

end
