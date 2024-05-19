import Foundation
import UIKit

// Hack: To look into keyboard events
fileprivate extension UIEvent {
    fileprivate var isKeyboardEvent: Bool { String(describing: Swift.type(of: self)) == "UIPhysicalKeyboardEvent" }

    fileprivate var modifiedInput: String? {
        guard isKeyboardEvent else { return nil }
        return self.value(forKey: "_modifiedInput") as? String
    }

    fileprivate var unmodifiedInput: String? {
        guard isKeyboardEvent else { return nil }
        return self.value(forKey: "_unmodifiedInput") as? String
    }

    fileprivate var isKeyDown: Bool? {
        guard isKeyboardEvent else { return nil }
        return (self.value(forKey: "_isKeyDown") as? Bool)
    }

    fileprivate var keyCode: Int? {
        guard isKeyboardEvent else { return nil }
        return (self.value(forKey: "_keyCode") as? Int)
    }
}

class ShortcutManager {
    private var actionsForKeyInputs: [String: () -> Void] = [:]

    static let initializeOnce = {
        performSwizzling()
    }()

    public static let sharedInstance = {
        ShortcutManager.initializeOnce
        return ShortcutManager()
    }()

    // Registers a action to be performed when "key" is presseed by user
    // Note: This will override existing action for the "key"
    public func registerShortcut(withKey key: String, action: @escaping () -> Void) {
        actionsForKeyInputs[key] = action
    }

    private func handleKeyboardEvent(pressedKey: String) {
        if let action = actionsForKeyInputs[pressedKey] {
            action()
        }
    }

    fileprivate func interceptedSendEvent(_ event: UIEvent) {
        guard event.isKeyboardEvent, event.isKeyDown ?? false else { return }
        if let input = event.modifiedInput {
            handleKeyboardEvent(pressedKey: input)
        }
    }
}

// Handle siwizzling: Just call `performSwizzling()`
// Expect call to `ShortcutManager.interceptedSendEvent(_: UIEvent)` when any event is performed on `UIApplication`.
private extension ShortcutManager {
    // Performs swizzle only once
    private static func performSwizzling() {
        _ = _swizzledOnce
    }

    private static var _swizzledOnce: () = {
        _swizzle()
    }()
    
    private static func _swizzle() {
        let originalSelector = #selector(UIApplication.sendEvent(_:))
        let swizzledSelector = #selector(UIApplication.swizzled_sendEvent(_:))
        
        guard let originalMethod = class_getInstanceMethod(UIApplication.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIApplication.self, swizzledSelector) else {
            return
        }
        
        let didAddMethod = class_addMethod(UIApplication.self, originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(UIApplication.self, swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
}

fileprivate extension UIApplication {
    @objc func swizzled_sendEvent(_ event: UIEvent) {
        ShortcutManager.sharedInstance.interceptedSendEvent(event)

        // Call original
        swizzled_sendEvent(event)
    }
}
