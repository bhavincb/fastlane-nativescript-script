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
