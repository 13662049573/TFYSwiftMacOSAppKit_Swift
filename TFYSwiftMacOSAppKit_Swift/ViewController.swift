//
//  ViewController.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by mi ni on 2024/11/5.
//

import Cocoa


class ViewController: NSViewController {

    override func loadView() {
        let view:NSView = NSView(frame: NSRect(x: 0, y: 0, width: 1100, height: 720))
        self.view = view
    }
    
    private lazy var lablel: TFYSwiftLabel = {
        let labe = TFYSwiftLabel().chain
            .frame(CGRect(x: 200, y: 600, width: self.view.macos_width-400, height: 100))
            .text("用户协议和隐私政策请您务必审值阅读、充分理解 “用户协议” 和 ”隐私政策” 各项条款，包括但不限于：为了向您提供即时通讯、内容分享等服务，我们需要收集您的设备信息、操作日志等个人信息。您可阅读《用户协议》和《隐私政策》了解详细信息。如果您同意，请点击 “同意” 开始接受我们的服务;")
            .textColor(.gray)
            .font(.systemFont(ofSize: 14, weight: .bold))
            .backgroundColor(.white)
            .build
        return labe
    }()
    
    lazy var button: NSButton = {
        let btn = NSButton(frame: NSRect(x: 200, y: 600, width: self.view.macos_width-400, height: 50))
        btn.chain
            .font(.systemFont(ofSize: 16, weight: .bold))
            .text("弹出界面")
            .wantsLayer(true)
            .textColor(.red)
            .cornerRadius(25)
            .border(2, borderColor: .orange)
            .backgroundColor(.blue)
            .bezelStyle(.smallSquare)
            .addTarget(self, action: #selector(onClick(btn:)));
        return btn
    }()
    
    lazy var textfiled: NSTextField = {
        let filed = NSTextField(frame: NSRect(x: 100, y: 400, width: self.view.macos_width-200, height: 100))
        filed.chain
            .font(NSFont.systemFont(ofSize: 14, weight: .semibold))
            .wantsLayer(true)
            .backgroundColor(.white)
            .text("sssssssss")
            .textColor(.red)
        return filed
    }()
        
    lazy var textsView: TFYSwiftTextFieldView = {
        let view = TFYSwiftTextFieldView(frame: NSRect(x: 100, y: 200, width: self.view.macos_width-400, height: 40))
        view.placeholderString = "请输入密码"
        return view
    }()
    
    lazy var imageView: NSImageView = {
        let image = NSImageView(frame: NSMakeRect(1200, 100, 300, 300))
        return image
    }()
    
    lazy var popbuttom: NSPopUpButton = {
        let pop = NSPopUpButton(frame: NSRect(x: 200, y: 300, width: self.view.macos_width-400, height: 60))
        pop.chain
            .pullsDown(false)
            .autoenablesItems(false)
            .preferredEdge(.maxY)
            .addItems(["显示纯文本提示", "显示错误提示", "显示信息提示", "显示多行文本提示", "模拟文件上传场景", "显示加载中", "显示进度条", "模拟网络请求场景","模拟登录场景","连续提示示例","添加图片"])
            .selectItem(0)
            .addTarget(self, action: #selector(popUpButtonAction(pop:)))
        return pop
    }()
    
    var clickGesture: NSClickGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(popbuttom)
        view.addSubview(button)
        view.addSubview(lablel)
        view.addSubview(textfiled)
        view.addSubview(imageView)
        view.addSubview(textsView)
        
        let color = NSColor(hexString: "F46734")
        
        let linkInfos = [
            LinkInfo(key: "《用户协议》", value: "http://api.irainone.com/app/iop/register.html"),
            LinkInfo(key: "《隐私政策》", value: "http://api.irainone.com/app/iop/register.html")
        ]
        
        lablel.changeColors(with: [color, .blue], changeTexts: ["《用户协议》","《隐私政策》"])
        lablel.changeFonts(with: [.systemFont(ofSize: 20, weight: .bold)], changeTexts: ["《用户协议》","《隐私政策》"])
        lablel.changeLineSpace(with: 5)
        lablel.addGestureTap { reco in
            reco.didTapLabelAttributedText(linkInfos, action: { key, value in
                TFYLogger.log(key,value ?? "")
            }, lineFragmentPadding: 5)
        }
        
        TFYSwiftUtils.getWiFiInfo {[weak self] info in
            self?.textfiled.stringValue = "IP:\(info.ip ?? "未知")\nMac地址:\(info.macAddress ?? "未知")\nName:\(info.name ?? "未知")"
        }
    
        let address = TFYSwiftUtils.getIPAddress(preferIPv4: true)
        TFYLogger.log(address)
       
        let qrImageLogo = NSImage.generateQRCodeWithLogo(from: "https://apps.apple.com/cn/app/id6505094026", size: CGSize(width: 300, height: 300), logoImage: NSImage(named: "mood_day_6")!, logoSize: CGSizeMake(60, 60))
        
        imageView.image = qrImageLogo
    }
    
    @objc func onClick(btn:NSButton) {
        
        let showVc:TFYSwiftHomeController = TFYSwiftHomeController()
        showVc.preferredContentSize = NSSize(width: 400, height: 600)
        TFYStatusItem.shared.configureSafely(with: .init(
            customView: btn,
            viewController: showVc
        ))
    }
    
    @objc func popUpButtonAction(pop:NSPopUpButton) {
        let selectedIndex = pop.indexOfSelectedItem
        switch (selectedIndex) {
            case 0:
            showTextMessage()
                break;
            case 1:
            showErrorMessage()
                break;
            case 2:
            showSuccessMessage()
                break;
            case 3:
            showMultiLineMessage()
                break;
            case 4:///自定义动画
            simulateFileUpload()
                break;
            case 5:
            showLoadingMessage()
                break;
            case 6:
            showProgressMessage()
                break;
            case 7:
            simulateNetworkRequest()
                break;
            case 8:
            simulateLogin()
                break;
            case 9:
            showSequentialMessages()
                break;
            case 10:
            showImageMessage()
                break;
            default:
                break;
        }
    }
    
    // 1. 显示纯文本提示
    func showTextMessage() {
        TFYProgressMacOSHUD.showMessage("这是一条纯文本提示消息")
    }

    // 2. 显示多行文本提示
    func showMultiLineMessage() {
        TFYProgressMacOSHUD.showMessage("""
            感谢您信任并使用雷电加速器!我们非常重视您的隐私保护和个人信息保护。请认真阅读 《用户协议》和《隐私政策》的所有条款。
            1.为向您提供网络加速、用户注册登录等相关服务，我们会根据您使用服务的具体功能需要，收集必要的用户信息。
            2.为保障您的账号与使用安全，提升加速体验，您需要授权我们读取相关设备信息。您有权拒绝或取消授权。
            3.未经您授权，我们不会与第一方共享或对外提供您的信息。
            您点击"同意"即表示您已经阅读并同意以上协议的全部内容。
            """)
    }

    // MARK: - 状态提示框

    func showSuccessMessage() {
        TFYProgressMacOSHUD.showSuccess("操作成功！")
    }

    func showErrorMessage() {
        TFYProgressMacOSHUD.showError("操作失败，请重试")
    }

    func showInfoMessage() {
        TFYProgressMacOSHUD.showInfo("请注意这条重要信息")
    }

    // MARK: - 加载提示框

    func showLoadingMessage() {
        TFYProgressMacOSHUD.showLoading("正在加载中...")
        
        // 模拟延迟操作
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            TFYProgressMacOSHUD.hideHUD()
        }
    }

