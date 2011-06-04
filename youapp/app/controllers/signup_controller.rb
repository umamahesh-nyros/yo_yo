class SignupController < ApplicationController

  filter_parameter_logging :password
  layout 'users'

  verify :method => :post, :only => [ :create, :submit ],
         :redirect_to => { :action => :logout }

  def index
    session[:user_id] = nil
    session[:people] = nil
    session[:invite] = nil
    session[:already] = nil
    session[:community_search_results] = nil
    @user = User.new
  end

  def community
    if params[:id].to_s.empty?
      flash[:warning] = 'This community key is not valid'
      redirect_to :action => :index
      return
    end
    comms = Community.good_hash?(params[:id])
    if comms
      @sentence = comms.collect(&:name).to_sentence
      @hash = params[:id]
      render :action => :community
    else
      flash[:warning] = 'This community key has been removed or is not valid'
      redirect_to :action => :index
    end
  end

  def accept_community
    if session[:user_id]
      redirect_to :controller => :users, :action => :add_community, :id => params[:id]
    else
      session[:community_email] = params[:id]
      flash[:notice] = 'Great! Now just login or signup.'
      redirect_to :action => :index
    end
  end

  def create
    #NOTE kick out robots
    unless params[:user_proxy][:email].empty?
      flash[:notice] = "Please do not use Google (or any other) AutoFill for the signup form."
      redirect_to :action => :index
      return
    end
    params[:user][:user_type_id] = 1
    @user = User.new(params[:user])
    if request.post? and @user.save
      unless EmailInvite.new_account_invites(@user.email)
        session[:expired_invites] = true
      end
      if session[:community_email]
	session[:user_id] = @user.id
        redirect_to :controller => :users, :action => :add_community, :id => session[:community_email]
        session[:community_email] = nil
      else
        ############################
	# TMP pref
	# force them false for beta
	############################
	@user.prefs
        ############################
	# TMP pref
	############################
        @user.update_attribute(:active, false)
	NewAccount::deliver_welcome("noreply@yoyouwantto.com", @user.email, @user.hashed_password)
        flash[:notice] = 'To login, follow the instructions in the email we just sent out to verify yourself.'
        redirect_to :action => :index
      end
    else
      render :action => :index
    end
  end

  def submit
    user = User.authenticate(params[:user][:email], params[:user][:password])
    if user
      params[:yywt][:user_id] = user.id
      session[:invite] = Invite.create(params[:yywt])
      session[:user_id] = user.id
      redirect_to :controller => :users
    else
      flash[:warning] = 'Incorrect login!<br />Have you confirmed your account via the email we sent you?'
      redirect_to :action => :index
    end
  end

  def activate_user
    if params[:id].to_s.empty?
      redirect_to :action => :index
      return
    end
    look = User.find(:first, :conditions => ['hashed_password = ?', params[:id]])
    unless look.nil?
      look.update_attribute(:active, true)
      session[:user_id] = look.id
      flash[:notice] = 'Add some communities'
      redirect_to :controller => :users, :action => :communities
    else
      redirect_to :action => :index
    end
  end

  def forgotten
    session[:password_hash] = nil
  end

  def email_password
    email = params[:user][:email]
    if email.empty?
      flash[:warning] = "Woops!"
      redirect_to :action => :forgotten
      return
    end
    look = User.find(:first, :conditions => ['email = ?', email])
    if look.nil?
      flash[:warning] = "Woops! Email not in system"
      redirect_to :action => :forgotten
      return
    end
    LostPassword::deliver_password_mail("noreply@yoyouwantto.com", email, look.hashed_password)
    flash[:notice] = "New password instructions were emailed to #{email}"
    redirect_to :action => :index
    return
  end

  def reset_password
    if params[:id].nil? and session[:password_hash].nil?
      redirect_to :action => :index
      return
    end
    if params[:id].nil?
      hash = session[:password_hash]
    else
      hash = params[:id]
    end
    look = User.find(:first, :conditions => ['hashed_password = ?', hash])
    if look.nil?
      redirect_to :action => :index
      return
    end
    session[:password_hash] = look.hashed_password
  end

  def submit_reset_password
    if session[:password_hash].nil?
      redirect_to :action => :index
      return
    end
    @user = User.find(:first, :conditions => ['hashed_password = ?', session[:password_hash]])
    if @user.nil?
      redirect_to :action => :index
      return
    end
    unless @user.update_attributes(params[:user])
      render :action => :reset_password
    else
      session[:password_hash] = nil
      flash[:notice] = "You can now log in with your new password."
      redirect_to :action => :index
    end
  end

  def logout
    flash[:notice] = 'Close all browser windows to ensure security.'
    redirect_to :action => :index
  end

end
