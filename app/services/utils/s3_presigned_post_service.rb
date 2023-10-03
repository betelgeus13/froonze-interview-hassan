# frozen_string_literal: true

module Utils
  class S3PresignedPostService
    UPLOAD_DATA = {
      WISHLIST_IMPORT = 'wishlist_import' => {
        bucket: :import,
        return_download_url: false,
        acl: 'bucket-owner-full-control',
        prefix: 'wishlist'
      },
      CUSTOM_FORMS = 'custom_forms' => {
        bucket: :custom_forms,
        return_download_url: true,
        acl: 'public-read',
        prefix: 'custom-forms',
        cache_control: 'max-age=2592000,public'
      },
      PUBLIC_FILE = 'email_logo' => {
        bucket: :public_files,
        return_download_url: true,
        acl: 'public-read',
        prefix: 'email-logo',
        cache_control: 'max-age=2592000,public'
      },
      LOYALTY_IMPORT = 'loyalty_import' => {
        bucket: :import,
        return_download_url: false,
        acl: 'bucket-owner-full-control',
        prefix: 'loyalty'
      }
    }

    def initialize(file_name:, shop:, reason:)
      @file_name = file_name.split('.').first
      @extension = file_name.split('.')[1..-1].join('.')
      @shop = shop
      @reason = reason
      @data = UPLOAD_DATA[reason]
    end

    def call
      return { error: "Reason: #{@reason} is not supported" } if @data.blank?

      @s3_bucket = Aws::S3::Resource.new.bucket(Rails.application.credentials.aws[:buckets][@data[:bucket]])

      {
        presigned_post:,
        url: presigned_url.url,
        download_url:
      }
    end

    private

    def presigned_url
      params = {
        key: object_key,
        acl: @data[:acl],
        cache_control: @data[:cache_control]
      }.compact

      @presigned_url ||= @s3_bucket.presigned_post(**params)
    end

    def object_key
      @object_key ||= "#{@data[:prefix]}/#{shop_name}/#{unique_file_name}"
    end

    def shop_name
      @shop_name ||= @shop.name.parameterize
    end

    def unique_file_name
      @unique_file_name ||= "#{@file_name.parameterize}--#{SecureRandom.uuid}.#{@extension}"
    end

    def presigned_post
      presigned_url.fields.map { |k, v| { name: k, value: v } }
    end

    def download_url
      return nil unless @data[:return_download_url]

      s3_bucket_url = Rails.application.credentials.aws.dig(:buckets_url, @data[:bucket]).presence || presigned_url.url
      "#{s3_bucket_url}/#{object_key}"
    end
  end
end
