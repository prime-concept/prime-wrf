use_frameworks!
inhibit_all_warnings!
platform :ios, '13.0'

def shared_pods
  pod 'Alamofire', '~> 4.8'
  pod 'AnyFormatKit', '~> 2.0'
  pod 'AutoInsetter'
  pod 'Branch'
  pod 'CTPanoramaView', '~> 1.3'
  pod 'DeviceKit', '~> 5.2.2'
  pod 'Firebase/Analytics', '~> 10.23'
  pod 'Firebase/Messaging', '~> 10.23'
  pod 'FirebaseCrashlytics', '~> 10.23'
  pod 'FloatingPanel', :git => 'https://github.com/Hayk91K/FloatingPanel', :commit => 'da1aedf3d1c9ed8e16c2cada819ec78a463f3433'
  pod 'GoogleMaps', '~> 3.4'
  pod 'IQKeyboardManagerSwift', '~> 6.3'
  pod 'JTAppleCalendar', '~> 7.1'
  pod 'libPhoneNumber-iOS'
  pod 'MBProgressHUD', '~> 1.1'
  pod 'Nuke', '~> 7.6'
  pod 'PhoneNumberKit', '~> 3.3'
  pod 'PromiseKit', '~> 6.8'
  pod 'RealmSwift', '~> 10.7'
  pod 'SkyFloatingLabelTextField', '~> 3.7'
  pod 'SnapKit', '~> 4.2'
  pod 'SwiftKeychainWrapper', '~> 3.3'
  pod 'Tabman', '~> 2.4'
  pod 'TagListView', '~> 1.4'
  pod 'YandexMobileMetrica/Dynamic/Core', '~> 3.8'
  pod 'YoutubeKit', '~> 0.5'
end

target 'PrimeGuideCore' do
  shared_pods
end

target 'MaisonDellos' do
  pod 'ChatSDK', :git => 'https://git.lgn.me/technolab/pr1me/chat_ios.git', :tag => '1.0.2'
end

target 'WRF' do
  pod 'ChatSDK', :git => 'https://git.lgn.me/technolab/pr1me/chat_ios.git', :tag => '1.0.2'
end

target '101' do
  pod 'ChatSDK', :git => 'https://git.lgn.me/technolab/pr1me/chat_ios.git', :tag => '1.0.2'
end

target 'FHConcepts' do
  pod 'ChatSDK', :git => 'https://git.lgn.me/technolab/pr1me/chat_ios.git', :tag => '1.0.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings["DEVELOPMENT_TEAM"] = "3BN8524HDR"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings["OTHER_SWIFT_FLAGS"] = "-no-verify-emitted-module-interface"
    end
  end
end
