//
//  AlertPresentable.swift
//  AlertPresentable
//
//  Created by Stan Liu on 17/10/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import UIKit

public struct Alert {
  
  /// create a UIAlertController
  public static func with(title t: String?, message: String?, style: UIAlertControllerStyle, completion: (() -> Void)? = nil) -> UIAlertController {
    
    presentCompletion = completion
    return UIAlertController(title: t, message: message, preferredStyle: style)
  }
}

var presentCompletion: (() -> Void)?

public protocol AlertCreatable {
  
  func alert(with title: String?, message: String?, style: UIAlertControllerStyle, completion: (() -> Void)?) -> UIAlertController
}

public protocol AlertPresentable {
  
  // to present alert controller
  func show(on viewController: UIViewController?, completion: (() -> Void)?)
}

public protocol AlertActionBindable {
  
  // add a button to a alert controller with properties and handler
  func bind(button title: String, style: UIAlertActionStyle, enable: Bool, completion: ((UIAlertAction) -> Void)?) -> UIAlertController
  
  /// add a button to a alert controller with UIAlertController func
  func bind(action a: UIAlertAction) -> UIAlertController
}

public protocol AlertTextFieldBindable {
  
  /// add a textfield to a alert controller with properties and handler
  func bind(textfield text: String?, placeholder: String, secure: Bool, returnHandler: @escaping (UITextField) -> Void) -> UIAlertController
}


extension AlertCreatable where Self: NSObject {
  
  public func alert(with title: String?, message: String?, style: UIAlertControllerStyle, completion: (() -> Void)? = nil) -> UIAlertController {
    presentCompletion = completion
    return UIAlertController(title: title, message: message, preferredStyle: style)
  }
}

public extension AlertPresentable where Self: UIAlertController {
  
  func show(on viewController: UIViewController? = nil,
            completion: (() -> Void)? = nil) {
    
    UIApplication.shared.windows.forEach { (window) in
      if let alertController = window.rootViewController as? UIAlertController {
        alertController.dismiss(animated: false, completion: nil)
      }
      if let alertController = window.rootViewController?.presentedViewController as? UIAlertController {
        alertController.dismiss(animated: false, completion: nil)
      }
      if let alertController = window.rootViewController?.presentingViewController as? UIAlertController {
        alertController.dismiss(animated: false, completion: nil)
      }
    }

    // use user given viewController
    if let vc = viewController {
      let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
      if deviceIdiom == .pad {
        modalPresentationStyle = .popover
        if let popoverPC = popoverPresentationController {
          popoverPC.sourceView = vc.view
          popoverPC.sourceRect = CGRect(x: vc.view.bounds.midX,
                                        y: vc.view.bounds.midY,
                                        width: 0,
                                        height: 0)
          popoverPC.permittedArrowDirections = []
        }
      }
      if let presentedVC = vc.presentedViewController {
        presentedVC.dismiss(animated: false) {
          vc.present(self, animated: true, completion: completion ?? presentCompletion)
        }
      } else {
        vc.present(self, animated: true, completion: completion ?? presentCompletion)
      }
      return
    }
    
    // use topVC
    guard let rootVC = UIViewController.topVC else {
      print("Something wrong with your rootViewController at: \(#file), func: \(#function), line: \(#line)")
      return
    }
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    if deviceIdiom == .pad {
      modalPresentationStyle = .popover
      if let popoverPC = popoverPresentationController {
        popoverPC.sourceView = rootVC.view
        popoverPC.sourceRect = CGRect(x: rootVC.view.bounds.midX,
                                      y: rootVC.view.bounds.midY,
                                      width: 0,
                                      height: 0)
        popoverPC.permittedArrowDirections = []
      }
    }
    
    if let presentedVC = rootVC.presentedViewController {
      presentedVC.dismiss(animated: false) {
        rootVC.present(self, animated: true, completion: completion ?? presentCompletion)
      }
    } else {
      rootVC.present(self, animated: true, completion: completion ?? presentCompletion)
    }
  }
}

public extension AlertActionBindable where Self: UIAlertController {
  
  func bind(button title: String, style: UIAlertActionStyle = .default, enable: Bool = true, completion: ((UIAlertAction) -> Void)?) -> UIAlertController {
    
    let alertAction = UIAlertAction(title: title, style: style, handler: completion)
    alertAction.isEnabled = enable
    addAction(alertAction)
    
    return self
  }
  
  func bind(action a: UIAlertAction) -> UIAlertController {
    
    addAction(a)
    return self
  }
}

public extension AlertTextFieldBindable where Self: UIAlertController {
  
  func bind(textfield text: String? = nil, placeholder: String, secure: Bool = false, returnHandler: @escaping (UITextField) -> Void) -> UIAlertController {
    
    addTextField { (customTextField) in
      
      customTextField.text = text
      customTextField.placeholder = placeholder
      customTextField.isSecureTextEntry = secure
      customTextField.addTarget(self, action: #selector(self.textFieldDidBeginEdit), for: .editingChanged)
      returnHandler(customTextField)
    }
    return self
  }
}

public extension UIAlertController {
  
  @objc func textFieldDidBeginEdit() {
    
    guard let alertWindow = UIApplication.shared.windows.filter({ $0.rootViewController?.presentedViewController is UIAlertController }).first else {
      return
    }
    guard let alertController = alertWindow.rootViewController?.presentedViewController as? UIAlertController else {
      return
    }
    guard let usernameTextfield = alertController.textFields?.first,
      let passwordTextfield = alertController.textFields?.last,
      let confirmAction = alertController.actions.last else { return }
    
    confirmAction.isEnabled = (((usernameTextfield.text?.count ?? 0) > 0) && ((passwordTextfield.text?.count ?? 0) > 0))
  }
}


extension UIAlertController: AlertPresentable { }
extension UIAlertController: AlertActionBindable { }
extension UIAlertController: AlertTextFieldBindable { }


extension UIViewController {
  
  /// TOPPPPPP
  static var topVC: UIViewController? {
    
    let baseViewController = UIApplication.shared.keyWindow?.rootViewController
    
    if let nav = baseViewController as? UINavigationController {
      return nav.visibleViewController
    }
    
    if let tab = baseViewController as? UITabBarController {
      let navigationController = tab.moreNavigationController
      
      if let top = navigationController.topViewController, top.view.window != nil {
        return top
      } else if let selected = tab.selectedViewController {
        return selected
      }
    }
    
    if let presented = baseViewController?.presentedViewController {
      return presented
    }
    return baseViewController
  }
}
