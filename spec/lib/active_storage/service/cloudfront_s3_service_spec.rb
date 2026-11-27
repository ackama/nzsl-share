# spec/lib/active_storage/service/cloudfront_s3_service_spec.rb
require "rails_helper"
require "active_storage/service/cloudfront_s3_service"

RSpec.describe ActiveStorage::Service::CloudfrontS3Service do
  def build_service(**options)
    described_class.new(
      bucket: "test-bucket",
      region: "ap-southeast-2",
      stub_responses: true,
      cloudfront_host: "files.example.test",
      cloudfront_key_pair_id: "KTEST",
      cloudfront_private_key: OpenSSL::PKey::RSA.new(2048).to_pem,
      **options
    )
  end

  it "signs private urls, including the response overrides" do
    url = build_service.url(
      "abc",
      expires_in: 5.minutes,
      filename: ActiveStorage::Filename.new("a b.mp4"),
      disposition: :attachment,
      content_type: "video/mp4"
    )
    uri = URI(url)
    params = URI.decode_www_form(uri.query).to_h

    expect(uri.host).to eq "files.example.test"
    expect(params["response-content-disposition"]).to start_with 'attachment; filename="a b.mp4"'
    expect(params["response-content-type"]).to eq "video/mp4"
    expect(params).to include("Expires", "Signature", "Key-Pair-Id")
  end

  it "returns unsigned urls and sends no acl when public" do
    service = build_service(public: true)

    expect(service.url("abc")).to eq "https://files.example.test/abc"
    expect(service.upload_options).not_to have_key(:acl)
  end
end
