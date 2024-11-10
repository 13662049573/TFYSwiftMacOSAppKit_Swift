//
//  TFYSwiftUtils.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import System
import CoreWLAN
import SystemConfiguration
import CoreTelephony
import QuartzCore

public func TFYLog(_ msg: Any...,
                    file: NSString = #file,
                    line: Int = #line,
                    column: Int = #column,
                    fn: String = #function) {
    #if DEBUG
    var msgStr = ""
    for element in msg {
        msgStr += "\(element)\n"
    }
    let prefix = "----------------######################----begin🚀----##################----------------\n当前时间：\(NSDate())\n当前文件完整的路径是：\(file)\n当前文件是：\(file.lastPathComponent)\n第 \(line) 行 \n第 \(column) 列 \n函数名：\(fn)\n打印内容如下：\n\(msgStr)----------------######################----end😊----##################----------------"
    print(prefix)
    // 将内容同步写到文件中去（Caches文件夹下）
    let cachePath  = CachesDirectory()
    let logURL = cachePath + "/log.txt"
    appendText(fileURL: URL(string: logURL)!, string: "\(prefix)")
    #endif
}

private func CachesDirectory() -> String {
    //获取程序的/Library/Caches目录
    let cachesPath = NSHomeDirectory() + "/Library/Caches"
    return cachesPath
}

// 在文件末尾追加新内容
private func appendText(fileURL: URL, string: String) {
    do {
        // 如果文件不存在则新建一个
        createFile(filePath: fileURL.path)
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        let stringToWrite = "\n" + string
        // 找到末尾位置并添加
        fileHandle.seekToEndOfFile()
        fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
        
    } catch let error as NSError {
        print("failed to append: \(error)")
    }
}

private func judgeFileOrFolderExists(filePath: String) -> Bool {
    let exist = FileManager.default.fileExists(atPath: filePath)
    // 查看文件夹是否存在，如果存在就直接读取，不存在就直接反空
    guard exist else {
        return false
    }
    return true
}

@discardableResult
private func createFile(filePath: String) -> (isSuccess: Bool, error: String) {
    guard judgeFileOrFolderExists(filePath: filePath) else {
        // 不存在的文件路径才会创建
        // withIntermediateDirectories 为 ture 表示路径中间如果有不存在的文件夹都会创建
        let createSuccess = FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        return (createSuccess, "")
    }
    return (true, "")
}

public class TFYSwiftUtils: NSObject {
    
    /// 获取本机IP
    public static func getIPAddress() -> String? {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return addresses.first
    }
    
    /// 获取连接wifi的ip地址, 需要定位权限和添加Access WiFi information
    public static func getWiFiIP() -> String? {
        var address: String?
        // get list of all interfaces on the local machine
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0,
              let firstAddr = ifaddr else { return nil }
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPV4 or IPV6 interface
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name
                let name = String(cString: interface.ifa_name)
                if name == "en0" {
                    // Convert interface address to a human readable string
                    var addr = interface.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
    /// 获取连接wifi的名字和mac地址, 需要定位权限和添加Access WiFi information
    public static func getWiFiInfo() -> (wifiName: String?, macAddress: String?) {
        var wifiName: String?
        var macAddress: String?
        let interfaceNames = SCDynamicStoreCopyKeyList((SCDynamicStore.self as! SCDynamicStore), "State:/Network/Global/IPv4" as CFString)
        if let interfaceNames = interfaceNames as? [String] {
            for name in interfaceNames {
                if let serviceID = SCDynamicStoreCopyValue(nil, name as CFString),
                   let serviceDict = (serviceID as? [String: Any])?["PrimaryInterface"] as? [String: Any],
                   let interfaceName = serviceDict["InterfaceName"] as? String,
                   interfaceName.hasPrefix("en") { // en开头的通常是无线接口
                    let wlanClient = CWWiFiClient()
                    let interface = wlanClient.interface()
                    let ssidData:Data? = interface?.ssidData()
                    if let ssidString = String(data: ssidData!, encoding: .utf8) {
                        wifiName = ssidString
                    }
                    if let macAddressData = interface?.hardwareAddress() {
                        macAddress = macAddressData.map { String(format: "%02x:", $0 as! CVarArg) }.joined(separator: "")
                        macAddress?.removeLast() // 移除最后一个冒号
                    }
                    break
                }
            }
        }
        return (wifiName, macAddress)
    }
    
    
    public static func checkForAppUpdate(appID: String, completion: @escaping (_ isUpdated:Bool,_ newVersion:String?) -> Void) {
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(appID)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, "无法连接到App Store")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [Any],
                   let firstResult = results.first as? [String: Any],
                   let version = firstResult["version"] as? String {
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    completion(currentVersion == version, version)
                } else {
                    completion(false, "无法获取版本信息")
                }
            } catch {
                completion(false, "解析错误: \(error.localizedDescription)")
            }
        }.resume()
    }
}
