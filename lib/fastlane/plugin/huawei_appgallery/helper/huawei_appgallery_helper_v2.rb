require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class HuaweiAppgalleryHelperV2


      def self.request_access_token(client_id, client_secret)
        UI.message("Requesting access token from Huawei AppGallery ...")

        content = {'grant_type' => 'client_credentials', 'client_id' => client_id, 'client_secret' => client_secret}

        result = Net::HTTP.post(
          URI("https://connect-api.cloud.huawei.com/api/oauth2/v1/token"),
          content.to_json.encode('utf-8'),
          "Content-Type" => "application/json"
        )

        if result.code.to_i != 200
          UI.user_error!("Could not get access token from app gallery api. (HTTP #{result.code} - #{result.message})")
        end

        result_json = JSON.parse(result.body)
        access_token = result_json['access_token']
        access_token
      end


      def self.update_release_notes(client_id, access_token, app_id, release_notes)
        release_notes.each do |lang, notes|
          UI.message("Updating release notes for language #{lang} ...")

          content = {'lang' => lang, 'newFeatures' => notes}

          uri = URI("https://connect-api.cloud.huawei.com/api/publish/v2/app-language-info?appId=#{app_id}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Put.new(uri)
          request.body = content.to_json.encode('utf-8')
          request['Content-Type'] = "application/json"
          request['Authorization'] = "Bearer #{access_token}"
          request['client_id'] = client_id
          result = http.request(request)

          if result.code.to_i != 200
            UI.user_error!("Could not update release notes for #{lang}. (HTTP #{result.code} - #{result.message})")
          end
        end
      end


      def self.upload_apk(client_id, access_token, app_id, apk_path)
        # get upload url and auth code
        upload_url_result = self.get_upload_url(client_id, access_token, app_id)
        auth_code = upload_url_result['authCode']
        upload_url = upload_url_result['uploadUrl']

        # upload apk
        server_apk_url = self.upload_apk_to_api(auth_code, upload_url, apk_path)

        # update app file information
        self.update_app_file_information(client_id, access_token, app_id, server_apk_url)
      end


      def self.get_upload_url(client_id, access_token, app_id)
        UI.message("Obtaining upload url ...")

        uri = URI("https://connect-api.cloud.huawei.com/api/publish/v2/upload-url?appId=#{app_id}&suffix=apk")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{access_token}"
        request['client_id'] = client_id
        result = http.request(request)

        if result.code.to_i != 200
          UI.user_error!("Could not apk upload url from app gallery api. (HTTP #{result.code} - #{result.message})")
        end

        # result json containing "authCode", "uploadUrl"
        result_json = JSON.parse(result.body)
        result_json
      end


      def self.upload_apk_to_api(auth_code, upload_url, apk_path)
        UI.message("Uploading apk to #{upload_url} ...")

        boundary = "-----------------755754302457647"

        uri = URI(upload_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri)
        request['Accept'] = 'application/json'
        request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"

        post_body = []
        # add auth code
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"authCode\"\r\n\r\n"
        post_body << auth_code
        post_body << "\r\n"
        # add file count
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"fileCount\"\r\n\r\n"
        post_body << "1"
        post_body << "\r\n"
        # add parse type
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"parseType\"\r\n\r\n"
        post_body << "0"
        post_body << "\r\n"
        # add apk
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"release.apk\"\r\n"
        post_body << "Content-Type: multipart/form-data\r\n\r\n"
        post_body << File.read(apk_path).encode('utf-8')
        post_body << "\r\n"

        post_body << "--#{boundary}--\r\n"
        request.body = post_body.join
        result = http.request(request)

        if result.code.to_i != 200
          UI.user_error!("Could not upload apk to gallery api. (HTTP #{result.code} - #{result.message})")
        end

        # example response
        # {"result":{"UploadFileRsp":{"fileInfoList":[{"fileDestUlr":"https://developerfile7.hicloud.com/FileServer/getFile/7/appapktemp/20200727/appapk/000/000/410/0890049000000000410.20200727174607.32489040188051103716016542322538:20200727174634:2500:AD10C3C4138E988C7A1C3680440C84559E2DD6184DF5A2E1C457C23868E5F277.apk","size":86803266}],"ifSuccess":1},"resultCode":"0"}}
        result_json = JSON.parse(result.body)
        json_result_obj = result_json['result']
        json_upload_file_rsp = json_result_obj['UploadFileRsp']
        json_file_info_list = json_upload_file_rsp['fileInfoList']
        json_file_info = json_file_info_list.first()
        file_dest_url = json_file_info['fileDestUlr'] # ulr is correct

        file_dest_url
      end


      def self.update_app_file_information(client_id, access_token, app_id, apk_server_path)
        UI.message("Updating app file information ...")

        content = {
          'fileType' => 5, # type 5 = RPK or APK
          'files' => [{
            'fileName' => 'naviki-release.apk', 
            'fileDestUrl' => apk_server_path
          }]
        }

        uri = URI("https://connect-api.cloud.huawei.com/api/publish/v2/app-file-info?appId=#{app_id}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Put.new(uri)
        request.body = content.to_json.encode('utf-8')
        request['Content-Type'] = "application/json"
        request['Authorization'] = "Bearer #{access_token}"
        request['client_id'] = client_id
        result = http.request(request)

        if result.code.to_i != 200
          UI.user_error!("Could not update app file information. (HTTP #{result.code} - #{result.message})")
        end

        result_json = JSON.parse(result.body)
        json_ret = result_json['ret']
        UI.message("app-file-info ret: #{json_ret}")
      end


      def self.submit_app(client_id, access_token, app_id)
        UI.message('Submitting app for review ...')

        # should be in format yyyy-MM-dd'T'HH:mm:ssZZ, must be escaped to be GET param
        # https://apidock.com/ruby/DateTime/strftime
        # https://www.shortcutfoo.com/app/dojos/ruby-date-format-strftime/cheatsheet
        release_time = CGI::escape(Time.now.utc.strftime("%FT%T%z")) # as soon as possible
        UI.message("Use release time #{release_time}")

        uri = URI("https://connect-api.cloud.huawei.com/api/publish/v2/app-submit?appId=#{app_id}&releaseTime=#{release_time}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = "application/json"
        request['Accept'] = 'application/json'
        request['Authorization'] = "Bearer #{access_token}"
        request['client_id'] = client_id
        result = http.request(request)

        if result.code.to_i != 200
          UI.user_error!("Could not submit app for review. (HTTP #{result.code} - #{result.message})")
        end

        result_json = JSON.parse(result.body)
        json_ret = result_json['ret']
        UI.message("app-submit ret: #{json_ret}")
      end
    end
  end
end
