require File.dirname(__FILE__) + '/../test_helper'

class YotagTest < Test::Unit::TestCase
  fixtures :yotags

  def test_should_get_one_random
    assert_equal('XCVV', Yotag.new_random_tag.first.tag, 'WOW what are the odds!!')
  end

  def test_should_deactivate
    grab = Yotag.new_random_tag.first
    assert(Yotag.find(grab.id, :conditions => ['active = ?', true]), 'should have found tag')
    assert(Yotag.deactivate(grab.id), 'should have deactiavated tag')
    assert_raise ActiveRecord::RecordNotFound, 'should not have found such record' do
      Yotag.find(grab.id, :conditions => ['active = ?', true])
    end
  end

end
