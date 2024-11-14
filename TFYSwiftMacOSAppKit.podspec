Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftMacOSAppKit"

  spec.version      = "1.1.1"

  spec.summary      = "swift 版纯代码进行写macOS 开发，封装库。基本组件。最低支持Mac 12.4"

  spec.description  = <<-DESC
                        swift 版纯代码进行写macOS 开发，封装库。基本组件。最低支持Mac 12.4
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift"
  
  spec.license      = "MIT"

  spec.author       = { "田风有" => "420144542@qq.com" }
  
  spec.osx.deployment_target = "12.4"
  
  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftMacOSAppKit_Swift.git", :tag => spec.version }


  spec.subspec 'macOScategory' do |ss|
    ss.source_files  = "TFYSwiftMacOSAppKit/macOScategory/**/*.{swift}"
    ss.dependency "macOScontainer/macOSUtils"
    ss.dependency "macOSfoundation"
  end

  spec.subspec 'macOSchain' do |ss|
    ss.source_files  = "TFYSwiftMacOSAppKit/macOSchain/**/*.{swift}"
  end

  spec.subspec 'macOSfoundation' do |ss|
    ss.source_files  = "TFYSwiftMacOSAppKit/macOSfoundation/**/*.{swift}"
  end

  spec.subspec 'macOScontainer' do |ss|
    ss.source_files  = "TFYSwiftMacOSAppKit/macOScontainer/**/*.{swift}"

    ss.subspec 'macOSStatusItem' do |sss|
       sss.source_files  = "TFYSwiftMacOSAppKit/macOScontainer/macOSStatusItem/**/*.{swift}"
    end

    ss.subspec 'macOSUtils' do |sss|
       sss.source_files  = "TFYSwiftMacOSAppKit/macOScontainer/macOSUtils/**/*.{swift}"
    end
  end

end
