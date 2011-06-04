require 'csv'
class DoPenn
  def initialize
    type = {'S' => 1,'D' => 2, 'A' => 3, 'D' => 4}
    proper = Array.new
    Community.transaction do
      CSV::Reader.parse(File.new('lib/upenn.csv','r').read) do |row|
        a = Community.new(:name => row[1], :parent => row[2], :community_type_id => type[row[3]]) 
	a.id = row[0]
	a.save
      end
    end
  end
end
