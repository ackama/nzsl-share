module SignRequestsHelper
  def facebook_requests_url
    "https://www.facebook.com/groups/213136893357675/"
  end

  def sign_requests_video_sources
    [
      "https://#{s3_bucket_name}.s3.ap-southeast-2.amazonaws.com/assets/sign-requests-1080.mp4",
      "https://#{s3_bucket_name}.s3.ap-southeast-2.amazonaws.com/assets/sign-requests-1080.webm",
      "https://#{s3_bucket_name}.s3.ap-southeast-2.amazonaws.com/assets/sign-requests-720.mp4",
      "https://#{s3_bucket_name}.s3.ap-southeast-2.amazonaws.com/assets/sign-requests-720.webm"
    ]
  end

  private

  def s3_bucket_name
    ENV.fetch("S3_BUCKET_NAME", nil)
  end
end
