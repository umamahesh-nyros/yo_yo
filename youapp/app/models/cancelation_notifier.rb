class CancelationNotifier < ActionMailer::Base
  def cancel(sender, emails, invite)
    recipients emails
    headers "Reply-to" => "#{sender.email}"
    from "noreply@yoyouwantto.com"
    subject "Yo, I have to cancel..." 
    body :name => sender.name, :invite => invite.content
  end
end
