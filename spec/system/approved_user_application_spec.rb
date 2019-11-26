require "rails_helper"

RSpec.describe "Approved user application", type: :system do
  include ActiveJob::TestHelper
  let(:user) { FactoryBot.create(:user) }
  let!(:admin) { FactoryBot.create(:user, :administrator) } # We need a user to receive admin emails
  subject { ApprovedUserApplicationFeature.new }
  before { subject.start(user) }

  it "completes the mandatory fields only" do
    subject.fill_in_mandatory_fields
    expect { subject.submit; user.reload }.to change(user, :approved_user_application).to be_present
    expect(page).to have_current_path root_path
    expect(page).to have_content "Thank you! An NZSL Share Admin will look at your application soon."
  end

  it "sends an email to the user after submitting" do
    subject.fill_in_mandatory_fields
    perform_enqueued_jobs { subject.submit }
    mail = ActionMailer::Base.deliveries[-2]
    expect(mail.to).to eq [user.email]
    expect(mail.subject).to eq I18n.t("approved_user_mailer.submitted.subject")
  end

  it "sends an email to the admin after submitting" do
    subject.fill_in_mandatory_fields
    perform_enqueued_jobs { subject.submit }
    mail = ActionMailer::Base.deliveries[-1]
    expect(mail.to).to eq [admin.email]
    expect(mail.subject).to eq I18n.t("approved_user_mailer.admin_submitted.subject")
  end

  it "leaves a required field blank" do
    subject.fill_in_mandatory_fields
    subject.fill_in "First name", with: ""
    subject.submit
    expect(page).to have_selector "#application_first_name.invalid + .form-error",
                                  text: "can't be blank"
  end

  it "picks some options for language roles" do
    subject.fill_in_mandatory_fields
    roles = Demographics.language_roles.sample(2)
    roles.each { |role| check I18n.t("demographic.language_roles.#{role}") }
    subject.submit
    expect(page).to have_content I18n.t!("approved_user_applications.create.success")
    expect(ApprovedUserApplication.last.language_roles).to match_array roles
  end

  it "picks the 'Other' option for language roles", uses_javascript: true do
    subject.fill_in_mandatory_fields
    other_role = Faker::Lorem.sentence
    subject.check "Other:"
    subject.fill_in "application_language_roles", with: other_role
    subject.submit
    expect(ApprovedUserApplication.last.language_roles).to match_array ["other", other_role]
  end

  it "picks the 'Other' option for ethnicity", uses_javscript: true do
    subject.fill_in_mandatory_fields
    other_ethnicity = Faker::Lorem.sentence
    subject.choose "Other ethnic group:"
    subject.fill_in "application_ethnicity", with: other_ethnicity
    subject.submit
    expect(ApprovedUserApplication.last.ethnicity).to eq other_ethnicity
  end

  context "already-approved user" do
    let(:user) { FactoryBot.create(:user, :approved) }

    it "returns to the homepage" do
      expect(page).to have_current_path root_path
    end

    it "shows the unauthorized message" do
      expect(page).to have_content I18n.t("application.unauthorized")
    end
  end
  context "not signed in" do
    let(:user) { nil }

    it "redirects to the sign in page" do
      expect(page).to have_current_path new_user_session_path
    end
  end
end
