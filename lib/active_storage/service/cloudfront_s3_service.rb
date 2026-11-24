require "active_storage/service/s3_service"
require "aws-sdk-cloudfront"

module ActiveStorage
  # A version of the S3 storage service that serves reads via CloudFront
  class Service::CloudfrontS3Service < Service::S3Service
    def initialize(
      cloudfront_host:,
      cloudfront_key_pair_id: nil,
      cloudfront_private_key: nil,
      **s3_options
    )
      super(**s3_options)
      @cloudfront_host = cloudfront_host

      # buckets served via cloudfront should have acls disabled, which will result
      # in an error when attempting to set an acl. since the S3Service sets the acl
      # to "public-read" when the storage is public, we have to unset it here
      @upload_options.delete(:acl)

      return if public?

      @signer = Aws::CloudFront::UrlSigner.new(
        key_pair_id: cloudfront_key_pair_id,
        private_key: cloudfront_private_key
      )
    end

    private

    def private_url(key, expires_in:, filename:, disposition:, content_type:, **) # rubocop:disable Metrics/ParameterLists
      query = {
        "response-content-disposition" => content_disposition_with(
          type: disposition,
          filename: filename
        ),
        "response-content-type" => content_type
      }.compact.map { |k, v| "#{k}=#{ERB::Util.url_encode(v)}" }.join("&")

      @signer.signed_url("#{cloudfront_url(key)}?#{query}", expires: expires_in.from_now)
    end

    def public_url(key, **)
      cloudfront_url(key)
    end

    def cloudfront_url(key)
      "https://#{@cloudfront_host}/#{key}"
    end
  end
end
