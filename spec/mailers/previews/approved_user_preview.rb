# Preview all emails at http://localhost:3000/rails/mailers/approved_user
class ApprovedUserPreview < ActionMailer::Preview
  def submitted
    application = FactoryBot.build_stubbed(:approved_user_application)
    ApprovedUserMailer.submitted(application)
  end

  def admin_submitted
    application = FactoryBot.build_stubbed(:approved_user_application)
    ApprovedUserMailer.admin_submitted(application)
  end
end
