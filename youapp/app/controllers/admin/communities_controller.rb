class Admin::CommunitiesController < AdminAreaController

  def index
    list
    render :action => :list
  end

  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    session[:tmp_parent] = nil
    @communities = Community.find(:all, :conditions => ['parent is ? and active = ?', nil, true])
  end

  def show
    @community = Community.find(params[:id])
  end

  def new
    @community = Community.new
    @parent = true
  end

  def create
    @community = Community.new(params[:community])
    if @community.valid?
      params[:community][:created_at] = Time.new
      @community = Community.create(params[:community])
      Community.taggify(@community.id, params[:tag][:string])
      flash[:notice] = 'Community was successfully created.'
      redirect_to :action => :list
    else
      @parent = true
      render :action => :new
    end
  end

  def edit
    @community = Community.find(params[:id])
    @tags = @community.tags
    unless @community.parent
      @parent = true
    end
  end

  def new_child
    session[:tmp_parent] = params[:id] 
    @parent_community = Community.find(session[:tmp_parent])
    @community = Community.new
  end

  def create_child
    params[:community][:parent] = session[:tmp_parent]
    @community = Community.new(params[:community])
    if @community.valid?
      @community = Community.create(params[:community])
      Community.taggify(@community.id, params[:tag][:string])
      flash[:notice] = 'Community child was successfully created.'
      redirect_to :action => :list
    else
      @parent_community = Community.find(session[:tmp_parent])
      render :action => :new_child
    end
  end

  def update
    @community = Community.find(params[:id])
    @tags = @community.tags
    if @community.update_attributes(params[:community])
      if @community.parent
        Community.taggify(params[:id], params[:tag][:string])
      end
      flash[:notice] = 'Community was successfully updated.'
      redirect_to :action => :show, :id => @community
    else
      render :action => :edit
    end
  end

  def delete_tag
    CommunityTag.find(params[:id]).update_attribute(:active, false)
    redirect_to :back
  end

  def destroy
    Community.find(params[:id]).update_attribute('active', false)
    redirect_to :action => :list
  end

end
