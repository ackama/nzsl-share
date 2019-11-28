require "rails_helper"

RSpec.describe "Editing a sign", type: :system do
  include FileUploads
  include WaitForAjax

  let!(:topic) { FactoryBot.create(:topic) }
  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, :unprocessed, contributor: user) }
  subject { page }

  before do
    AuthenticateFeature.new(user).sign_in
    visit edit_sign_path(sign)
  end

  it "renders the edit page" do
    expect(subject.current_path).to eq edit_sign_path(sign)
  end

  it "shows the destroy button to contributors for private signs" do
    expect(subject).to have_content "Remove from NZSL Share"
    expect(subject).not_to have_content "Unpublish"
  end

  context "moderator signed in" do
    let(:user) { FactoryBot.create(:user, :moderator) }
    let(:sign) { FactoryBot.create(:sign, :published) }

    it "renders the edit page" do
      expect(subject.current_path).to eq edit_sign_path(sign)
    end

    it "shows the unpublish button" do
      expect(subject).to have_content "Unpublish"
      expect(subject).not_to have_content "Remove from NZSL Share"
    end
  end

  it "shows the expected page title" do
    expect(subject).to have_title "Edit '#{sign.word}' – NZSL Share"
  end

  it "can successfully enter metadata about a sign" do
    fill_in "sign_word", with: "Dog"
    fill_in "sign_maori", with: "Kuri"
    select topic.name, from: "Topic"
    fill_in "sign_secondary", with: "Canine"
    choose "should_submit_for_publishing_true"
    check "sign_conditions_accepted"
    click_on "Update Sign"
    sign.reload
    expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
    expect(subject).to have_content I18n.t!("signs.update.success")
    expect(subject).to have_content "Dog"
    expect(subject).to have_content topic.name
    expect(sign.submitted?).to eq true
  end

  context "non-approved user" do
    let(:user) { FactoryBot.create(:user) }

    it "doesn't see the conditions" do
      expect(page).to have_no_selector "#terms-and-conditions"
    end

    it "doesn't have an option to submit for publishing" do
      expect(page).to have_no_field "Yes, request my sign be public"
    end

    it "can update a private sign" do
      click_on "Update Sign"
      sign.reload
      expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
      expect(subject).to have_content I18n.t!("signs.update.success")
    end
  end

  it "can update a private sign without accepting the conditions" do
    choose "No, keep my sign private"
    click_on "Update Sign"
    sign.reload
    expect(subject.current_path).to eq sign_path(Sign.order(created_at: :desc).first)
    expect(subject).to have_content I18n.t!("signs.update.success")
    expect(sign.submitted?).to eq false
  end

  it "cannot request a sign be made public without accepting the conditions" do
    choose "Yes, request my sign be public"
    click_on "Update Sign"
    sign.reload
    expect(subject).to have_content sign.errors.generate_message(:conditions_accepted, :blank)
    expect(sign.submitted?).to eq false
  end

  it "hides the terms and conditions with JS unless they are required to be accepted", uses_javascript: true do
    expect(page).to have_selector "#terms-and-conditions", visible: false
    choose "Yes, request my sign be public"
    expect(page).to have_selector "#terms-and-conditions", visible: true
  end

  it "displays information about the video belonging to the sign" do
    within ".file-preview" do
      expect(subject).to have_content "dummy.mp4"
      expect(subject).to have_content "1 MB"
    end
  end

  it "displays validation errors" do
    fill_in "sign_word", with: ""
    click_on "Update Sign"

    expect(subject).to have_content "Edit sign"
    expect(subject).to have_css ".invalid"
  end

  describe "removing a sign" do
    before { click_on "Remove from NZSL Share" }

    it { expect { sign.reload }.to raise_error ActiveRecord::RecordNotFound }
    it { expect(current_path).to eq user_signs_path }
    it { expect(page).to have_content "Your sign, '#{sign.word}' has been removed from NZSL Share" }

    it "confirms before deleting", uses_javascript: true do
      confirmation = page.driver.browser.switch_to.alert
      expect(confirmation.text).to eq I18n.t!("signs.destroy.confirm")
    end
  end

  describe "video processing", uses_javascript: true do
    subject { page.find(".video") }

    context "when the video is unprocessed" do
      it { expect(page).to have_selector ".video[poster*=processing]" }
    end

    context "when the sign video has had thumbnails generated" do
      before { sign.update!(processed_thumbnails: true); }
      it { expect(page).to have_selector ".video[poster*='/rails/active_storage/']" }
    end

    context "when the sign video has been encoded" do
      before { sign.update!(processed_thumbnails: true, processed_videos: true); }
      it { expect(subject).to have_selector("source[src*='/videos']", count: 3, visible: false) }
    end
  end

  shared_examples_for "sign attachment behaviour" do |attribute|
    include ActionView::Helpers::NumberHelper
    let(:field_name) { "sign_#{attribute}" }
    let(:list_selector) { ".#{field_name.tr("_", "-")}" }
    let(:container_selector) { ".#{attribute.to_s.tr("_", "-")}" }
    let(:invalid_file) { Rails.root.join("spec", "fixtures", "dummy.exe") }

    context "without JS" do
      it "sees existing attachment data" do
        single_record = sign.public_send(attribute).first
        expected_file_size = number_to_human_size(single_record.byte_size)
        within(list_selector) do
          expect(page).to have_content single_record.filename
          expect(page).to have_content expected_file_size
          expect(page).to have_button "Remove File"
        end
      end

      it "can remove a file" do
        within(list_selector) do
          expect(page).to have_selector "li", count: 1
          click_button "Remove File"
          expect(page).not_to have_selector "li"
        end
      end

      it "can update the description of an attachment" do
        desc = Faker::Lorem.sentence
        single_record = sign.public_send(attribute).first
        expect do
          within(list_selector + " li") do
            fill_in :description, with: desc
            page.find("input[type=submit]", visible: false).click
            single_record.reload
          end
        end.to change { single_record.blob.metadata["description"] }.to eq desc

        within(list_selector) { expect(page).to have_field(:description, with: desc) }
      end

      it "can upload a new file" do
        within container_selector { page.attach_file field_name, valid_file }
        click_on "Update Sign"
        click_on "Edit"
        expect(page).to have_selector "#{list_selector} li", count: 1
      end

      it "rejects an invalid file with an error" do
        within container_selector do
          choose_file invalid_file
        end

        click_on "Update Sign"

        expect(page).to have_selector "input##{field_name}.invalid"
        expect(page).to have_content "file is not of an accepted type"
      end
    end

    context "with JS", uses_javascript: true do
      it "can remove a file" do
        within container_selector do
          click_on "Remove File"
        end

        expect(page.find(list_selector)).not_to have_selector "li"
      end

      it "can upload a new file" do
        original_count = sign.public_send(attribute).size
        page.scroll_to(find(container_selector))
        within container_selector do
          choose_file(valid_file)
        end

        expect(page.find(list_selector)).to have_selector "li", count: original_count + 1
        expect(sign.public_send(attribute).count).to eq original_count + 1
      end

      it "can upload a new file using drag and drop" do
        original_count = sign.public_send(attribute).size

        page.scroll_to(find(container_selector))
        within container_selector do
          drop_file_in_file_upload(valid_file,
                                   content_type: content_type,
                                   selector: "#{container_selector}-file-upload")
        end

        expect(page.find(list_selector)).to have_selector "li", count: original_count + 1
        expect(sign.public_send(attribute).count).to eq original_count + 1
      end

      it "can update the description of an attachment" do
        desc = Faker::Lorem.sentence
        single_record = sign.public_send(attribute).first
        within(list_selector + " li") do
          field = find_field(:description)
          field.send_keys desc, :return
          expect(page).to have_field(:description, with: desc)
        end

        single_record.reload
        expect(single_record.blob.metadata["description"]).to eq desc
      end

      it "rejects an invalid file with an error" do
        expected_err = "The file you selected does not comply with our upload guidelines."

        within container_selector do
          choose_file invalid_file
          expect(page).to have_content expected_err
          expect(page).to have_link "Try again."
        end
      end
    end
  end

  describe "usage examples" do
    let!(:sign) { FactoryBot.create(:sign, :with_usage_examples, contributor: user) }
    let(:valid_file) { Rails.root.join("spec", "fixtures", "dummy.mp4") }
    let(:content_type) { "video/mp4" }
    include_examples "sign attachment behaviour", :usage_examples
  end

  describe "illustrations" do
    let!(:sign) { FactoryBot.create(:sign, :with_illustrations, contributor: user) }
    let(:valid_file) { Rails.root.join("spec", "fixtures", "image.jpeg") }
    let(:content_type) { "image/jpeg" }
    include_examples "sign attachment behaviour", :illustrations
  end
end
