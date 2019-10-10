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

  describe "#dom_id" do
    subject { presenter.dom_id }
    it { is_expected.to eq "sign_#{sign.id}" }

    context "provided with a suffix" do
      subject { presenter.dom_id(:folders) }
      it { is_expected.to eq "folders_sign_#{sign.id}" }
    end
  end
end
