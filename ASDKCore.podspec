#
#  Be sure to run `pod spec lint ASDKCore.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ASDKCore"
  s.version      = "1.5.0"
  s.summary      = "Core library that allows you to use internet acquiring from Tinkoff Bank in your app"
  s.description  = "Core library that allows you to use internet acquiring from Tinkoff Bank in your app!"

  s.homepage     = "https://www.tinkoff.ru"
  s.license      = "{ :type => 'Apache 2.0' }"
  
  s.author             = { "d.tarasov" => "d.tarasov@tinkoff.ru" } 
  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/TinkoffCreditSystems/tinkoff-asdk-ios.git", :tag => "#{s.version}" }
  s.source_files  = "ASDKCore", "ASDKCore/**/*.{h,m}"
  s.requires_arc = true

end
