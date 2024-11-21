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
import CoreLocation
import NetworkExtension
import IOKit

// MARK: - Network Utilities Class
public final class TFYSwiftUtils: NSObject, CLLocationManagerDelegate {
    
    static let MACOS_CELLULAR = "pdp_ip0"
    static let MACOS_WIFI = "en1"
    static let MACOS_VPN = "utun0"
    static let IP_ADDR_IPv4 = "ipv4"
    static let IP_ADDR_IPv6 = "ipv6"
    
    // MARK: - Types
    public struct NetworkInfo {
        let name: String?
        let ip: String?
        let macAddress: String?
    }
    
    // MARK: - Properties
    private static let shared = TFYSwiftUtils()
    private var locationManager: CLLocationManager?
    private var wifiNameCompletion: ((String?) -> Void)?
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Setup Location Manager
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()  // Adjust based on your app's requirement
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Authorization status changed")
        checkLocationAuthorization(manager: manager)
    }
    
    private func checkLocationAuthorization(manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            handleLocationPermissionGranted()
        case .denied, .restricted, .notDetermined:
            completeWithFailure()
        @unknown default:
            fatalError("Unhandled case in location authorization status")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completeWithFailure()
    }
    
    // MARK: - Public Method to Get WiFi Information
    public static func getWiFiInfo(completion: @escaping (NetworkInfo) -> Void) {
        shared.getWiFiName { name in
            let ip = getWiFiIP()
            let macAddress = getMacAddress()
            let info = NetworkInfo(
                name: name,
                ip: ip,
                macAddress: macAddress
            )
            completion(info)
        }
    }
    
    // MARK: - Private Method to Get WiFi Name
    private func getWiFiName(completion: @escaping (String?) -> Void) {
        if let name = try? Self.getWiFiNameUsingCWWiFiClient() {
            completion(name)
            return
        }
        wifiNameCompletion = completion
        requestLocationPermission()
    }
    
    private static func getWiFiNameUsingCWWiFiClient() throws -> String? {
        CWWiFiClient.shared().interface()?.ssid()
    }
    
    private func requestLocationPermission() {
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func handleLocationPermissionGranted() {
        if let name = try? Self.getWiFiNameUsingCWWiFiClient() {
            wifiNameCompletion?(name)
        } else {
            completeWithFailure()
        }
    }
    
    private func completeWithFailure() {
        wifiNameCompletion?(nil)
        wifiNameCompletion = nil
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
        static func getIPAddress(preferIPv4: Bool) -> String {
            let searchArray = preferIPv4 ?
                [MACOS_VPN + "/" + IP_ADDR_IPv4, MACOS_VPN + "/" + IP_ADDR_IPv6, MACOS_WIFI + "/" + IP_ADDR_IPv4, MACOS_WIFI + "/" + IP_ADDR_IPv6, MACOS_CELLULAR + "/" + IP_ADDR_IPv4, MACOS_CELLULAR + "/" + IP_ADDR_IPv6] :
                [MACOS_VPN + "/" + IP_ADDR_IPv6, MACOS_VPN + "/" + IP_ADDR_IPv4, MACOS_WIFI + "/" + IP_ADDR_IPv6, MACOS_WIFI + "/" + IP_ADDR_IPv4, MACOS_CELLULAR + "/" + IP_ADDR_IPv6, MACOS_CELLULAR + "/" + IP_ADDR_IPv4]

            let addresses = getAllIPAddresses()
            for key in searchArray {
                if let address = addresses[key], isValidatIP(ipAddress: address) {
                    TFYLogger.log("找到有效IP: \(address)")
                    return address
                }
            }
            TFYLogger.log("在搜索数组中找不到有效的IP地址。")
            return ""
        }

        static func isValidatIP(ipAddress: String) -> Bool {
            let urlRegEx = "^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\.([01]?\\d\\d?|2[0-4]\\d|25[0-5])$"
            let regex = try? NSRegularExpression(pattern: urlRegEx, options: [])
            if let match = regex?.firstMatch(in: ipAddress, options: [], range: NSRange(location: 0, length: ipAddress.utf16.count)) {
                return match.range.location != NSNotFound
            }
            return false
        }

    static func getAllIPAddresses() -> [String: String] {
            var addresses = [String: String]()
            var ifaddr: UnsafeMutablePointer<ifaddrs>?
            
            guard getifaddrs(&ifaddr) == 0 else {
                return addresses
            }
            
            guard let firstAddr = ifaddr else {
                return addresses
            }
            
            var ptr = firstAddr
            while true {
                defer { ptr = ptr.pointee.ifa_next }
                
                let flags = Int32(ptr.pointee.ifa_flags)
                guard (flags & IFF_UP) == IFF_UP else {
                    guard ptr.pointee.ifa_next != nil else { break }
                    continue
                }
                
                guard let addr = ptr.pointee.ifa_addr else {
                    guard ptr.pointee.ifa_next != nil else { break }
                    continue
                }
                
                let family = addr.pointee.sa_family
                
                if family == UInt8(AF_INET) || family == UInt8(AF_INET6) {
                    let name = String(cString: ptr.pointee.ifa_name)
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    
                    // 修正这里：使用 MemoryLayout 获取结构体大小
                    let sockaddrSize: socklen_t
                    if family == UInt8(AF_INET) {
                        sockaddrSize = socklen_t(MemoryLayout<sockaddr_in>.size)
                    } else {
                        sockaddrSize = socklen_t(MemoryLayout<sockaddr_in6>.size)
                    }
                    
                    if getnameinfo(ptr.pointee.ifa_addr,
                                  sockaddrSize,
                                  &hostname,
                                  socklen_t(hostname.count),
                                  nil,
                                  0,
                                  NI_NUMERICHOST) == 0 {
                        
                        let ip = String(cString: hostname)
                        if family == UInt8(AF_INET) {
                            addresses[name] = ip
                        } else if family == UInt8(AF_INET6) {
                            addresses["\(name)-IPv6"] = ip
                        }
                    }
                }
                
                guard ptr.pointee.ifa_next != nil else { break }
            }
            
            freeifaddrs(ifaddr)
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
        return (currentVersion == version, version)
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
