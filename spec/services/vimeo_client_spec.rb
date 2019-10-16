require "rails_helper"

RSpec.describe VimeoClient, type: :service do
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  subject { VimeoClient.new { |conn| conn.adapter(:test, stubs) } }

  it "has methods corresponding to each HTTP verb" do
    %i[get post patch put delete].each do |verb|
      expect(subject).to respond_to verb
    end
  end

  it "raises wrapped HTTP errors" do
    stubs.get("/ua-test") { [422] }
    expect { subject.get("/ua-test") }.to raise_error VimeoClient::Error do |err|
      expect(err.cause).to be_a Faraday::ClientError
      expect(err.cause.response[:status]).to eq 422
    end
  end

  it "communicates with an identiable user agent" do
    stubs.get("/ua-test") do |env|
      expect(env.request_headers["User-Agent"]).to start_with "NZSL Share"
    end

    subject.get("/ua-test")
  end

  describe "with built in configuration" do
    it "makes a GET request with the expected request data" do
      stubs.get("/test") do |env|
        expect(env.request_headers["Authorization"]).to be_present
        expect(env.url.host).to eq "api.vimeo.com"
        expect(env.params).to eq("in_test" => "true")
        [200, { "Content-Type" => "application/json" }, '{"success": true}']
      end

      expect(subject.get("/test", in_test: true).success).to eq true
      stubs.verify_stubbed_calls
    end

    it "makes a POST request with the expected request data" do
      stubs.post("/post-test") do |env|
        expect(env.request_headers["Authorization"]).to be_present
        expect(env.url.host).to eq "api.vimeo.com"
        expect(env.body).to eq(in_test: true)
        [200, { "Content-Type" => "application/json" }, '{"success": true}']
      end

      expect(subject.post("/post-test", in_test: true).success).to eq true
      stubs.verify_stubbed_calls
    end
  end

  describe "with custom configuration" do
    subject { described_class.new(host: "https://mycustomhost.example.com") { |conn| conn.adapter(:test, stubs) } }

    it "uses this configuration when making requests" do
      stubs.get("/test") do |env|
        expect(env.url.host).to eq "mycustomhost.example.com"
        [200, { "Content-Type" => "application/json" }, '{"success": true}']
      end

      expect(subject.get("/test").success).to eq true
      stubs.verify_stubbed_calls
    end
  end

  describe "when an error is unexpected"
end
