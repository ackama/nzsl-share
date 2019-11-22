# Preview all emails at http://localhost:3000/rails/mailers/approved_user
class ApprovedUserPreview < ActionMailer::Preview
  def submitted
    user = FactoryBot.create(:user)
    ApprovedUserMailer.submitted(user)
  end
end
