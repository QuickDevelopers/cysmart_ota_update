#
#  Be sure to run `pod spec lint cysmart_ota_update.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|


  spec.name         = "cysmart_ota_update"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of cysmart_ota_update."

 
  spec.description  = <<-DESC
	This is quickly Bluetooth help connect, it is help quick more device connect. so you use very smart!
                   DESC

  spec.homepage     = "https://github.com/QuickDevelopers/cysmart_ota_update"
  

  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  
  spec.author             = { "ArdWang" => "278161009@qq.com" }
  
  spec.platform     = :ios, "11.0"
  spec.ios.deployment_target = "11.0"

 

  spec.source       = { :git => "https://github.com/QuickDevelopers/cysmart_ota_update.git", :tag => "#{spec.version}" }


  spec.source_files  = "cysmart_ota_update", "cysmart_ota_update/Upgrade/*.{h,m}"
                 
  spec.frameworks = "Foundation","UIKit","CoreBluetooth"
                 
                        
end