    func showProgressMessage() {
        // 模拟进度更新
        var progress: Float = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress += 0.01
            TFYProgressMacOSHUD.showProgress(progress, status: "上传中 \(Int(progress * 100))%")
            
            if progress >= 1.0 {
                timer.invalidate()
                TFYProgressMacOSHUD.showSuccess("上传完成！")
            }
        }
    }

    // MARK: - 复杂场景示例

    func simulateNetworkRequest() {
        TFYProgressMacOSHUD.showLoading("正在请求数据...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 随机模拟成功或失败
            if Bool.random() {
                TFYProgressMacOSHUD.showSuccess("数据加载成功！")
            } else {
                TFYProgressMacOSHUD.showError("网络连接失败，请检查网络设置")
            }
        }
    }

    func simulateFileUpload() {
        TFYProgressMacOSHUD.showLoading("准备上传文件...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var progress: Float = 0.0
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                progress += 0.02
                
                if progress <= 1.0 {
                    TFYProgressMacOSHUD.showProgress(progress, status: "正在上传 \(Int(progress * 100))%")
                } else {
                    timer.invalidate()
                    TFYProgressMacOSHUD.showSuccess("文件上传成功！")
                }
            }
        }
    }

    func simulateLogin() {
        TFYProgressMacOSHUD.showLoading("正在登录...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            TFYProgressMacOSHUD.showSuccess("登录成功！")
            TFYProgressMacOSHUD.hideHUD(afterDelay: 1.5)
        }
    }

    func showSequentialMessages() {
        TFYProgressMacOSHUD.showInfo("正在检查更新...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            TFYProgressMacOSHUD.showLoading("发现新版本，正在下载...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                TFYProgressMacOSHUD.showSuccess("更新完成！")
            }
        }
    }

    func showImageMessage() {
        if let image = NSImage(named: "mood_min_1") {
            TFYProgressMacOSHUD.showImage(image, status: "极速发生本菲卡是本菲卡设备开发必胜客被罚款部分卡包卡包")
        }
    }
}

