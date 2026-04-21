//
//  TFYSwiftUtils.swift
//  TFYSwiftMacOSAppKit_Swift
//
//  Created by 田风有 on 2024/11/5.
//  Copyright © 2024 TFYSwift. All rights reserved.
//

import Foundation
import CoreWLAN
import SystemConfiguration
import Network
import NetworkExtension
import IOKit
import CommonCrypto
import CryptoKit

// MARK: - Network Utilities Class
public final class TFYSwiftUtils: NSObject {
    // 定义常量
    private static let encoding = String.Encoding.utf8
    private static let algorithm: CCAlgorithm = CCAlgorithm(kCCAlgorithm3DES)
    private static let keySize = kCCKeySize3DES
    private static let blockSize = kCCBlockSize3DES
    static let MACOS_CELLULAR = "pdp_ip0"
    static let MACOS_WIFI = "en1"
    static let MACOS_VPN = "utun1"
    static let IP_ADDR_IPv4 = "ipv4"
    static let IP_ADDR_IPv6 = "ipv6"
    
    // MARK: - Types
    public struct NetworkInfo {
        public let name: String?
        public let ip: String?
        public let macAddress: String?
        public let wifiInfo:[String: Any]?

        public init(name: String?, ip: String?, macAddress: String?, wifiInfo: [String: Any]?) {
            self.name = name
            self.ip = ip
            self.macAddress = macAddress
            self.wifiInfo = wifiInfo
        }
    }
    
    // MARK: - Properties
    private static let shared = TFYSwiftUtils()
    private var wifiNameCompletion: ((String?) -> Void)?
    
    // MARK: - Public Method to Get WiFi Information
    public static func getWiFiInfo(completion: @escaping (NetworkInfo) -> Void) {
        let name = getWiFiName()
        let ip = getWiFiIP()
        let macAddress = getMacAddress()
        let wifiInfo = getWiFiInfo()
        let info = NetworkInfo(
            name: name,
            ip: ip,
            macAddress: macAddress,
            wifiInfo: wifiInfo
        )
        completion(info)
    }
    
    public static func getWiFiName() -> String? {
        guard let interface = CWWiFiClient.shared().interface() else {
            print("无法获取 WiFi 接口")
            return nil
        }
        return interface.ssid()
    }
    
    // 获取更详细的 WiFi 信息
    public static func getWiFiInfo() -> [String: Any] {
        var wifiInfo: [String: Any] = [:]
        guard let interface = CWWiFiClient.shared().interface() else {
            print("无法获取 WiFi 接口")
            return wifiInfo
        }
        // SSID (网络名称)
        if let ssid = interface.ssid() {
            wifiInfo["ssid"] = ssid
        }
        // BSSID (MAC 地址)
        if let bssid = interface.bssid() {
            wifiInfo["bssid"] = bssid
        }
        // 信号强度
        wifiInfo["rssi"] = interface.rssiValue()
        // 传输速率
        wifiInfo["transmitRate"] = interface.transmitRate()
        // 信道
        if let channel = interface.wlanChannel() {
            wifiInfo["channel"] = channel.channelNumber
            wifiInfo["channelBand"] = channel.channelBand
        }
        // 安全类型
        wifiInfo["security"] = interface.security().rawValue
        return wifiInfo
    }
    
    // 添加错误处理版本
    public enum WiFiError: Error {
        case interfaceUnavailable
        case notConnected
        case permissionDenied
        case unknown(String)
    }
    
    public static func getWiFiNameWithError() -> Result<String, WiFiError> {
        guard let interface = CWWiFiClient.shared().interface() else {
            return .failure(.interfaceUnavailable)
        }
        guard let ssid = interface.ssid() else {
            return .failure(.notConnected)
        }
        return .success(ssid)
    }
    
    // MARK: - Private Method to Get WiFi IP Address
    private static func getWiFiIP() -> String? {
        guard let sock = createSocket() else { return nil }
        defer { close(sock) }
        guard let addr = createSocketAddress(),
              connectSocket(sock, addr) else {
            return nil
        }
        return getLocalAddress(for: sock)
    }

