module UsersHelper

  def assembled_preview(hash)
    out = String.new
    out << "<p>You have selected "
    if hash[:comm_cnt] > 0
      out << "%s communities and " % hash[:comm_cnt]
    else
      out << "no communities and "
    end
    if hash[:invited_cnt] > 0
      if hash[:invited_cnt] == 1
        word = 'person'
      else
        word = 'people'
      end
      out << "<a href='/users/current_invites'>%s %s.</a> " % [hash[:invited_cnt],word]
    else
      out << "no people. "
    end
    out << "Once %s people accept or %s pass, no one will see your YYWT invitation.</p>" % [hash[:maximum], expiration(hash[:set_min])]
  end

  #TODO not used no mo
  def assembled_profile(pro)
    #TODO move _profile to here -- figure out with eval --
  end

  def assembled_friends(arr)
    return "" if arr.blank?
    arr.map{|f| invite_toggle(f)}.join('<br/>')
  end

  #TODO not used no mo
  def dropdown_past_yos(arr)
    return "" if arr.empty?
    out = String.new
    out << "<form action='/users/invited_populace' id='special_past_yos_form' method='post'>"
    out << "<select id='special_past_yos_select'>"
    out << "<option value=''>Select Past Yos</option>\n"
    out << "<option value=''>-------------</option>\n"
    arr.each do |rec|
      next if session[:invite].id == rec.id
      out << "<option value='%s'>%s</option>\n" % [rec.id,rec.trunc_content]
    end
    out << "</select>"
    out << "</form>"
    out
  end

  #TODO not used no mo
  def assembled_past_yos(arr)
    return "" if arr.empty?
    out = String.new
    arr.each do |rec|
      next if session[:invite].id == rec.id
      out << "<b><a href='/users/invited_populace/%s'>%s</a></b><br />\n" % [rec.id,rec.content]
    end
    out
  end

  def assembled_yos_in
    user = User.find(session[:user_id])
    user.invitations.map{|invitation| yo_div(invitation)}.join
  end

  def yo_div(invitation)
    out = ["[#{invitation.user.name}]",
           "Yo, you want to #{invitation.content}",
           "Max users: #{invitation.status[:maximum]}",
           "Expires: #{expiration(invitation.status[:remaining_min])}",
           "Accepted:"]
    out << invitation.status[:accepted].map{|user| user_profile_link(user)}.join(tag :br)
    out << tag(:br)
    out << accept_invitation_toggle(invitation)
    out << cancel_invitation(invitation)

    content_tag :div, out.join('<br/>'), :id => invitation.dom_id('yo_in'), :class => 'sticky sticky_orange'
  end

  def assembled_yos_out
    user = User.find(session[:user_id])
    arr = user.invites
    return if arr.empty?
    out = String.new
    arr.each do |rec|
      next unless rec.status[:remaining_min] > 0
      out << '<div class="sticky sticky_blue">'
      out << ' <div class="inner"> <small>From:</small>'
      out << '  <div class="top">'
      out << '    <dl class="clearfix">'
      out << '      <dt class="img"><img src="images/usrpic.gif" alt="" /></dt>'
      out << '      <dt class="name right">Some name here</dt>'
      out << '    </dl>'
      out << '  </div>'   
      out << '<div class="mid">'
      out << "<h2>Yo, you want to <strong>%s</strong>?</h2><br />\n" %rec.content
      out << '<div class="options">'
      if rec.status[:remaining_min] == 0
        out << "<p>Time remaining to accept: <strong>Expired</strong>\n"
      elsif rec.status[:remaining_min] == -1
        out << "<p>Time remaining to accept: <strong>Pending</strong>\n"
      else
        out << "<p>Time remaining to accept: <strong>%s</strong>\n" % expiration(rec.status[:remaining_min])
      end
      out << "<p>Max people that can come: <strong>%s</strong> people</p>\n" % rec.status[:maximum]
      out << "</div>"
      out << ' <div class="inAlready">'
      out << "<h4>Who's in already?</h4>\n"
      rec.status[:accepted].each do |user|
        out << "<br /><a href='/users/profile/%s'>%s</a>" % [user.id, user.name]
      end
      out << "</div>"
      out << '<div class="action">'
      out << "<br />\n"
      out << '<div class="fieldHalf"><a href="/users/kill_yywt/%s" %s><img src="images/ico_cross.png" alt="" /></a> <span>Cancel this Yo.</span> </div>'  % [rec.id, javascript_window]
      out << "</div>"
      out << "</div>"
      out << "</div>"      
      out << "</div>"
      out << "<br /><br />"      
    end
    out
  end

  #TODO expired
  def dropdown_communities(arr)
    return "" if arr.empty?
    out = String.new
    out << "<form id='special_community_form' method='post'>"
    out << "<select id='special_community_select'>"
    out << "<option value=''>Select Community</option>\n"
    out << "<option value=''>-------------</option>\n"
    aggregate_communities(arr).each do |comm|
      comm.each do |c|
        if c[2]
          out << "<option value='%s' id='community_populace'>%s</option>\n" % [c[1], c[0]]
        else
          out << "<option value='%s' id='parent_populace'>%s</option>\n" % [c[1], c[0]]
        end
      end
      out << "<option value=''>-------------</option>\n"
    end
    out << "</select>"
    out << "</form>"
    out
  end

  def assembled_edit_communities(a)
    out = String.new
    out << '<div>'
    out << '<b><u>%s</u></b>&nbsp%s' % [a.name,tools(a.id,false)]
    code = String.new
    cnt = 1
    ('a').upto('dm') do |pos|
      code << part_string(pos,cnt)
      cnt += 1
    end
    cnt -= 1
    cnt.times {|n| code << "\nend"}
    eval code
    out << '</div>'
  end

  def list_communities_v2(arr,already)
    return "" if arr.empty? 
    out = Array.new
    aggregate_communities(arr).each do |comm|
      comm.each do |c|
        next if c[4]
        if already.include?(c[1])
          selected = "X"
        else
          selected = "&nbsp;"
        end
        if c[2]
          out << "<a href='/users/community_populace_v2/%s'>[%s]%s (%s)</a><br />" % [c[1], selected, c[0], c[3]]
        else
          out << "<a href='/users/parent_populace_v2/%s'>[%s]%s (%s)</a><br />" % [c[1], selected, c[0], c[3]]
        end
      end
      out << '<hr/>'
    end
    out
  end

  #TODO expired
  def list_communities(arr)
    return "" if arr.empty?
    out = Array.new
    aggregate_communities(arr).each do |comm|
      comm.each do |c|
        if c[2]
          out << "<a href='/users/community_populace/%s'>%s</a><br />" % [c[1], c[0]]
        else
          out << "<a href='/users/parent_populace/%s'>%s</a><br />" % [c[1], c[0]]
        end
      end
      out << "------------<br />"
    end
    out
  end

  #TODO expired
  def assembled_communities(arr)
    return "" if arr.flatten.empty?
    out = String.new
    set = split_communities(arr)
    unless set.flatten.empty?
      for comm in set
        out << tree_community(comm)
      end
    end
    out
  end

  private

  def part_string(pos,num)
    str = "%s.admin_childs.each do |%s|\n" % [pos, pos.next]
    str << "out << child_html(%s,%s)\n" % [pos.next, num]
  end

  def tools(id, child=true)
    out = String.new
    out << '<small>'
    if child
      out << '[<a href="/users/select_community/%s">add me</a>]&nbsp;' % id
    end
    #out << '[<a href="/admin/communities/destroy/%s" %s>destroy</a>]&nbsp;' % [id, javascript_window]
    out << '</small>'
  end

  def child_html(comm,x=0)
    out = String.new
    out << "<div>%s<b>-%s</b>&nbsp;%s<br />\n" % ["&nbsp;"*(x*10),comm.name,tools(comm.id)]
    out << '%s<small><i>http://yoyouwantto.com/signup/community/%s</i></small>' % ["&nbsp;"*(x*10),comm.hashed_name]
    out << '</div>'
  end

  ##NOTE aggregate_communities
  # returns an array containing a 4 element array for a community:
  # n[0] = comm name
  # n[1] = comm id
  # n[2] = boolean -- is that community a child-most comm
  # n[3] = user count for that community
  # n[4] = boolean -- is super parent
  ##
  def aggregate_communities(arr)
    set = Array.new
    superset = Array.new
    arr.each do |comm|
      set << [comm.parents.collect(&:id), comm.id].flatten
    end
    grouped = Array.new
    set.each do |curr|
      grouped <<  set.select{|all|all.first == curr.first}
    end
    final = Array.new
    grouped.uniq.each do |set|
      final << set.flatten.uniq
    end
    Community.transaction do
      final.each do |s|
        superset << Community.find(s).collect{|comm| [comm.name, comm.id, arr.collect(&:id).include?(comm.id), comm.user_count, comm.parent.to_s.empty?]}
      end
    end
    superset
  end

  #TODO delete expired
  def split_communities(arr)
    set = Array.new
    arr.collect do |a|
      unless a.parents.empty?
        set << [a.id, a.parents.first.id]
      end
    end 
    tmp_set = set.collect{|s|s.last}
    combined = tmp_set.collect{|t|t if (tmp_set.select{|s|s == t}.length > 1)}.compact.uniq
    combined_set = Array.new
    combined.each do |parent| 
      combined_set << arr.collect{|com| com if (set.collect{|s|s.first if parent == s.last}.compact).include?(com.id)}.compact
    end
    combined_set
  end

  #TODO delete expired
  def tree_community(comm)
    out = String.new
    parts = Array.new
    comm.each do |part|
      p = String.new
      p << "<li><b><a href='/users/community_populace/%s' id='owned'>%s</a></b>\n" % [part.id,part.name]
      p << "<ul>\n"
      #NOTE users
      p << community_users(part)
      p << "</ul>\n"
      p << "</li>\n"
      parts << [part.id, part.parents.last.id, p]
    end
    start = parts.collect{|p|p[1]}.max
    iterations = comm.find{|c| c.parents.last.id == start}.parents.collect{|n|n.id}
    out << "<ul>\n"
    iterations.each do |i|
      comm = Community.find(i) #TODO no new query
      out << "\s<li><a href='/users/parent_populace/%s'>%s</a>\n" % [comm.id,comm.name]
      out << "\s\s<ul>\n"
      for part in parts 
        out << part[2] if part[1] == i
      end
    end
    iterations.each do
      out << "\s\s</ul>\n"
      out << "\s</li>\n"
    end
    out << "</ul>"
  end

  #TODO delete expired
  def community_users(comm)
    out = String.new
    out << "<li><i>Members (%s)</i></li>\n" % (comm.users.length - 1)
    friends = User.find(session[:user_id]).friends.collect(&:id)
    comm.users.each do |usr|
      next if session[:user_id] == usr.id
      if friends.include?(usr.id)
        out << "<li>%s</li>\n" % usr.email
      else
        out << "<li>%s - unfamiliar</li>\n" % usr.email
      end
    end
    out
  end

  def javascript_window
    "onclick=\"if (confirm('Are you sure?')) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;f.submit(); };return false;\""
  end


  #AJAX Helpers
  def invite_toggle_link(user)
    if user.confirm_invited?(session[:invite])
      image_tag('check_small.png')
    elsif user.invited?(session[:invite])
      link_to_remote image_tag('ico_cross.png'), :url => {:action => 'uninvite', :id => user}
    else
      link_to_remote image_tag('ico_add.png'), :url => {:action => 'invite', :id => user}
    end
  end

  def user_profile_link(user)
    image_tag('usrpic.gif') + user.name
    #link_to user.name, {:action => 'profile', :id => user}
  end
  def invite_toggle(user)
    content_tag :div,
                user_profile_link(user) + invite_toggle_link(user),
                :id => user.dom_id('invite_toggle'), :class => 'invite_toggle'
  end

  def accept_invitation_toggle(invitation)
    unless User.find(session[:user_id]).confirm_invited?(invitation)
      link_to_remote 'Accept', :url => {:action => 'accept_invitation', :id => invitation}
    else
      link_to_remote 'Unaccept', :url => {:action => 'unaccept_invitation', :id => invitation}
    end
  end
  def cancel_invitation(invitation)
    link_to_remote 'Ignore Yo', :url => {:action => 'kill_invitation', :id => invitation}
  end

  def search_result_item(result)
    content_tag :li, 
      image_tag('user.png') + result.name,
      :id => result.id
  end

end
