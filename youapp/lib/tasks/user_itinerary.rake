desc "Send users itineraries for the pending invites"
namespace :user do
  task :email_itineraries => :environment do
    grab = Invite.all_hands_on_deck
    if grab.length > 0
      p "%s:" % Time.new
      p "Emails for invite %s sent out." % grab.to_sentence
    end
  end
end

