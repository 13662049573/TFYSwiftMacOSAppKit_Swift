Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftMacOSAppKit"

  spec.version      = "1.1.5"
  
  spec.summary      = "Swift code for macOS development, encapsulation library. Basic components. Minimum support Mac 12.0"

  spec.description  = <<-DESC
                        Swift code for macOS development, encapsulation library. Basic components. Minimum support Mac 12.0
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift"

  spec.license      = "MIT"

  spec.author       = { "田风有" => "420144542@qq.com" }

  spec.osx.deployment_target = "12.0"

  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift.git", :tag => spec.version }

  spec.source_files = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/**/*.{swift}"

  spec.subspec 'macOScategory' do |ss|
    ss.source_files  = "TFYSwiftMacOSAppKit/macOScategory/**/*.{swift}"
  end

  spec.subspec 'macOSchain' do |ss|
    ss.subspec 'macOSBase' do |sss|
       sss.source_files  = "TFYSwiftMacOSAppKit/macOSchain/macOSBase/**/*.{swift}"
    end
    ss.subspec 'macOSCALayer' do |sss|
       sss.source_files  = "TFYSwiftMacOSAppKit/macOSchain/macOSCALayer/**/*.{swift}"
    end
    ss.subspec 'macOSView' do |sss|
       sss.source_files  = "TFYSwiftMacOSAppKit/macOSchain/macOSView/**/*.{swift}"
    end
    ss.subspec 'macOSGesture' do |sss|
       sss.source_files  = "TFYSwiftMacOSAppKit/macOSchain/macOSGesture/**/*.{swift}"
    end
  end

  spec.subspec 'macOSfoundation' do |ss|
    ss.source_files  = "TFYSwiftMacOSAppKit/macOSfoundation/**/*.{swift}" 
  end

  spec.subspec 'macOScontainer' do |ss|
    ss.subspec 'macOSStatusItem' do |sss|
      sss.source_files  = "TFYSwiftMacOSAppKit/macOScontainer/macOSStatusItem/**/*.{swift}"
    end
    ss.subspec 'macOSUtils' do |sss|
      sss.source_files  = "TFYSwiftMacOSAppKit/macOScontainer/macOSUtils/**/*.{swift}"
    end
  end

end