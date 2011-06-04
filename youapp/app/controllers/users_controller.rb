class UsersController < ApplicationController
 
  before_filter :authorize_user
  layout 'users'

  verify :method => :post,
    :only => [ :unaccept_invitation, :accept_invitation, :kill_invitation, :update_profile, :yywt, :kill_yywt, :send_yywt ], 
    :redirect_to => { :action => :index }

  def index
    dashboard
    render :action => :dashboard
  end

  def dashboard
    main_content
  end

  def parse_email
    hash = Hash.new
    hash[:user_id] = session[:user_id]
    hash[:invite_id] = session[:invite].id
    hash[:email] = params[:email][:email]
    @email = EmailInvite.new(hash)
    if @email.valid?
      if @email.already #NOTE already exists
        common_invite(@email.already)
        flash[:notice] = "Existing User added"
        redirect_to :action => :dashboard
      else
        @email.save
        flash[:notice] = "Email added."
        redirect_to :action => :dashboard
      end
    else
      main_content(:email)
      render :action => :dashboard
    end
  end

  def parse_search
    params[:search][:user_id] = session[:user_id]
    @search = Search.new(params[:search])
    if @search.valid?
      session[:people] = @search.users
    end
    render :partial => 'search_results', :object => @search.users
  end

  #TODO: handle errors in a more ajax-y fashion for the 5 methods
  def kill_invitation
    user = User.find(session[:user_id])
    @invitation = user.kill_invite(params[:id])
  end

  def accept_invitation
    user = User.find(session[:user_id])
    @invitation = user.confirm_invite(params[:id])
  end

  def unaccept_invitation
    user = User.find(session[:user_id])
    @invitation = user.unconfirm_invite(params[:id])
  end

  def invite
    res = common_invite(params[:id])
    return if res.nil?
    @user = User.find(params[:id])
  end

  def uninvite
    res = common_uninvite(params[:id])
    return if res.nil?
    @user = User.find(params[:id])
  end


  def current_invites
    invite = Invite.find(session[:invite].id)
    session[:people] = invite.users + invite.email_invites
    main_content(:community)
    render :action => :dashboard
  end

  def invited_populace
    invite = Invite.find(params[:id])
    session[:people] = invite.users
    main_content(:community)
    render :action => :dashboard
  end

  def new_yywt
    session[:already] = Array.new
    session[:invite] = nil
    main_content
    render :action => :dashboard
  end

  def update_yywt
    rec = Invite.find(session[:invite].id)
    rec.update_attributes(params[:yywt])
    session[:invite] = rec.reload
    main_content(:community)
    render :action => :dashboard
  end

  def send_yywt
    trial = Invite.find(session[:invite].id)
    if trial.publish
      session[:invite] = nil
      session[:already] = Array.new
      flash[:notice] = 'Invite sent out.'
      redirect_to :controller => :users
    else
      flash[:warning] = trial.err
      redirect_to :back
    end
  end

  def kill_yywt
    if User.owner_of_invite?(session[:user_id], params[:id])
      invite = Invite.find(params[:id])
      invite.update_attribute('active', false)
      user = User.find(session[:user_id])
      users = invite.confirmed_users
      unless users.empty?
        CancelationNotifier.deliver_cancel(user, users.collect(&:email), invite)
      end
      #TODO deactivate in email_invite
      if session[:invite] and session[:invite].id == params[:id].to_i
        session[:invite] = nil
      end
      flash[:notice] = 'Invite canceled.'
    else
      flash[:warning] = 'Not a valid invite.'
    end
    redirect_to :back
  end

  #TODO not used no mo
  def revamp_yywt
    begin
      invite = Invite.find(params[:id], :conditions => ['active = ? and user_id = ?', true, session[:user_id]])
    rescue
      flash[:warning] = 'Bad request.'
      redirect_to :back
    end
    session[:invite] = invite
    redirect_to :action => :current_invites
  end

  def communities
    unless session[:community_search_results].nil?
      @results = session[:community_search_results]
    end
    @communities = User.find(session[:user_id]).communities
  end

  def search_communities
    params[:search][:user_id] = session[:user_id]
    @search = CommunitySearch.new(params[:search])
    if @search.valid?
      session[:community_search_results] = @search.results
      redirect_to :action => :communities
    else
      session[:community_search_results] = nil
      @communities = User.find(session[:user_id]).communities
      render :action => :communities
    end
  end

  def delete_community
    user = User.find(session[:user_id])
    unless user.unjoin_community(params[:id])
      flash[:warning] = user.err
    else
      session[:community_search_results] = nil
      flash[:notice] = 'Community deleted.'
    end
    redirect_to :action => :communities
  end
  
  def select_community
    user = User.find(session[:user_id])
    if user.join_community(params[:id])
      flash[:notice] = 'Community added.'
    else
      flash[:warning] = user.err
    end
    redirect_to :action => :communities
  end

  def add_community
    string = params[:id]
    user = User.find(session[:user_id])
    if user.join_community(string, true)
      flash[:notice] = 'Community added.'
    else
      flash[:warning] = user.err
    end
    if session[:invite]
      redirect_to :action => :dashboard
    else
      redirect_to :controller => :public
    end
  end

  def community_populace
    session[:people] = Community.standard_users(params[:id],[session[:user_id]])
    session[:people].each do |p|
      common_invite(p.id)
    end
    main_content(:community)
    render :action => :dashboard
  end

  def parent_populace
    session[:people] = Community.all_child_users(params[:id], [session[:user_id]])
    session[:people].each do |p|
      common_invite(p.id)
    end
    main_content(:community)
    render :action => :dashboard
  end

  def community_populace_v2
    if params[:id].to_s.empty?
      redirect_to :action => :dashboard
      return
    end
    if session[:already].include?(params[:id].to_i)
      Community.standard_users(params[:id],[session[:user_id]]).each do |p|
	common_uninvite(p.id)
      end
      session[:people] = Invite.find(session[:invite].id).users
      session[:already].delete(params[:id].to_i)
    else
      Community.standard_users(params[:id],[session[:user_id]]).each do |p|
	common_invite(p.id)
      end
      session[:people] = Invite.find(session[:invite].id).users
      session[:already] << params[:id].to_i
    end
    main_content(:community)
    render :action => :dashboard
  end

  def parent_populace_v2
    if params[:id].to_s.empty?
      redirect_to :action => :dashboard
      return
    end
    if session[:already].include?(params[:id].to_i)
      Community.all_child_users(params[:id],[session[:user_id]]).each do |p|
	common_uninvite(p.id)
      end
      session[:people] = Invite.find(session[:invite].id).users
      session[:already].delete(params[:id].to_i)
    else
      Community.all_child_users(params[:id],[session[:user_id]]).each do |p|
	common_invite(p.id)
      end
      session[:people] = Invite.find(session[:invite].id).users
      session[:already] << params[:id].to_i
    end
    main_content(:community)
    render :action => :dashboard
  end

  def profile
    @profile = User.user_profile(params[:id])
  end

  def edit_profile
    @user = User.find(session[:user_id])
  end

  def update_profile
    @user = User.find(session[:user_id])
    if params[:user][:last_name].empty?
      params[:user][:last_name] = nil
    end
    if @user.update_attributes(params[:user])
      #NOTE do not delete
      #@user.preference.update_attributes(params[:prefs])
      #unless params[:user][:yotag_id].to_s.empty?
      #  Yotag.deactivate(params[:user][:yotag_id])
      #end
      unless params[:photo][:image].to_s.empty?
        params[:photo][:user_id] = @user.id
        upload_photo(params[:photo], :overwrite_existing => true, :user_id => @user.id)
        flash[:notice] = 'Your profile was successfully updated with photo.'
      else
        flash[:notice] = 'Your profile was successfully updated.'
      end
      redirect_to :action => :edit_profile
    else
      render :action => :edit_profile
    end
  end

  def delete_photo
    Photo.find(User.find(session[:user_id]).photo.id).destroy
    flash[:notice] = 'Photo deleted.'
    redirect_to :back
  end

  ##########################################################  
  # Private
  ##########################################################  

  private
 
  def main_content(method = nil)
    session[:already] ||= Array.new
    session[:invite] ||= Invite.create(:user_id => session[:user_id], 
        :expiration_interval => EXP_DEFAULT,
	:maximum_users => MAXIMUM_USERS_DEFAULT)
    @yywt = session[:invite]
    user = User.find(session[:user_id])
    @communities = user.communities
    @already = session[:already]
    unless method == :email
      @email = EmailInvite.new
    end
    unless method == :search
      @search = Search.new(String.new)
    end
    #@past_yos = user.past_invites
    unless method == :community or method == :search
      adjust_session
    end
    #@friends = session[:people]
    preview
  end

  def preview
    invite = Invite.find(session[:invite].id)
    @preview = Hash.new
    @preview[:set_min] = invite.status[:set_min]
    @preview[:maximum] = invite.status[:maximum]
    @preview[:invited_cnt] = invite.status[:invited].length
    @preview[:comm_cnt] = session[:already].length
  end

  def adjust_session
    session[:people] = Array.new
  end
  
  def common_invite(id)
    unless User.owner_of_invite?(session[:user_id], session[:invite].id)
      return nil
    end
    friend = User.find(id)
    if friend.join_event(session[:invite].id)
      User.find(session[:user_id]).join_friend(friend.id)
      return [true, '%s was invited.' % friend.name]
    else
      return [false, friend.err]
    end
  end

  def common_uninvite(id)
    unless User.owner_of_invite?(session[:user_id], session[:invite].id)
      return nil
    end
    friend = User.find(id)
    if friend.unjoin_event(session[:invite].id)
      User.find(session[:user_id]).join_friend(friend.id)
      return [true, '%s was uninvited.' % friend.name]
    else
      return [false, friend.err]
    end
  end

end
