Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftMacOSAppKit"

  spec.version      = "1.4.1"
  
  spec.summary      = "AppKit-focused macOS Swift toolkit with chain APIs, custom controls, HUD, status item, and utilities."

  spec.description  = <<-DESC
                        TFYSwiftMacOSAppKit is a macOS AppKit toolkit written in Swift.
                        It provides chain-style APIs, custom controls, category extensions,
                        status item presentation, HUD components, cache/JSON/timer/GCD utilities,
                        and a fully upgraded demo app for real-world integration and verification.
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift"

  spec.license      = "MIT"

  spec.author       = { "田风有" => "420144542@qq.com" }

  spec.platform     = :osx
  spec.osx.deployment_target = "13.5"
  spec.swift_version = '5.0'
  spec.default_subspecs = 'macOSBase', 'macOSfoundation', 'macOScategory', 'macOScontainer', 'macOSchain', 'macOSHUD'

  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift.git", :tag => spec.version }

  # 1. 基础组件
  spec.subspec 'macOSBase' do |ss|
    ss.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSBase/**/*.{swift}"
  end

  # 2. Foundation 扩展
  spec.subspec 'macOSfoundation' do |ss|
    ss.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSfoundation/**/*.{swift}"
    ss.dependency 'TFYSwiftMacOSAppKit/macOSBase'
  end

  # 3. 类别扩展
  spec.subspec 'macOScategory' do |ss|
    ss.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOScategory/**/*.{swift}"
    ss.dependency 'TFYSwiftMacOSAppKit/macOSBase'
    ss.dependency 'TFYSwiftMacOSAppKit/macOSfoundation'
  end

  # 4. 容器组件
  spec.subspec 'macOScontainer' do |ss|
    ss.dependency 'TFYSwiftMacOSAppKit/macOSBase'
    ss.dependency 'TFYSwiftMacOSAppKit/macOSfoundation'
    ss.dependency 'TFYSwiftMacOSAppKit/macOScategory'
    
    ss.subspec 'macOSStatusItem' do |sss|
      sss.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOScontainer/macOSStatusItem/**/*.{swift}"
    end
    
    ss.subspec 'macOSUtils' do |sss|
      sss.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOScontainer/macOSUtils/**/*.{swift}"
    end
  end

  # 5. 链式编程模块
  spec.subspec 'macOSchain' do |ss|
    ss.dependency 'TFYSwiftMacOSAppKit/macOSBase'
    ss.dependency 'TFYSwiftMacOSAppKit/macOSfoundation'
    ss.dependency 'TFYSwiftMacOSAppKit/macOScategory'
    ss.dependency 'TFYSwiftMacOSAppKit/macOScontainer'
    
    ss.subspec 'macOSCALayer' do |sss|
      sss.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSchain/macOSCALayer/**/*.{swift}"
    end
    
    ss.subspec 'macOSView' do |sss|
      sss.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSchain/macOSView/**/*.{swift}"
      sss.dependency 'TFYSwiftMacOSAppKit/macOSchain/macOSCALayer'
    end
    
    ss.subspec 'macOSGesture' do |sss|
      sss.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSchain/macOSGesture/**/*.{swift}"
      sss.dependency 'TFYSwiftMacOSAppKit/macOSchain/macOSView'
    end
  end

  # 6. HUD 组件
  spec.subspec 'macOSHUD' do |ss|
    ss.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSHUD/**/*.{swift}"
    ss.dependency 'TFYSwiftMacOSAppKit/macOSBase'
    ss.dependency 'TFYSwiftMacOSAppKit/macOSchain'
  end

  # 添加编译选项
  spec.pod_target_xcconfig = { 
    'SWIFT_VERSION' => '5.0'
  }

end
