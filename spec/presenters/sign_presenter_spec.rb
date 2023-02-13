require "rails_helper"

RSpec.describe SignPresenter, type: :presenter do
  let(:sign) { FactoryBot.build_stubbed(:sign) }
  subject(:presenter) { SignPresenter.new(sign, view) }

  it "exposes a selection of core sign attributes" do
    %w[word id agree_count disagree_count].each do |sign_attr|
      expect(sign).to receive(sign_attr)
      subject.public_send(sign_attr)
    end
  end

  describe "#available_folders" do
    # We need the sign to actually exist so we can set up
    # folder associations
    let(:sign) { FactoryBot.create(:sign) }
    let(:user) { sign.contributor }
    before { sign_in user }
    subject { presenter.available_folders }

    context "with no folders" do
      it { expect(subject).to be_empty }
    end

    context "with no user signed in" do
      before { sign_out :user }
      it { is_expected.to be_empty }
    end

    context "when the sign is assigned to a folder" do
      let!(:folder) { FactoryBot.create(:folder, user:, signs: [sign]) }
      it { expect(subject).to eq(folder => sign.folder_memberships.first) }
    end

    context "when the sign is not assigned to a folder" do
      let!(:folder) { FactoryBot.create(:folder, user:) }
      it { expect(subject).to eq(folder => nil) }
    end

    context "when a block is passed" do
      let!(:folder) { FactoryBot.create(:folder, user:, signs: [sign]) }
      it "yields the folder and membership to the block" do
        expect do |b|
          presenter.available_folders(&b)
        end.to yield_with_args(folder, folder.folder_memberships.first)
      end
    end
  end

  describe "#status_name" do
    let(:sign) { FactoryBot.build(:sign, :submitted) }
    subject { presenter.status_name }

    context "user is a moderator" do
      let(:user) { FactoryBot.create(:user, :moderator) }
      before { sign_in user }

      it "returns the admin status name" do
        expect(subject).to eq "Pending"
      end

      context "but also contributed the sign" do
        before { sign.contributor = user }

        it "returns the friendly status name" do
          expect(subject).to eq "In Progress"
        end
      end
    end

    it "returns a friendly status name" do
      expect(subject).to eq "In Progress"
    end
  end

  describe "#status_notes" do
    let(:user) { FactoryBot.create(:user, :approved) }
    let(:sign) { FactoryBot.build(:sign, contributor: user) }
    before { sign_in user }
    subject { presenter.status_notes }

    context "user contributed the sign" do
      it { is_expected.to eq I18n.t!("signs.personal.status_notes") }
    end

    context "user is not the contributor" do
      let(:other_user) { FactoryBot.create(:user) }
      before { sign_in other_user }
      it { is_expected.to be_nil }
    end

    context "sign is not private" do
      let(:sign) { FactoryBot.build(:sign, :submitted) }
      it { is_expected.to be_nil }
    end
  end

  describe "#assignable_folder_options" do
    # We need the sign to actually exist so we can set up
    # folder associations
    let(:sign) { FactoryBot.create(:sign) }
    let(:user) { sign.contributor }
    before { sign_in user }
    subject { presenter.assignable_folder_options }

    context "when the sign is assigned to the folder" do
      let!(:folder) { FactoryBot.create(:folder, user:, signs: [sign]) }
      it { is_expected.to be_empty }
    end

    context "when the sign is not assigned to a folder" do
      let!(:folder) { FactoryBot.create(:folder, user:) }
      it { is_expected.to match(/\A<option value="#{folder.id}">/) }
    end
  end

  describe "#friendly_date" do
    subject { presenter.friendly_date }
    context "sign is published" do
      before { sign.published_at = Time.zone.parse("1 January 2010 13:00") }
      it { is_expected.to eq "1 Jan 2010" }
    end

    context "sign is not published" do
      before { sign.created_at = Time.zone.parse("1 January 2011 13:00") }
      it { is_expected.to eq "1 Jan 2011" }
    end
  end

  describe "#truncated_secondary" do
    it "truncates something that is too long" do
      sign.secondary = <<~LOREM
        Lorem ipsum dolor sit amet, consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
      LOREM

      expect(presenter.truncated_secondary.length).not_to eq sign.secondary.length
      expect(presenter.truncated_secondary).to end_with "..."
    end

    it "does not truncate something that is not too long" do
      sign.secondary = "normal secondary length"

      expect(presenter.truncated_secondary.length).to eq sign.secondary.length
      expect(presenter.truncated_secondary).not_to end_with "..."
    end
  end

  describe "#poster_url" do
    context "thumbnails are not processed" do
      it "returns a placeholder" do
        expect(presenter.poster_url).to match(/processing-[a-f0-9]+.svg\Z/)
      end
    end

    context "thumbnails are processed" do
      before { sign.processed_thumbnails = true }

      it "requests a video preview with the default size" do
        preview = double.as_null_object

        expect(sign.video).to receive(:preview)
          .with(ThumbnailPreset.default.scale_1080.to_h)
          .and_return(preview)

        expect(view).to receive(:url_for).with(preview.image).and_return("/preview-url")
        expect(presenter.poster_url).to eq "/preview-url"
      end

      it "requests a video preview with the given size" do
        preview = double.as_null_object
        expect(view).to receive(:url_for).with(preview.image).and_return("/preview-url")

        expect(sign.video).to receive(:preview)
          .with(ThumbnailPreset.default.scale_720.to_h)
          .and_return(preview)

        expect(presenter.poster_url(size: 720)).to eq "/preview-url"
      end
    end
  end

  describe "#sign_video_sourceset" do
    subject { presenter.sign_video_sourceset }

    context "videos are processed" do
      before { sign.processed_videos = true }

      it "derives the sourceset from the default presets" do
        expect(subject.scan("<source").size).to eq 3
        expect(subject).to include "1080p"
        expect(subject).to include "720p"
        expect(subject).to include "360p"
      end

      it "derives the sourceset from override presets" do
        result = presenter.sign_video_sourceset(["360p"])
        expect(result.scan("<source").size).to eq 1
        expect(result).to include "360p"
      end
    end

    context "videos are unprocessed" do
      it { is_expected.to be_nil }
    end
  end

  describe "#dom_id" do
    subject { presenter.dom_id }
    it { is_expected.to eq "sign_#{sign.id}" }

    context "provided with a suffix" do
      subject { presenter.dom_id(:folders) }
      it { is_expected.to eq "folders_sign_#{sign.id}" }
    end
  end

  describe "#comments_count" do
    it "counts comments using Pundit.policy_scope" do
      user = User.new
      sign_in user
      relation_double = instance_double(ActiveRecord::Relation, count: 10).as_null_object
      expect(Pundit).to receive(:policy_scope)
        .with(view.current_user, sign.sign_comments)
        .and_return(relation_double)

      expect(presenter.comments_count).to eq 10
    end

    it "does not count comments that are added when the sign is in a different state" do
      sign = FactoryBot.create(:sign, :published)
      presenter = SignPresenter.new(sign, view)
      allow(presenter.h).to receive(:current_user).and_return(sign.contributor)
      FactoryBot.create(:sign_comment, sign:)

      expect(presenter.comments_count).to eq 1

      sign.unpublish!
      presenter.instance_variable_set(:@comments_count, nil) # Bust cache
      expect(presenter.comments_count).to eq 0
    end
  end

  describe "#unread_comments?" do
    let(:sign) { FactoryBot.create(:sign, :published) }

    it "is true when there is an unread comment" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:sign_comment, sign:)
      allow(presenter.h).to receive(:current_user).and_return(user)
      expect(presenter.unread_comments?).to be true
    end

    it "is false when there are no unread comments" do
      user = FactoryBot.create(:user)
      comment = FactoryBot.create(:sign_comment, sign:)
      comment.activities.read.create!(user:)
      allow(presenter.h).to receive(:current_user).and_return(user)
      expect(presenter.unread_comments?).to be false
    end

    it "doesn't count comments created before the user registered" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:sign_comment, sign:, created_at: user.created_at - 1.hour)
      allow(presenter.h).to receive(:current_user).and_return(user)
      expect(presenter.unread_comments?).to be false
    end
  end
end
