Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftMacOSAppKit"

  spec.version      = "1.2.0"
  
  spec.summary      = "Swift code for macOS development, encapsulation library. Basic components. Minimum support Mac 12.0"

  spec.description  = <<-DESC
                        Swift code for macOS development, encapsulation library. Basic components. Minimum support Mac 12.0. This library provides a set of high-level UI components and utilities to help developers build macOS applications more efficiently.
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift"

  spec.license      = "MIT"

  spec.author       = { "田风有" => "420144542@qq.com" }

  spec.platform     = :osx
  spec.osx.deployment_target = "13.0"
  spec.swift_version = '5.0'

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
    'SWIFT_VERSION' => '5.0',
    'SWIFT_OPTIMIZATION_LEVEL' => '-Onone'
  }

end