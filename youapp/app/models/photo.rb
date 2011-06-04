class Photo < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :image
  validates_file_format_of :image, :in => ["image/jpeg","image/gif","image/png"]

  #NOTE IMG_PATH in production must symlink to img server/folder
  file_column :image, :web_root => IMG_PATH, :root_path => File.join(RAILS_ROOT, "public", IMG_PATH),
              :magick => {
              :versions => {"thumb" => {:crop => '1:1', :size => '75x75'},
                            "medium" => {:crop => '1:1', :size => '150x150'},
                            "poly_medium" => {:size => '250x250>'},
                            "large" => '800x800>' } }                                                                                                               
  
  def murder_siblings(user_id)
    photos = Photo.find(:all, :conditions => ["user_id = ?", user_id])
    if photos.length > 0
      photos.each{|photo| photo.destroy }
    end 
  end

end
