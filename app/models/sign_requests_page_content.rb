class SignRequestsPageContent
  def self.facebook_requests_url
    "https://www.facebook.com/groups/213136893357675/"
  end

  def self.sign_requests_video_sources
    [
      "https://#{s3_bucket_name}.s3.ap-southeast-2.amazonaws.com/assets/sign-requests-1080.mp4",
      "https://#{s3_bucket_name}.s3.ap-southeast-2.amazonaws.com/assets/sign-requests-1080.webm",
      "https://#{s3_bucket_name}.s3.ap-southeast-2.amazonaws.com/assets/sign-requests-720.mp4",
      "https://#{s3_bucket_name}.s3.ap-southeast-2.amazonaws.com/assets/sign-requests-720.webm"
    ]
  end

  def self.s3_bucket_name
    "nzsl-share-production-uploaded-files"
  end
end
