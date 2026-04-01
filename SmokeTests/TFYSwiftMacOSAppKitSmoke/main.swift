import AppKit
import Foundation
import TFYSwiftMacOSAppKit

@main
enum TFYSwiftMacOSAppKitSmoke {
    static func main() {
        run("cache config validation") {
            precondition(TFYCacheConfig.default().validate().isEmpty)
            
            var invalidConfig = TFYCacheConfig()
            invalidConfig.memoryCacheSize = 0
            precondition(!invalidConfig.validate().isEmpty)
        }
        
        run("dispatch interval conversion") {
            let interval = DispatchTimeInterval.fromSeconds(1.25)
            precondition(abs(interval.toSeconds() - 1.25) < 0.001)
            precondition(interval.toMilliseconds() == 1250)
        }
        
        run("status item configuration") {
            let configuration = TFYStatusItemWindowConfiguration.defaultConfiguration()
            configuration.animationDuration = 0.5
            configuration.setPresentationTransition(.none)
            precondition(configuration.animationDuration == 0)
        }
        
        run("json validation") {
            precondition(TFYSwiftJsonUtils.isValidJSON("{\"name\":\"TFY\"}"))
            precondition(!TFYSwiftJsonUtils.isValidJSON("{\"name\":"))
        }
        
        run("gradient image fallback") {
            let size = NSSize(width: 24, height: 24)
            let image = NSImage.gradientImage(colors: [], size: size)
            precondition(image.size == size)
        }
        
        run("main-thread notification delivery") {
            let semaphore = DispatchSemaphore(value: 0)
            var deliveredOnMainThread = false
            let name = Notification.Name("TFYSwiftMacOSAppKitSmoke.notification")
            let token = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { _ in
                deliveredOnMainThread = Thread.isMainThread
                semaphore.signal()
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                NotificationCenter.default.postNotificationOnMainThread(
                    name: name,
                    object: nil,
                    userInfo: nil,
                    waitUntilDone: true
                )
            }
            
            let timeoutDate = Date().addingTimeInterval(2)
            var didReceiveNotification = false
            repeat {
                if semaphore.wait(timeout: .now()) == .success {
                    didReceiveNotification = true
                    break
                }
            } while Date() < timeoutDate && RunLoop.current.run(mode: .default, before: timeoutDate)
            
            NotificationCenter.default.removeObserver(token)
            precondition(didReceiveNotification)
            precondition(deliveredOnMainThread)
        }
        
        print("Smoke checks passed.")
    }
    
    private static func run(_ name: String, block: () -> Void) {
        block()
        print("PASS: \(name)")
    }
}
