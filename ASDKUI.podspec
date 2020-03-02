Pod::Spec.new do |s|
  s.name         = "ASDKUI"
  s.version      = "1.5.0"
  s.summary      = "UI components library for internet acquiring from Tinkoff Bank"
  s.description  = "UI components library for internet acquiring from Tinkoff Bank!"
  s.homepage     = "https://www.tinkoff.ru"
  s.license      = "{ :type => 'Apache 2.0' }"  
  s.author       = { "d.tarasov" => "d.tarasov@tinkoff.ru" } 
  s.platform     = :ios
  s.ios.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/TinkoffCreditSystems/tinkoff-asdk-ios.git", :tag => "#{s.version}" }

  s.source_files  = "ASDKUI", "ASDKUI/**/*.{h,m}"
  s.resources = "ASDKUI/Resources/**/*.*" , "ASDKUI/**/*.{xib}"

  

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "ASDKCore"

end
