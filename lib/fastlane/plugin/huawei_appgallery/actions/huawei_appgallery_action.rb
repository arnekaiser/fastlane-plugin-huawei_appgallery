require 'fastlane/action'
require_relative '../helper/huawei_appgallery_helper'

module Fastlane
  module Actions
    class HuaweiAppgalleryAction < Action
      def self.run(params)
        cookie = Helper::HuaweiAppgalleryHelper.request_cookie(params[:client_id], params[:time], params[:signature])
        Helper::HuaweiAppgalleryHelper.update_release_notes(cookie, params[:app_id], params[:release_notes])
        Helper::HuaweiAppgalleryHelper.upload_apk(cookie, params[:app_id], params[:apk_path])
        Helper::HuaweiAppgalleryHelper.submit_app(cookie, params[:app_id])
        UI.message('Finished!')
      end

      def self.description
        "Plugin to deploy an app to the Huawei AppGallery"
      end

      def self.authors
        ["Arne Kaiser"]
      end

      def self.return_value
        # no return value
      end

      def self.details
        "Updates the release notes, uploads an APK and submits the new version for review."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :client_id,
                                  env_name: "HUAWEI_APPGALLERY_CLIENT_ID",
                               description: "Client ID of an AppGallery Connect API client",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :time,
                                  env_name: "HUAWEI_APPGALLERY_TIME",
                               description: "Time in milliseconds since 1970, which was used to create the signature",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :signature,
                                  env_name: "HUAWEI_APPGALLERY_SIGNATURE",
                               description: "Signature which needs to be created by your own. Example code: https://developer.huawei.com/consumer/en/service/hms/catalog/publishingAPI.html?page=hmssdk_appGalleryConnect_devguide",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                  env_name: "HUAWEI_APPGALLERY_APP_ID",
                               description: "Application ID of your app",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :apk_path,
                                  env_name: "HUAWEI_APPGALLERY_APK_PATH",
                               description: "Path to your APK file",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :release_notes,
                                  env_name: "HUAWEI_APPGALLERY_RELEASE_NOTES",
                               description: "Dictionary with language codes as the keys and the release notes as the values",
                                  optional: false,
                                      type: Hash)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
