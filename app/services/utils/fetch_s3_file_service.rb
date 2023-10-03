module Utils
  class FetchS3FileService
    def initialize(s3_key:, bucket:)
      @s3_key = s3_key
      @bucket = bucket
      @s3_service ||= Aws::S3::Resource.new
    end

    def call
      { result: @s3_service.bucket(@bucket).object(@s3_key).get.body.read }
    rescue StandardError => e
      Utils::RollbarService.error(e, s3_key: @s3_key, bucket: @bucket)
      { error: e }
    end
  end
end
