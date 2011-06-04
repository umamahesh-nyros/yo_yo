module Admin::CommunitiesHelper

  def assembled_admin_communities(a)
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
  
  def part_string(pos,num)
    str = "%s.admin_childs.each do |%s|\n" % [pos, pos.next]
    str << "out << child_html(%s,%s)\n" % [pos.next, num]
  end

  def tools(id, child=true)
    out = String.new
    out << '<small>'
    out << '[<a href="/admin/communities/new_child/%s">add child</a>]&nbsp;' % id
    out << '[<a href="/admin/communities/edit/%s">edit</a>]&nbsp;' % id
    if child
      out << '[<a href="/admin/communities/invite/%s">invite</a>]&nbsp;' % id
    end
    out << '[<a href="/admin/communities/destroy/%s" %s>destroy</a>]&nbsp;' % [id, javascript_window]
    out << '</small>'
  end

  def child_html(comm,x=0)
    out = String.new
    out << "<p>%s<b>-%s</b>&nbsp;%s<br />\n" % ["&nbsp;"*(x*10),comm.name,tools(comm.id)]
    out << '%s<small><i>http://yoyouwantto.com/signup/community/%s</i></small>' % ["&nbsp;"*(x*10),comm.hashed_name]
    out << '</p>'
  end

  def javascript_window
    "onclick=\"if (confirm('Are you sure?')) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;f.submit(); };return false;\""
  end

end
