require File.dirname(__FILE__) + '/../test_helper'

class CommunityTest < Test::Unit::TestCase
  fixtures :communities, :community_assigns, :users, :cached_communities

  def test_should_create
    new = Community.new(:name => 'Toronto University')
    assert(new.save, 'Community didnt save')
  end

  def test_should_update_and_have_same_hash
    umd = Community.find(communities(:two).id)
    assert(umd.update_attribute(:name,'University of Maryland'), 'Community didnt save')
    new_umd = Community.find(communities(:two).id)
    assert_equal(umd.hashed_name, new_umd.hashed_name, 'Hash is not correct')
  end

  def test_should_not_save_no_namae
    new = Community.new(:name => '')
    assert(!new.save, 'Community saved with empty name')
  end

  def test_should_have_children_music_and_econ_and_one_grandchild
    #NOTE emulating link to UMD - main campus
    test = communities(:three)
    assert_equal(1, test.parents.length, 'Should have one parent')
    assert_equal(3, test.all_childs.length, 'Should have had 2 children')
    assert_equal('Economics Department', test.all_childs.first.name, 'Should be Econ')
    assert_equal('MacroEcon201', test.all_childs.last.name, 'Should be Macro')
  end

  def test_should_have_econ_and_grandchild_macro
    #NOTE emulating link to Econ dept.
    test = communities(:four)
    assert_equal(2, test.parents.length, 'Should have two parent')
    assert_equal(1, test.all_childs.length, 'Should have had 1 children')
  end

  def test_should_have_children_no_parents
    #NOTE emulating link UMD.
    test = communities(:two)
    assert_equal(0, test.parents.length, 'UMD should have no parent')
    assert_equal(4, test.all_childs.length, 'Should have had 1 children --main campus')
  end

  def test_should_have_proper_order_parents
    #NOTE emulating link Macro.
    test = communities(:six)
    assert_equal(3, test.parents.length, 'Macro should have three parent')
    assert_equal('UMD', test.parents[0].name, 'Last parent should be UMD')
    assert_equal('College Park', test.parents[1].name, 'Next parent should be CP')
    assert_equal('Economics Department', test.parents[2].name, 'Next parent should be Econ')
  end

  def test_should_have_users
    test = communities(:one)
    assert_equal(1, test.users.length, 'Community had no users and should have one')
  end
  
  def test_should_yield_matches
    user = users(:five)
    string = 'college park'
    search = Community.name_search(string, user.id)
    assert_equal('College Park', search.first.name, 'should have matched college park')
    string = 'econ heaven'
    search = Community.name_search(string, user.id)
    assert_equal('Economics Department', search.first.name, 'tag should have matched econ')
    assert_equal(1, search.length, 'tag should have matched one')
  end

  def test_should_not_yield_matches
    user = users(:one)
    string = 'college park'
    search = Community.name_search(string, user.id)
    assert_equal(Array.new, search, 'should not be allowed')
    user = users(:five)
    string = 'adsas'
    search = Community.name_search(string, user.id)
    assert_equal(Array.new, search, 'should not have matched string')
  end

end
