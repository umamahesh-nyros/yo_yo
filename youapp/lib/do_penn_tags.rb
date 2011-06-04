require 'csv'
class DoPennTags
  def initialize
    proper = Array.new
    CommunityTag.transaction do
      CSV::Reader.parse(File.new('lib/tags.csv','r').read) do |row|
        a = CommunityTag.new(:id => row[0], :tagname => row[1], :community_id => row[2]) 
	a.save
      end
    end
  end
end
