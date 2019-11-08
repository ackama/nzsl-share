# frozen_string_literal: true

require "rails_helper"

RSpec.describe SignAttachmentsController, type: :routing do
  describe "#create" do
    let(:params) { { controller: "sign_attachments", action: "create" } }

    context "for usage examples" do
      subject { { post: "/signs/1/usage_examples" } }
      let(:params) { super().merge(sign_id: "1", attachment_type: "usage_examples") }
      it { is_expected.to route_to(params) }
    end

    context "for illustrations" do
      subject { { post: "/signs/1/illustrations" } }
      let(:params) { super().merge(sign_id: "1", attachment_type: "illustrations") }
      it { is_expected.to route_to(params) }
    end

    context "for madeup" do
      subject { { post: "/signs/1/madeup" } }
      it { is_expected.not_to be_routable }
    end

    context "for usage_examples_with_extra" do
      subject { { post: "/signs/1/usage_examples_with_extra" } }
      it { is_expected.not_to be_routable }
    end
  end

  describe "#destroy" do
    let(:params) { { controller: "sign_attachments", action: "destroy", sign_id: "1", id: "1" } }
    it { expect(delete: "/signs/1/usage_examples/1").to route_to(params) }
    it { expect(delete: "/signs/1/illustrations/1").to route_to(params) }
  end
end
