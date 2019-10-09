require "rails_helper"

RSpec.describe ApplicationPresenter, type: :presenter do
  let(:dummy) { double }
  subject(:presenter) { ApplicationPresenter.new(dummy, view) }

  describe "#h" do
    subject { presenter.h }
    it { is_expected.to eq view }
  end

  describe ".presents" do
    subject do
      dummy_presenter_class = Class.new(ApplicationPresenter) { presents(:my_dummy_object) }
      dummy_presenter_class.new(dummy, view)
    end

    it "exposes the presenter subject via the requested key" do
      expect(subject.my_dummy_object).to eq dummy
    end
  end
end
