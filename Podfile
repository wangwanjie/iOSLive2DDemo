source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
platform :ios, '9.0'
inhibit_all_warnings!

targetsArray = ['iOSLive2DDemo']

def debug_pods
    pod 'LookinServer', :configurations => ['Debug']
end

# 引入部分组件使用 :subspecs => ['HDMediator', 'ScanCode']

def remote_pods
  pod 'YYModel'
end

def pods
end

targetsArray.each do |_target|
  target _target do
    debug_pods
    remote_pods
    pods
  end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['ENABLE_STRICT_OBJC_MSGSEND'] = "NO"
            config.build_settings['ENABLE_BITCODE'] ='NO'
        end
    end
end
