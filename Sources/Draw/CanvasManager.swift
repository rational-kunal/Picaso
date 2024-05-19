import UIKit

public class CanvasManager {

    public static let sharedInstance = {
        return CanvasManager()
    }()

    private lazy var canvasWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.isHidden = false
//        window.windowLevel = .statusBar
        window.backgroundColor = .yellow
        return window
    }()

    private var isCanvasActive: Bool { self.canvasWindow.windowScene != nil }

    /// Default initialization
    /// - Shortcut "x" to toggle canvas
    public static func defaultInitialization() {
        ShortcutManager.sharedInstance.registerShortcut(withKey: Constants.ToggleCanvasDefaultShortcutKey,
                                                        action: {
            CanvasManager.sharedInstance.toggleCanvas()
        })
    }

    public func toggleCanvas() {
        if isCanvasActive {
            hideCanvas()
        } else {
            showCanvas()
        }
    }

    public func showCanvas() {
        guard let windowScene = UIApplication.shared.activeWindowScene else { return }
        canvasWindow.rootViewController = makeRootViewController()
        canvasWindow.windowScene = windowScene
        canvasWindow.isHidden = false
    }

    public func hideCanvas() {
        canvasWindow.rootViewController = nil
        canvasWindow.windowScene = nil
        canvasWindow.isHidden = true
    }

    private func makeRootViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.view = CanvasView(frame: .zero)
        viewController.view.backgroundColor = .clear

        return viewController
    }
}

fileprivate extension UIApplication {
    // TODO: keyWindow is depricated
    fileprivate var activeWindowScene: UIWindowScene? {
        return keyWindow?.windowScene
    }
}