    // MARK: - Private Helper Methods for Socket Operations
    private static func createSocket() -> Int32? {
        let sock = socket(AF_INET, SOCK_DGRAM, 0)
        return sock != -1 ? sock : nil
    }

    private static func createSocketAddress() -> sockaddr_in? {
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_addr.s_addr = inet_addr("8.8.8.8") // Google DNS
        addr.sin_port = UInt16(53).bigEndian        // DNS port
        return addr
    }

    private static func connectSocket(_ sock: Int32, _ addr: sockaddr_in) -> Bool {
        var addr = addr
        let connectResult = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        return connectResult != -1
    }

    private static func getLocalAddress(for sock: Int32) -> String? {
        var localAddr = sockaddr_in()
        var len = socklen_t(MemoryLayout<sockaddr_in>.size)
        
        let getsockResult = withUnsafeMutablePointer(to: &localAddr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                getsockname(sock, $0, &len)
            }
        }
        guard getsockResult != -1 else { return nil }
        
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let result = withUnsafePointer(to: &localAddr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                getnameinfo($0, len, &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
            }
        }
        return result == 0 ? String(cString: hostname) : nil
    }
    
    // MARK: - Private Method to Get MAC Address
    private static func getMacAddress() -> String? {
        let matching = IOServiceMatching("IOEthernetInterface") as NSMutableDictionary
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else {
            return nil
        }
        defer { IOObjectRelease(iterator) }
        
        var macAddress: String?
        repeat {
            let service = IOIteratorNext(iterator)
            guard service != 0 else { break }
            defer { IOObjectRelease(service) }
            
            var parentService: io_object_t = 0
            guard IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService) == KERN_SUCCESS else {
                continue
            }
            defer { IOObjectRelease(parentService) }
            
            if let macData = IORegistryEntryCreateCFProperty(parentService, "IOMACAddress" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue() as? Data {
                macAddress = macData.map { String(format: "%02x", $0) }.joined(separator: ":")
                break
            }
        } while true
        
        return macAddress
    }
    
    // MARK: - Get Device Current Network IP Address
        public static func getIPAddress(preferIPv4: Bool) -> String {
            let searchArray = preferIPv4 ?
                [MACOS_VPN + "/" + IP_ADDR_IPv4, MACOS_VPN + "/" + IP_ADDR_IPv6, MACOS_WIFI + "/" + IP_ADDR_IPv4, MACOS_WIFI + "/" + IP_ADDR_IPv6, MACOS_CELLULAR + "/" + IP_ADDR_IPv4, MACOS_CELLULAR + "/" + IP_ADDR_IPv6] :
                [MACOS_VPN + "/" + IP_ADDR_IPv6, MACOS_VPN + "/" + IP_ADDR_IPv4, MACOS_WIFI + "/" + IP_ADDR_IPv6, MACOS_WIFI + "/" + IP_ADDR_IPv4, MACOS_CELLULAR + "/" + IP_ADDR_IPv6, MACOS_CELLULAR + "/" + IP_ADDR_IPv4]

            let addresses = getAllIPAddresses()
            for key in searchArray {
                if let address = addresses[key], isValidIP(ipAddress: address) {
                    return address
                }
            }
            return ""
        }

        @available(*, deprecated, renamed: "isValidIP(ipAddress:)")
        public static func isValidatIP(ipAddress: String) -> Bool {
            return isValidIP(ipAddress: ipAddress)
        }

        public static func isValidIP(ipAddress: String) -> Bool {
            let urlRegEx = "^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])$"
            let regex = try? NSRegularExpression(pattern: urlRegEx, options: [])
            if let match = regex?.firstMatch(in: ipAddress, options: [], range: NSRange(location: 0, length: ipAddress.utf16.count)) {
                return match.range.location != NSNotFound
            }
            return false
        }

    public static func getAllIPAddresses() -> [String: String] {
        var addresses = [String: String]()
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        // 获取网络接口地址
        guard getifaddrs(&ifaddr) == 0 else {
            return addresses
        }
        
        // 安全检查
        var ptr = ifaddr
        while let interface = ptr {
            defer {
                ptr = interface.pointee.ifa_next
            }
            
            // 检查接口是否有效
            guard let addr = interface.pointee.ifa_addr else {
                continue
            }
            
            let family = addr.pointee.sa_family
            
            // 只处理 IPv4 和 IPv6
            if family == UInt8(AF_INET) || family == UInt8(AF_INET6) {
                // 获取接口名称
                let name = String(cString: interface.pointee.ifa_name)
                
                // 检查接口状态
                let flags = Int32(interface.pointee.ifa_flags)
                guard (flags & IFF_UP) == IFF_UP else {
                    continue
                }
                
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                
                // 获取地址大小
                let sockaddrSize: socklen_t = {
                    switch family {
                    case UInt8(AF_INET):
                        return socklen_t(MemoryLayout<sockaddr_in>.size)
                    case UInt8(AF_INET6):
                        return socklen_t(MemoryLayout<sockaddr_in6>.size)
                    default:
                        return 0
                    }
                }()
                
                // 安全检查地址大小
                guard sockaddrSize > 0 else {
                    continue
                }
                
                // 获取 IP 地址
                if getnameinfo(addr,
                              sockaddrSize,
                              &hostname,
                              socklen_t(hostname.count),
                              nil,
                              0,
                              NI_NUMERICHOST) == 0 {
                    
                    let ip = String(cString: hostname)
                    
                    // 根据地址类型存储
                    if family == UInt8(AF_INET) {
                        addresses[name] = ip
                    } else if family == UInt8(AF_INET6) {
                        // 可选：如果不需要 IPv6 地址，可以注释掉这行
                        addresses["\(name)-IPv6"] = ip
                    }

                    #if DEBUG
                    // 调试信息只在 Debug 构建中输出，避免生产环境刷日志
                    print("Interface: \(name), IP: \(ip)")
                    #endif
                }
            }
        }
        
        // 释放内存
        if let ifaddrPtr = ifaddr {
            freeifaddrs(ifaddrPtr)
        }
        
        return addresses
    }

    
    // Fetch the raw device model string using sysctlbyname
        func getRawDeviceModel() -> String {
            var size: size_t = 0
            sysctlbyname("hw.model", nil, &size, nil, 0)
            var machine = Array<CChar>(repeating: 0, count: size)
            sysctlbyname("hw.model", &machine, &size, nil, 0)
            return String(cString: machine)
        }

        // Convert the raw device model string to a friendly device name
    func convertToFriendlyDeviceModel(_ rawModel: String) -> String {
        switch rawModel {
        // M1 Models
        case "Macmini9,1":
            return "Mac mini (M1, 2020)"
        case "iMac21,1", "iMac21,2":
            return "iMac (24-inch, M1, 2021)"
        case "MacBookAir10,1":
            return "MacBook Air (M1, 2020)"
        case "MacBookPro17,1":
            return "MacBook Pro (13-inch, M1, 2020)"

        // M2 Models
        case "Mac14,2":
            return "MacBook Air (M2, 2022)"
        case "Mac14,7":
            return "MacBook Pro (13-inch, M2, 2022)"
        case "Mac14,5", "Mac14,9":
            return "MacBook Pro (14-inch, M2, 2023)"
        case "Mac14,6", "Mac14,10":
            return "MacBook Pro (16-inch, M2, 2023)"
        case "Mac14,8":
            return "MacBook Air (15-inch, M2, 2023)"

        // Speculative M3 Models
        case "Mac15,12":
            return "MacBook Air (13-inch, M3, 2024)"
        case "Mac15,13":
            return "MacBook Air (15-inch, M3, 2024)"

        // Speculative M4 Models
        case "Mac17,1":
            return "MacBook Pro (M4, 2025)"  // Hypothetical model
        case "Mac17,2":
            return "MacBook Air (M4, 2025)"  // Hypothetical model

        // Other Models
        case "iMac18,1", "iMac18,2":
            return "iMac (Retina 4K, 21.5-inch, 2017)"
        case "iMac18,3":
            return "iMac (Retina 5K, 27-inch, 2017)"
        case "iMacPro1,1":
            return "iMac Pro (2017)"
        case "iMac19,1":
            return "iMac (Retina 5K, 27-inch, 2020)"
        case "iMac19,2":
            return "iMac (Retina 4K, 21.5-inch, 2020)"
        case "iMac20,1", "iMac20,2":
            return "iMac (Retina 5K, 27-inch, 2020)"
        case "MacBookPro14,1", "MacBookPro14,2", "MacBookPro14,3":
            return "MacBook Pro 2017"
        case "MacBookPro15,1", "MacBookPro15,2", "MacBookPro15,3":
            return "MacBook Pro 2018"
        case "MacBookPro15,4":
            return "MacBook Pro 2019 (Butterfly Keyboard)"
        case "MacBookPro16,1", "MacBookPro16,4":
            return "MacBook Pro 2019 (Magic Keyboard)"
        case "MacBookPro16,2", "MacBookPro16,3":
            return "MacBook Pro 2020"
        case "MacBookAir7,2":
            return "MacBook Air 2017"
        case "MacBookAir8,1":
            return "MacBook Air 2018"
        case "MacBookAir8,2":
            return "MacBook Air 2019"
        case "MacBookAir9,1":
            return "MacBook Air 2020"
        case "Macmini7,1":
            return "Mac mini (Late 2014)"
        case "Macmini8,1":
            return "Mac mini 2018"
        case "MacPro7,1":
            return "Mac Pro 2019"
        default:
            return "Unknown"
        }
    }

        // Get device model and convert to friendly name
        func getDeviceModel() -> String {
            let rawModel = getRawDeviceModel()
            return convertToFriendlyDeviceModel(rawModel)
        }

        // Get the current system version string
        func systemVersion() -> String {
            return ProcessInfo.processInfo.operatingSystemVersionString
        }

        // Get the application version string
        func version() -> String {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        }

        // Get the device name
        func deviceName() -> String {
            return Host.current().localizedName ?? "Unknown"
        }

        // Get or generate a unique device identifier (UUID)
        func uuid() -> String {
            let defaults = UserDefaults.standard
            if let storedUUID = defaults.string(forKey: "deviceID") {
                return storedUUID
            } else {
                let newUUID = UUID().uuidString
                defaults.set(newUUID, forKey: "deviceID")
                return newUUID
            }
        }
    
    /// 加密方法（已废弃：3DES ECB 不安全，请使用 encryptAESGCM）
    /// - Parameters:
    ///   - content: 要加密的内容
    ///   - key: 密钥
    /// - Returns: 加密后的 Base64 字符串
    @available(*, deprecated, message: "3DES ECB is insecure. Use AES-GCM via CryptoKit instead.")
    public static func encrypt(content: String, key: String) -> String? {
        guard let contentData = content.data(using: .utf8),
              let keyData = key.data(using: .utf8) else {
            return nil
        }
        
        // 调整密钥长度
        var adjustedKeyData = Data(count: keySize)
        adjustedKeyData.replaceSubrange(0..<min(keyData.count, keySize),
                                      with: keyData)
        
        let bufferSize = contentData.count + blockSize
        var buffer = Data(count: bufferSize)
        
        var encryptedSize: size_t = 0
        
        let status = buffer.withUnsafeMutableBytes { bufferPtr in
            contentData.withUnsafeBytes { contentPtr in
                adjustedKeyData.withUnsafeBytes { keyPtr in
                    CCCrypt(CCOperation(kCCEncrypt),
                           algorithm,
                           CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode),
                           keyPtr.baseAddress,
                           keySize,
                           nil,
                           contentPtr.baseAddress,
                           contentData.count,
                           bufferPtr.baseAddress,
                           bufferSize,
                           &encryptedSize)
                }
            }
        }
        
        guard status == kCCSuccess else {
            return nil
        }
        
        buffer.count = encryptedSize
        return buffer.base64EncodedString()
    }
    
    /// 解密方法（已废弃：3DES ECB 不安全，请使用 decryptAESGCM）
    /// - Parameters:
    ///   - content: 要解密的 Base64 字符串
    ///   - key: 密钥
    /// - Returns: 解密后的原文
    @available(*, deprecated, message: "3DES ECB is insecure. Use AES-GCM via CryptoKit instead.")
    public static func decrypt(content: String, key: String) -> String? {
        guard let contentData = Data(base64Encoded: content),
              let keyData = key.data(using: .utf8) else {
            return nil
        }
        
        // 调整密钥长度
        var adjustedKeyData = Data(count: keySize)
        adjustedKeyData.replaceSubrange(0..<min(keyData.count, keySize),
                                      with: keyData)
        
        let bufferSize = contentData.count + blockSize
        var buffer = Data(count: bufferSize)
        
        var decryptedSize: size_t = 0
        
        let status = buffer.withUnsafeMutableBytes { bufferPtr in
            contentData.withUnsafeBytes { contentPtr in
                adjustedKeyData.withUnsafeBytes { keyPtr in
                    CCCrypt(CCOperation(kCCDecrypt),
                           algorithm,
                           CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode),
                           keyPtr.baseAddress,
                           keySize,
                           nil,
                           contentPtr.baseAddress,
                           contentData.count,
                           bufferPtr.baseAddress,
                           bufferSize,
                           &decryptedSize)
                }
            }
        }
        
        guard status == kCCSuccess else {
            return nil
        }
        
        buffer.count = decryptedSize
        return String(data: buffer, encoding: .utf8)
    }
    
    /// AES-GCM 加密（推荐替代 encrypt(content:key:)）
    /// - Parameters:
    ///   - content: 要加密的内容
    ///   - key: 密钥字符串（将通过 SHA-256 派生为 256-bit 对称密钥）
    /// - Returns: 加密后的 Base64 字符串（含 nonce + ciphertext + tag），失败返回 nil
    @available(macOS 10.15, *)
    public static func encryptAESGCM(content: String, key: String) -> String? {
        guard let contentData = content.data(using: .utf8),
              let keyData = key.data(using: .utf8) else { return nil }
        let symmetricKey = SymmetricKey(data: SHA256.hash(data: keyData))
        guard let sealedBox = try? AES.GCM.seal(contentData, using: symmetricKey) else { return nil }
        return sealedBox.combined?.base64EncodedString()
    }
    
    /// AES-GCM 解密（推荐替代 decrypt(content:key:)）
    /// - Parameters:
    ///   - content: encryptAESGCM 返回的 Base64 字符串
    ///   - key: 密钥字符串（须与加密时相同）
    /// - Returns: 解密后的原文，失败返回 nil
    @available(macOS 10.15, *)
    public static func decryptAESGCM(content: String, key: String) -> String? {
        guard let contentData = Data(base64Encoded: content),
              let keyData = key.data(using: .utf8) else { return nil }
        let symmetricKey = SymmetricKey(data: SHA256.hash(data: keyData))
        guard let sealedBox = try? AES.GCM.SealedBox(combined: contentData),
              let decryptedData = try? AES.GCM.open(sealedBox, using: symmetricKey) else { return nil }
        return String(data: decryptedData, encoding: .utf8)
    }
    
}

