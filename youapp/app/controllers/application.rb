class ApplicationController < ActionController::Base
  session :session_key => '_yywt_session_id'

  private 

  def authorize_admin
    if session[:user_id].to_s.empty? or User.find(session[:user_id]).user_type.name != 'admin' and !TESTMODE
      flash[:notice] = "Please Log In..."
      redirect_to :controller => '/signup'
    end
  end

  def authorize_user
    if session[:user_id].to_s.empty? or !User.exists?(session[:user_id])
      redirect_to :controller => :signup
      return
    end
    if session[:expired_invites]
      flash[:notice] = "Yo(s) have expired since sent out to you."
      session[:expired_invites] = nil
    end
  end

  def upload_photo(photo_params, options={})
    photo = Photo.new(photo_params)
    unless photo.image.nil? and !options[:allow_nil]
      if options[:overwrite_existing] and options[:user_id]
        photo.murder_siblings(options[:user_id]) 
      end
      photo.save if photo.valid?
    end
  end

end
