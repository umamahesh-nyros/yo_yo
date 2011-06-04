class PublicController < ApplicationController

  layout 'users'

  def index
    session[:invite] = nil
    yywt
    render :action => :yywt
  end

  def yywt
    @yywt = Invite.new
  end

  def good_login_bad_form
    @yywt = Invite.new(session[:invite_tmp])
    @yywt.valid?
    render :action => :yywt
  end

  def create
    session[:invite_tmp] = params[:yywt]
    if session[:user_id].nil?
      flash[:notice] = 'Please log in to continue.'
      redirect_to :controller => :signup
      return
    end
    params[:yywt][:user_id] = session[:user_id]
    @yywt = Invite.new(params[:yywt])
    if @yywt.valid?
      @yywt.save
      session[:invite] = @yywt
      session[:invite_tmp] = nil
      flash[:notice] = 'Invite created.'
      redirect_to :controller => :users
    else
      render :action => :yywt
    end
  end

end