// MARK: - Usage Example
extension TFYSwiftUtils {
    public static func printNetworkInfo() {
        getWiFiInfo { info in
            TFYLogger.log("""
            Network Information:
            WiFi Name: \(info.name ?? "Unknown")
            IP Address: \(info.ip ?? "Unknown")
            MAC Address: \(info.macAddress ?? "Unknown")
            """)
        }
    }
}

// MARK: - Hash Helpers
@available(macOS 10.15, *)
public extension TFYSwiftUtils {

    /// Compute SHA-256 hex digest of a string (UTF-8).
    static func sha256Hex(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return "" }
        return sha256Hex(data)
    }

    /// Compute SHA-256 hex digest of data.
    static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    /// Compute MD5 hex digest of a string (UTF-8). Note: MD5 is not cryptographically secure,
    /// use only for checksums / cache keys.
    static func md5Hex(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return "" }
        return md5Hex(data)
    }

    static func md5Hex(_ data: Data) -> String {
        Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Network Reachability
@available(macOS 10.14, *)
public final class TFYNetworkReachability {
    public enum Status: Equatable {
        case unknown
        case unavailable
        case wifi
        case ethernet
        case cellular
        case other
    }

    public static let shared = TFYNetworkReachability()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.tfy.network.reachability")
    private var handlers: [UUID: (Status) -> Void] = [:]
    private let handlersLock = NSLock()
    private var started = false
    private var lastStatus: Status = .unknown

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let status = Self.mapStatus(path: path)
            self.handlersLock.lock()
            self.lastStatus = status
            let snapshot = Array(self.handlers.values)
            self.handlersLock.unlock()
            DispatchQueue.main.async {
                snapshot.forEach { $0(status) }
            }
        }
    }

    public func start() {
        handlersLock.lock()
        let already = started
        started = true
        handlersLock.unlock()
        guard !already else { return }
        monitor.start(queue: queue)
    }

    public func stop() {
        monitor.cancel()
        handlersLock.lock()
        started = false
        handlers.removeAll()
        handlersLock.unlock()
    }

    public var status: Status {
        handlersLock.lock()
        defer { handlersLock.unlock() }
        return lastStatus
    }

    /// Register a handler; returns a token you can pass to `remove(token:)`.
    @discardableResult
    public func addListener(_ handler: @escaping (Status) -> Void) -> UUID {
        let token = UUID()
        handlersLock.lock()
        handlers[token] = handler
        handlersLock.unlock()
        start()
        return token
    }

    public func remove(token: UUID) {
        handlersLock.lock()
        handlers[token] = nil
        handlersLock.unlock()
    }

    private static func mapStatus(path: Network.NWPath) -> Status {
        guard path.status == .satisfied else { return .unavailable }
        if path.usesInterfaceType(Network.NWInterface.InterfaceType.wifi) { return .wifi }
        if path.usesInterfaceType(Network.NWInterface.InterfaceType.wiredEthernet) { return .ethernet }
        if path.usesInterfaceType(Network.NWInterface.InterfaceType.cellular) { return .cellular }
        return .other
    }
}

