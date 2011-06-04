class LostPassword < ActionMailer::Base
  def password_mail(sender,email,hash)
    @recipients = email
    @from = sender
    @subject = "Your YoYouWantTo.com Password Instructions"
    @body[:hash] = hash
  end
end
