class NewAccount < ActionMailer::Base
  def welcome(sender,email,hash,sent_at = Time.new)
    @recipients = email
    @from = sender
    @subject = "Your YoYouWantTo.com Account Instructions"
    @body[:hash] = hash
    @sent_on    = sent_at
  end
end
