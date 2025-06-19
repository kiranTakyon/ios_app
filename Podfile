platform :ios, '14.0'
workspace 'Ambassador Education.xcworkspace'

def shared_pods
  use_frameworks!

  pod 'DGActivityIndicatorView'
  pod 'SkyFloatingLabelTextField', '~> 3.0'
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'MBCalendarKit', '~> 5.0.0'
  pod 'MXSegmentedPager'
  pod 'DropDown'
  pod 'RichEditorView'
  pod 'DatePickerDialog'
  pod 'CCBottomRefreshControl'
  pod 'FSCalendar' 
  pod 'BIZPopupView'
  pod 'SwiftSoup'
  pod 'FirebaseCore', '~> 11.10.0'
  pod 'FirebaseMessaging', '~> 11.10.0'
  pod 'FirebaseAnalytics', '~> 11.10.0'
  pod 'FirebaseCrashlytics', '~> 11.10.0'
  pod 'GoogleSignIn', '~> 8.0.0'
  pod 'SCLAlertView'
  pod 'EzPopup'
  pod 'Updates'
  pod 'Zip'
  pod 'SDWebImage'
end

target 'LPS' do
  shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      if target.respond_to?(:product_type) && target.product_type == "com.apple.product-type.bundle"
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
