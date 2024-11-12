//
//  TFYSwiftUtils.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Cocoa
import System
import SystemConfiguration
import CoreTelephony
import QuartzCore
import Network
import CoreWLAN
import SystemConfiguration.CaptiveNetwork
import Darwin

// 日志打印工具函数，用于在 DEBUG 环境下打印详细的日志信息并写入文件。
public func TFYLog(_ msg: Any...,
                    file: NSString = #file,
                    line: Int = #line,
                    column: Int = #column,
                    fn: String = #function) {
    // 如果是 DEBUG 环境
    #if DEBUG
    // 将传入的多个参数转换为字符串并拼接在一起，每个参数占一行。
    var msgStr = ""
    for element in msg {
        msgStr += "\(element)\n"
    }
    // 构建日志信息的前缀，包含当前时间、文件路径、行数、列数、函数名和打印内容。
    let prefix = "----------------######################----begin🚀----##################----------------\n当前时间：\(NSDate())\n当前文件完整的路径是：\(file)\n当前文件是：\(file.lastPathComponent)\n第 \(line) 行 \n第 \(column) 列 \n函数名：\(fn)\n打印内容如下：\n\(msgStr)----------------######################----end😊----##################----------------"
    print(prefix)
    // 将内容同步写到文件中去（Caches 文件夹下）。
    let cachePath = CachesDirectory()
    let logURL = cachePath + "/log.txt"
    appendText(fileURL: URL(string: logURL)!, string: "\(prefix)")
    #endif
}

// 获取程序的/Library/Caches 目录路径。
private func CachesDirectory() -> String {
    let cachesPath = NSHomeDirectory() + "/Library/Caches"
    return cachesPath
}

// 在文件末尾追加新内容的函数。
private func appendText(fileURL: URL, string: String) {
    do {
        // 如果文件不存在则新建一个。
        createFile(filePath: fileURL.path)
        let fileHandle = try FileHandle(forWritingTo: fileURL)
        let stringToWrite = "\n" + string
        // 找到文件末尾位置并添加新内容。
        fileHandle.seekToEndOfFile()
        fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
    } catch let error as NSError {
        print("failed to append: \(error)")
    }
}

// 判断文件或文件夹是否存在的函数。
private func judgeFileOrFolderExists(filePath: String) -> Bool {
    let exist = FileManager.default.fileExists(atPath: filePath)
    // 查看文件夹是否存在，如果存在就直接读取，不存在就直接返回 false。
    guard exist else {
        return false
    }
    return true
}

// 创建文件的函数，如果文件已存在则直接返回成功状态，否则创建文件并返回创建结果。
@discardableResult
private func createFile(filePath: String) -> (isSuccess: Bool, error: String) {
    guard !judgeFileOrFolderExists(filePath: filePath) else {
        // 如果文件已存在，直接返回成功状态。
        return (true, "")
    }
    // 创建文件，withIntermediateDirectories 为 ture 表示路径中间如果有不存在的文件夹都会创建。
    let createSuccess = FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
    return (createSuccess, "")
}

public class TFYSwiftUtils: NSObject {
    
    // 获取本机 IP 的静态方法。
    public static func getIPAddress() -> String? {
        var addresses = [String]()
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        // 获取系统中的网络接口信息。
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                // 检查接口是否处于活动状态且不是回环接口。
                if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
                    // 检查接口地址类型是 IPV4 或 IPV6。
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        // 将接口地址转换为人类可读的字符串形式。
                        if getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                            if let address = String(validatingUTF8: hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            // 释放获取到的网络接口信息内存。
            freeifaddrs(ifaddr)
        }
        // 返回第一个找到的 IP 地址，如果没有则返回 nil。
        return addresses.first
    }

