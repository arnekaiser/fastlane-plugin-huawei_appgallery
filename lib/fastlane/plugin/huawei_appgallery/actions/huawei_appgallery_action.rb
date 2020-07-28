require 'fastlane/action'

module Fastlane
  module Actions
    class HuaweiAppgalleryAction < Action
      def self.run(params)
        access_token = Helper::HuaweiAppgalleryHelperV2.request_access_token(params[:client_id], params[:client_secret])
        Helper::HuaweiAppgalleryHelperV2.update_release_notes(params[:client_id], access_token, params[:app_id], params[:release_notes])
        Helper::HuaweiAppgalleryHelperV2.upload_apk(params[:client_id], access_token, params[:app_id], params[:apk_path])
        Helper::HuaweiAppgalleryHelperV2.submit_app(params[:client_id], access_token, params[:app_id])
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
          FastlaneCore::ConfigItem.new(key: :client_secret,
                                  env_name: "HUAWEI_APPGALLERY_CLIENT_SECRET",
                               description: "Client Secret of an AppGallery Connect API client",
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
