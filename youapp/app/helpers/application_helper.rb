include UsersHelper
module ApplicationHelper
  def expiration(input = nil)
    return distance_of_time_in_words(Time.new, input.minutes.from_now) if input
    array = Array.new
    EXP_ARRAY.each do |x|
      array <<  [(distance_of_time_in_words(Time.new, x.minutes.from_now)),x]
    end
    array
  end

  def most_recent
    set = Invite.most_recent(RECENT_NUM)

    content_tag :ul,
                content_tag(:label, 'Yo, you want to...') + 
                set.map{|invite| content_tag(:li, invite.content) }.join,
                :id => 'recent_yos', :style => 'display:none;'
  end

  def checkbox_helper(input)
    return 'checked' if input
    nil
  end

end
