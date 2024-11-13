
Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftMacOSAppKit"

  spec.version      = "1.1.0"

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
    ss.source_files  = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOScategory/*.{swift}"
    ss.dependency "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOScontainer"
    ss.dependency "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSfoundation"
  end

  spec.subspec 'macOSchain' do |ss|
    ss.source_files  = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSchain/*.{swift}"

   #  ss.subspec 'macOSBase' do |sss|
   #     sss.source_files = 'TFYSwiftMacOSAppKit/macOSchain/macOSBase/*.{swift}'
   #  end

   #  ss.subspec 'macOSCALayer' do |sss|
   #     sss.source_files = 'TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSchain/macOSCALayer/*.{swift}'
   #     sss.dependency "TFYSwiftMacOSAppKit/macOSchain/macOSBase"
   #     sss.dependency "TFYSwiftMacOSAppKit/macOSfoundation"
   #  end

   #  ss.subspec 'macOSGesture' do |sss|
   #     sss.source_files = 'TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSchain/macOSGesture/*.{swift}'
   #     sss.dependency "TFYSwiftMacOSAppKit/macOSchain/macOSBase"
   #     sss.dependency "TFYSwiftMacOSAppKit/macOSfoundation"
   #  end

   #  ss.subspec 'macOSView' do |sss|
   #    sss.source_files = 'TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSchain/macOSView/*.{swift}'
   #    sss.dependency "TFYSwiftMacOSAppKit/macOSchain/macOSBase"
   #    sss.dependency "TFYSwiftMacOSAppKit/macOSfoundation"
   #  end

  end

  spec.subspec 'macOSfoundation' do |ss|
    ss.source_files  = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOSfoundation/*.{swift}"
  end

  spec.subspec 'macOScontainer' do |ss|
    ss.source_files  = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOScontainer/*.{swift}"

    ss.subspec 'macOSGcd' do |sss|
       sss.source_files  = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOScontainer/macOSGcd/*.{swift}"
    end

    ss.subspec 'macOSStatusItem' do |sss|
       sss.source_files  = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOScontainer/macOSStatusItem/*.{swift}"
    end

    ss.subspec 'macOSUtils' do |sss|
       sss.source_files  = "TFYSwiftMacOSAppKit_Swift/TFYSwiftMacOSAppKit/macOScontainer/macOSUtils/*.{swift}"
    end
    
  end

end
