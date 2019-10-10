require "rails_helper"

RSpec.describe PresentersHelper, type: :helper do
  let(:object) { Sign.new }

  describe ".present" do
    it "presents an object" do
      expect(helper.present(object)).to be_a SignPresenter
    end

    it "presents an object with a custom presenter" do
      custom_presenter = Class.new(ApplicationPresenter)
      expect(helper.present(object, custom_presenter)).to be_a custom_presenter
    end

    it "does not re-present an already presented object" do
      presented = helper.present(object)
      expect(helper.present(presented)).to eq presented
    end

    it "yields to a block if provided with one" do
      expect { |b| helper.present(object, &b) }.to yield_control
    end
  end
end
