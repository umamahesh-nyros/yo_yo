require 'resolv'
class PennDns
  attr_reader :tmp
  def initialize(ip)
    @tmp = create_set
    return
    #NOTE ruby -rresolv -e 'p Resolv.getname("138.102.114.1").to_s'
    begin
      @tmp = Resolv.getname(ip).to_s
    rescue ArgumentError => e
      puts 'Bad Input IP: %s' % e
    rescue Resolv::ResolvError => e
      puts 'No DNS Associated: %s' % e
    end
  end
  
  def create_set
    superset = Array.new
    PENN_IP_ARRAY.each do |ip|
      p ip 
      parts = ip.split('.')
      alpha = parts[0]
      beta  = parts[1]
      gamma = (0..255).to_a
      delta = (0..255).to_a
      set = Array.new
      gamma.each do |g|
        delta.each do |d|
          set << "%s.%s.%s.%s" % [alpha, beta, g, d]
        end
      end
      superset << set
    end
    return superset
  end

end
