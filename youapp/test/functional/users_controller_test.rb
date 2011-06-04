require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = users(:one).id
    @request.session[:user_id] = users(:one).id
  end

  def test_should_edit_profile
    get :edit_profile, :id => @first_id

    assert_response :success
    assert_template 'edit_profile'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_should_update_profile
    post :update_profile, {:user => {:profile => 'I am drunk'}, :photo => {}}
    assert_response :redirect
    assert_redirected_to :action => 'communities'
  end

  def test_should_do_stuff
  end

  ##################### SCAFFOLD #######################
=begin
  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:users)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:user)
  end

  def test_create
    num_users = User.count

    #post :create, :user => {}

    #assert_response :redirect
    #assert_redirected_to :action => 'list'

    #assert_equal num_users + 1, User.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      User.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      User.find(@first_id)
    }
  end
=end
end
