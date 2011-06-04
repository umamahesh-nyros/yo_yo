class InviteNotifier < ActionMailer::Base

  def invite(sender, email, invite)
    recipients email
    headers "Reply-to" => "#{sender.email}"
    from "noreply@yoyouwantto.com"
    subject "Yo, you want to..." 
    body :name => sender.name, :invite => invite.content
  end

  def confirmation(user, invite)
    recipients invite.user.email
    headers "Reply-to" => "#{user.email}"
    from "noreply@yoyouwantto.com"
    subject "Yo, you want to... [CONFIRMATION]" 
    body :name => user.name, :invite => invite.content
  end

  def unconfirmation(user, invite)
    recipients invite.user.email
    headers "Reply-to" => "#{user.email}"
    from "noreply@yoyouwantto.com"
    subject "Yo, you want to... [UNCONFIRMATION]" 
    body :name => user.name, :invite => invite.content
  end

  def itinerary(inviter, invitees, invite)
    emails = invitees.collect(&:email) << inviter.email
    recipients emails
    headers "Reply-to" => "#{inviter.email}"
    from "noreply@yoyouwantto.com"
    subject "Yo, you want to %s [ITINERARY]" % invite.content 
    body :name => inviter.name, :guests => invitees.collect(&:name), :invite => invite.content
  end

end
