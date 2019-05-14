platform :android do
  lane :build do
    # fastlane plugin added by running `fastlane add_plugin android_keystore`
    output_directory = android_keystore(generate_cordova_release_signing: false)
    sh ("cd .. && mkdir .android_signing")
    keytool_parts = [
            "keytool -genkey -v",
            "-keystore .android_signing/#{ENV['ANDROID_KEYSTORE_KEYSTORE_NAME']}",
            "-alias #{ENV['ANDROID_KEYSTORE_ALIAS_NAME']}",
            "-keyalg RSA -keysize 2048 -validity 10000",
            "-storepass #{ENV['ANDROID_KEYSTORE_PASSWORD']} ",
            "-keypass #{ENV['ANDROID_KEYSTORE_KEY_PASSWORD']}",
            "-storetype pkcs12",
            "-dname \"CN=#{ENV['ANDROID_KEYSTORE_FULL_NAME']}", 
            ",OU=#{ENV['ANDROID_KEYSTORE_ORG_UNIT']}", 
            ",O=#{ENV['ANDROID_KEYSTORE_ORG']}", 
            ",L=#{ENV['ANDROID_KEYSTORE_CITY_LOCALITY']}", 
            ",S=#{ENV['ANDROID_KEYSTORE_STATE_PROVINCE']}",
            ",C=#{ENV['ANDROID_KEYSTORE_COUNTRY']}\"",
          ]
    sh "(cd .. && #{keytool_parts.join(" ")})"
    
    UI.user_error! "`android_keystore` directory needs to exists" unless File.directory?(output_directory)
    
    # prepare Android platform to Nativescript project
    sh "(cd .. && tns prepare android)"
    
    # Copy contents of ".android_signing" to platforms/android
    FileUtils.cp_r Dir.glob("#{output_directory}/*"), '../platforms/android'
    
    # Build Android release APK(TODO: extra parameters for siging
    # --key-store-path C:\keystore\Telerik.keystore --key-store-password sample_password --key-store-alias Telerik --key-store-alias-password sample_password)
    # sh "(cd .. && tns build android --release )"
    sh "(cd .. && tns cloud build android --release --key-store-path .android_signing/#{ENV['ANDROID_KEYSTORE_KEYSTORE_NAME']} --keyStorePassword #{ENV['ANDROID_KEYSTORE_PASSWORD']} --key-store-alias #{ENV['ANDROID_KEYSTORE_ALIAS_NAME']} --key-store-alias-password #{ENV['ANDROID_KEYSTORE_KEY_PASSWORD']} --bundle webpack --env.uglify --env.aot --env.snapshot --accountId=1 )"
    
    # Get APK path
    apk_path = Dir.glob(File.join(Dir.pwd, "../.cloud/android/*.apk")).first
    apk_path = File.absolute_path apk_path
    UI.success "Successfully built APK: #{apk_path}"

    #upload to playstore
    sh "(cd .. && fastlane supply --apk #{apk_path} --track rollout --rollout 0.5)"
    UI.success "Successfully uploaded APK"
  end
end


platform :ios do
  lane :build do
    
    # Create app in the iOS dev center
    # produce(
    #   app_name: 'FastlaneScreencast',
    #   language: 'English',
    #   app_version: '1.0',
    #   # sku: 'FastlaneScreencast_001',
      
    #   # skip_itc: true # this will only create the app in the iOS dev center
    # )
    
    # Create distribution cert
    # cert
    
    # Create/fetch provisioning profile
    # profile_uuid = sigh
    
    # Create/fetch distribution cert and provisioning profile
    match(type:"appstore",output_path:".cert/")

    # prepare iOS platform
    sh "(cd .. && tns prepare ios)"
    
    

    # Get certificate and provsion path
    p12_path = Dir.glob(File.join(Dir.pwd, "../.cert/*.p12")).first
    p12_path = File.absolute_path p12_path
    cert_path = Dir.glob(File.join(Dir.pwd, "../.cert/*.cer")).first
    cert_path = File.absolute_path cert_path
    sh "(cd .. && openssl x509 -inform der -in #{cert_path} -out .cert/cert.pem)"
    sh "(cd .. && openssl pkcs12 -export -out .cert/cert.p12 -inkey #{p12_path} -in .cert/cert.pem -password pass:liamtoh666)"
    provision_path = Dir.glob(File.join(Dir.pwd, "../.cert/*.mobileprovision")).first
    provision_path = File.absolute_path provision_path
    UI.success "Successfully built IPA: #{cert_path}"
    UI.success "Successfully built IPA: #{provision_path}"

    # Build iOS release IPA
    sh "(cd .. && tns cloud build ios --release --accountId=1 --bundle --env.uglify --env.production --env.snapshot --certificate=\".cert/cert.p12\" --provision=\"#{provision_path}\" --certificatePassword=liamtoh666)"
    
    # Get IPA path
    ipa_path = Dir.glob(File.join(Dir.pwd, "../.cloud/ios/device/*.ipa")).first
    ipa_path = File.absolute_path ipa_path
    UI.success "Successfully built IPA: #{ipa_path}"
    deliver(ipa:ipa_path,submit_for_review:true,automatic_release: true,force:true)
  end
end