    // 获取连接wifi的IP地址的静态方法，支持macOS 12以上
    public static func getWiFiIP() -> String? {
        var address: String?
        // 获取系统中的网络接口信息
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil

        // 获取网络接口信息，若失败则打印错误并返回nil
        let result = getifaddrs(&ifaddr)
        if result != 0 {
            print("获取网络接口信息失败，错误码：\(result)")
            return nil
        }

        var currentAddr = ifaddr
        // 遍历网络接口信息
        while let addr = currentAddr {
            let interface = addr.pointee
            // 检查接口地址类型是IPV4或IPV6
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // 检查接口名称是否为en0或其他可能的无线接口名称
                let name = String(cString: interface.ifa_name)
                if name == "en0" || name == "en1" || name == "en2" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    // 将接口地址转换为人类可读的字符串形式
                    if getnameinfo(&interface.ifa_addr.pointee, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                        address = String(cString: hostname)
                        // 找到符合条件的接口并获取到IP地址后，释放已遍历过的网络接口信息内存
                        freeifaddrs(ifaddr)
                        return address
                    }
                }
            }
            currentAddr = addr.pointee.ifa_next
        }

        // 释放获取到的网络接口信息内存，如果循环结束未找到符合条件的接口
        freeifaddrs(ifaddr)
        return address
    }
    
    // 函数用于获取所有网络接口信息，返回可选的接口信息数组
    private static func getSupportedInterfaces() -> [CFString]? {
        guard let interfaces = CNCopySupportedInterfaces() as? [CFString] else {
            print("获取网络接口信息失败，错误码： \(errno)")
            return nil
        }
        return interfaces
    }

    // 获取连接wifi的名字和mac地址的静态方法，支持macOS 12以上
    public static func getWiFiInfo() -> (wifiName: String?, macAddress: String?) {
        // 用于存储WiFi名称和MAC地址
        var wifiName: String?
        var macAddress: String?

        // 获取所有网络接口信息
        if let interfaces = getSupportedInterfaces() {
            for interface in interfaces {
                // 获取指定接口的详细信息
                var interfaceInfo: [String: Any]?
                let interfaceData = SCDynamicStoreCopyValue(nil, "State:/InternetInterface/\(interface)/IPv4" as CFString)
                if let interfaceData = interfaceData as? [String: Any] {
                    interfaceInfo = interfaceData
                }

                // 检查是否是Wi-Fi接口（通常以"en"开头）
                if let interfaceInfo = interfaceInfo,
                   let interfaceName = interfaceInfo["Interface"] as? String,
                   interfaceName.hasPrefix("en") {

                    // 获取Wi-Fi客户端实例，将其声明为可选类型并处理初始化失败情况
                    var wlanClient: CWWiFiClient?
                    wlanClient = CWWiFiClient()

                    guard let unwrappedWlanClient = wlanClient else {
                        print("创建CWWiFiClient实例失败")
                        continue
                    }

                    // 获取WiFi接口实例并处理可能为nil的情况
                    guard let wifiInterface = unwrappedWlanClient.interface() else {
                        print("获取WiFi接口失败")
                        continue
                    }

                    // 获取wifi的SSID数据并转换为字符串。
                    if let ssidData = wifiInterface.ssidData() {
                        if let ssidString = String(data: ssidData, encoding:.utf8) {
                            wifiName = ssidString
                        }
                    }

                    // 获取wifi的硬件地址并转换为字符串格式。
                    if let macAddressData = wifiInterface.hardwareAddress() {
                        macAddress = macAddressData.map { String(format: "%02x:", $0 as! CVarArg) }.joined(separator: "")
                        macAddress?.removeLast() // 移除最后一个冒号
                    }

                    break
                }
            }
        } else {
            // 如果获取网络接口信息失败，这里可以根据具体需求进行更多处理，比如返回特定的错误值或进行其他提示操作
            print("无法继续获取WiFi信息，因为获取网络接口信息失败。")
            // 示例：返回特定的错误值表示获取失败
            return (nil, nil)
        }

        return (wifiName, macAddress)
    }
    
    
    // 检查应用是否有更新的静态方法，传入应用 ID 和回调函数，回调函数返回是否有更新以及新版本号（如果有）。
    public static func checkForAppUpdate(appID: String, completion: @escaping (_ isUpdated: Bool, _ newVersion: String?) -> Void) {
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(appID)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(false, "无法连接到 App Store")
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
