# Uncomment this line to define a global platform for your project
#ENV['SWIFT_VERSION'] = '5'
platform :ios, '12.0'
workspace 'Ambassador Education.xcworkspace'
#target 'T360' do

def shared_pods
  use_frameworks!
  pod 'DGActivityIndicatorView'
  pod 'SkyFloatingLabelTextField', '~> 3.0'
  pod 'Toast-Swift', '~> 2.0.0'
  pod 'RichEditorView'
  pod 'MBCalendarKit', '~> 5.0.0'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'MXSegmentedPager'
  pod 'DropDown'
  pod 'DatePickerDialog'
  pod 'CCBottomRefreshControl'
  pod 'FSCalendar'
  pod 'BIZPopupView'
  pod 'SwiftSoup'
  pod 'FirebaseAnalytics', '~> 7.0.0'
  pod 'FirebaseDatabase', '~> 7.0.0'
  pod 'SCLAlertView'
  pod 'GGLInstanceID'
  pod 'FirebaseMessaging'
  pod 'EzPopup'
  pod "Updates"
  pod 'GoogleSignIn'
  pod 'Zip'
  pod 'SDWebImage'


  
end


#target 'PEPS V2' do
#  shared_pods
#end

target 'OrisonSchool V2' do
#target 'EPS' do
  shared_pods
end

#pod 'Google/AdMob'
# Pods for Ambassador Education
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Set the minimum deployment target to iOS 12.0
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'

      # Exclude arm64 architecture for the simulator
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"

      # Disable code signing for bundle product types
      if target.respond_to?(:product_type) && target.product_type == "com.apple.product-type.bundle"
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
