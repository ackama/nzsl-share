require "rails_helper"

RSpec.describe SignPresenter, type: :presenter do
  let(:sign) { FactoryBot.build_stubbed(:sign) }
  subject(:presenter) { SignPresenter.new(sign, view) }

  it "exposes a selection of core sign attributes" do
    %w[english id agree_count disagree_count].each do |sign_attr|
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
      let!(:folder) { FactoryBot.create(:folder, user: user, signs: [sign]) }
      it { expect(subject).to eq(folder => sign.folder_memberships.first) }
    end

    context "when the sign is not assigned to a folder" do
      let!(:folder) { FactoryBot.create(:folder, user: user) }
      it { expect(subject).to eq(folder => nil) }
    end

    context "when a block is passed" do
      let!(:folder) { FactoryBot.create(:folder, user: user, signs: [sign]) }
      it "yields the folder and membership to the block" do
        expect do |b|
          presenter.available_folders(&b)
        end.to yield_with_args(folder, folder.folder_memberships.first)
      end
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
      let!(:folder) { FactoryBot.create(:folder, user: user, signs: [sign]) }
      it { is_expected.to be_empty }
    end

    context "when the sign is not assigned to a folder" do
      let!(:folder) { FactoryBot.create(:folder, user: user) }
      it { is_expected.to match(/\A<option value="#{folder.id}">/) }
    end
  end

  describe "#friendly_date" do
    subject { presenter.friendly_date }
    context "sign is published" do
      before { sign.published_at = Time.zone.parse("01 Jan 2010 13:00") }
      it { is_expected.to eq "1 January 2010" }
    end

    context "sign is not published" do
      before { sign.created_at = Time.zone.parse("01 Jan 2011 13:00") }
      it { is_expected.to eq "1 January 2011" }
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
        expect(sign.video).to receive(:preview)
          .with(ThumbnailPreset.default.scale_1080.to_h)
          .and_return(double(service_url: nil))

        presenter.poster_url
      end

      it "requests a video preview with the given size" do
        expect(sign.video).to receive(:preview)
          .with(ThumbnailPreset.default.scale_720.to_h)
          .and_return(double.as_null_object)

        presenter.poster_url(size: 720)
      end
    end
  end

  describe "#sign_video_source" do
    subject { presenter.sign_video_source("720p") }
    it { is_expected.to eq "<source src=\"/signs/#{sign.id}/videos/720p\"></source>" }
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
end
