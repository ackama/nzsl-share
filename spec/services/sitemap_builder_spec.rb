# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SitemapBuilder", type: :model do
  let(:sitemap_builder) { SitemapBuilder.new }
  let(:signs) { FactoryBot.build_stubbed_list(:sign, 3, :published) }
  before { allow(sitemap_builder).to receive(:fetch_all_signs).and_return(signs) }

  describe "#first_or_generate_basic" do
    context "when a Sitemap record exists" do
      let!(:sitemap) { Sitemap.create!(xml: "<sitemap></sitemap>") }

      it "returns that record" do
        expect(sitemap_builder.first_or_generate_basic).to eq(sitemap)
      end
    end

    context "when a Sitemap record does not exist" do
      it "generates one" do
        expect { sitemap_builder.first_or_generate_basic }.to change(Sitemap, :count).by(1)
      end
    end
  end

  describe "#update_sitemap" do
    let!(:sitemap) { Sitemap.create!(xml: "<sitemap></sitemap>") }

    before do
      allow(sitemap_builder).to receive(:generate_xml).and_return("<different-xml></different-xml>")
    end

    it "updates the first existing Sitemap record in the database" do
      expect do
        sitemap_builder.update_sitemap
        sitemap.reload
      end.to change(sitemap, :xml).to eq "<different-xml></different-xml>"
    end
  end

  describe "#generate_xml" do
    context "when an array of slugs are provided" do
      let(:slugs) { ["contact", "signs/22", "dogs"] }
      let(:hostname) { Rails.application.routes.default_url_options[:host] }

      it "returns the expected set of xml data featuring those slugs" do
        result = sitemap_builder.generate_xml(slugs)
        slugs.each do |slug|
          expect(result).to include "#{hostname}/#{slug}"
        end
      end
    end
  end

  describe "#page_slugs" do
    it { expect { sitemap_build.send(:page_slugs).to eq StaticController::PAGES } }
  end

  describe "#fetch_all_signs" do
    it "scopes to published records" do
      expect(Sign).to receive(:published)
      allow(sitemap_builder).to receive(:fetch_all_signs).and_call_original # Unstub
      sitemap_builder.send(:fetch_all_signs)
    end
  end

  describe "#sign_slugs" do
    subject { sitemap_builder.send(:sign_slugs) }
    it "returns an array of sign paths for published signs" do
      expect(subject.size).to eq signs.size
      signs.each { |sign| expect(subject).to include "/signs/#{sign.to_param}" }
    end
  end
end