// MARK: - App Update Checker
public final class TFYAppUpdateChecker {
    public static func checkForUpdate(appID: String) async throws -> (isUpdated: Bool, newVersion: String?) {
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(appID)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let firstResult = results.first,
              let version = firstResult["version"] as? String else {
            throw NSError(domain: "AppUpdateError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let isUpToDate: Bool
        if let current = currentVersion {
            isUpToDate = current.compare(version, options: .numeric) != .orderedAscending
        } else {
            isUpToDate = false
        }
        return (isUpToDate, version)
    }
}

// MARK: - Logger
public struct TFYLogger {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private static let logQueue = DispatchQueue(label: "com.tfy.logger")
    
    public static func log(_ items: Any...,
                          file: String = #file,
                          line: Int = #line,
                          column: Int = #column,
                          function: String = #function) {
        #if DEBUG
        logQueue.async {
            let timestamp = dateFormatter.string(from: Date())
            let fileName = (file as NSString).lastPathComponent
            let message = items.map { "\($0)" }.joined(separator: "\n")
            
            let logMessage = """
            ----------------######################----begin🚀----##################----------------
            时间: \(timestamp)
            文件: \(fileName)
            行号: \(line)
            列号: \(column)
            函数: \(function)
            内容:
            \(message)
            ----------------######################----end😊----##################----------------
            
            """
            
            print(logMessage)
            writeToFile(logMessage)
        }
        #endif
    }
    
    private static func writeToFile(_ message: String) {
        guard let logFileURL = getLogFileURL() else { return }
        
        do {
            if !FileManager.default.fileExists(atPath: logFileURL.path) {
                try "".write(to: logFileURL, atomically: true, encoding: .utf8)
            }
            
            let handle = try FileHandle(forWritingTo: logFileURL)
            defer { handle.closeFile() }
            
            handle.seekToEndOfFile()
            if let data = message.data(using: .utf8) {
                handle.write(data)
            }
        } catch {
            print("Error writing to log file: \(error)")
        }
    }
    
    private static func getLogFileURL() -> URL? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return cachesDirectory.appendingPathComponent("log.txt")
    }
}
