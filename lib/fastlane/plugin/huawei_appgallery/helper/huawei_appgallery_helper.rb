require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class HuaweiAppgalleryHelper
      def self.request_cookie(client_id, time, signature)
        UI.message("Requesting cookie from Huawei AppGallery ...")
        content = { 'key_string' => { 'clientId' => client_id, 'time' => time, 'sign' => signature } }
        result = Net::HTTP.post(
          URI('https://connect-api.cloud.huawei.com/api/common/v1/connect'),
          content.to_json.encode('utf-8'),
          "Accept" => "application/json"
        )
        cookie = result['set-cookie']
        if cookie.nil?
          UI.user_error!("Authentication failed: #{result.body}")
        end
        cookie.split('; ')[0]
      end

      def self.update_release_notes(cookie, app_id, release_notes)
        release_notes.each do |lang, notes|
          UI.message("Updating release notes for language #{lang} ...")

          uri = URI("https://connect-api.cloud.huawei.com/api/publish/v1/appInfo/#{app_id}?lang=#{lang}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Get.new(uri)
          request['Cookie'] = cookie
          request['Accept'] = 'application/json'

          result = http.request(request)

          if result.code.to_i != 200
            UI.user_error!("Cannot retrieve language information for language #{lang}!")
          end

          # get values for mandatory parameters
          result_json = JSON.parse(result.body)
          app_name = result_json['languages'][0]['appName']
          app_desc = result_json['languages'][0]['appDesc']
          brief_info = result_json['languages'][0]['briefInfo']

          if app_name.nil? || app_desc.nil? || brief_info.nil?
            UI.user_error!("Cannot retrieve language information for language #{lang}!")
          end

          # set new release notes
          content = {
            'appName' => app_name,
            'appDesc' => app_desc,
            'briefInfo' => brief_info,
            'newFeatures' => notes
          }

          uri = URI("https://connect-api.cloud.huawei.com/api/publish/v1/languageInfo/#{app_id}/#{lang}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Put.new(uri)
          request.body = content.to_json.encode('utf-8')
          request['Cookie'] = cookie
          request['Content-Type'] = 'application/json'
          result = http.request(request)
          if result.code.to_i != 200
            UI.user_error!("Cannot update language information for language #{lang}!")
          end
        end
      end

      def self.upload_apk(cookie, app_id, apk_path)
        unless File.file?(apk_path)
          UI.user_error!("Cannot read apk at: #{apk_path}")
        end

        # obtain upload url
        UI.message("Obtaining upload url ...")
        uri = URI("https://connect-api.cloud.huawei.com/api/publish/v1/uploadUrl?suffix=apk&appId=#{app_id}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri)
        request['Cookie'] = cookie
        request['Accept'] = 'application/json'
        result = http.request(request)
        result_json = JSON.parse(result.body)
        upload_url = result_json['uploadUrl'] # this is the upload server
        auth_code = result_json['authCode']
        if result.code.to_i != 200 || upload_url.nil? || auth_code.nil?
          UI.user_error!("Cannot obtain upload url! Result: #{result_json}")
        end

        # upload apk
        UI.message("Uploading apk to #{upload_url} ...")
        boundary = "755754302457647"
        uri = URI("https://#{upload_url}/api/publish/v1/uploadFile")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri)
        request['Cookie'] = cookie
        request['Accept'] = 'application/json'
        request['Content-Type'] = "multipart/form-data, boundary=#{boundary}"

        post_body = []
        # add the auth code
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"authCode\"\r\n\r\n"
        post_body << auth_code
        # add the apk
        post_body << "\r\n--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"release.apk\"\r\n"
        post_body << "Content-Type: multipart/form-data\r\n\r\n"
        post_body << File.read(apk_path).encode('utf-8')
        post_body << "\r\n--#{boundary}--\r\n"
        request.body = post_body.join

        result = http.request(request)
        result_json = JSON.parse(result.body)
        upload_url = result_json['uploadUrl']

        # update app file informnation
        UI.message("Updating app file information ...")
        content = {
          'type' => 5, # type 5 = RPK or APK
          'data' => upload_url
        }
        uri = URI("https://connect-api.cloud.huawei.com/api/publish/v1/mediaInfo/#{app_id}/en-US") # assumes that en-US is the default language
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Put.new(uri)
        request.body = content.to_json.encode('utf-8')
        request['Cookie'] = cookie
        request['Content-Type'] = 'application/json'
        result = http.request(request)
        if result.code.to_i != 200
          UI.user_error!("Cannot upload apk!")
        end
      end

      def self.submit_app(cookie, app_id)
        UI.message('Submitting app for review ...')
        uri = URI("https://connect-api.cloud.huawei.com/api/publish/v1/submit/#{app_id}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri)
        request['Cookie'] = cookie
        request['Accept'] = 'application/json'
        request['Content-Type'] = "application/json"
        content = { 'releaseTime' => (Time.now.to_f * 1000).to_i.to_s } # as soon as possible
        request.body = content.to_json.encode('utf-8')
        result = http.request(request)
        if result.code.to_i != 200
          UI.user_error!("Cannot submit app!")
        end
      end
    end
  end
end
