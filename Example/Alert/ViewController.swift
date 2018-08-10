//
//  ViewController.swift
//  AlertTest
//
//  Created by Stan Liu on 07/11/2016.
//  Copyright © 2016 Stan Liu. All rights reserved.
//

import UIKit
import SwiftAlert

class ViewController: UIViewController {
  
  var alertController: UIAlertController!
  @IBOutlet weak var buttonAmountLabel: UILabel!
  @IBOutlet weak var textfieldAmountLabel: UILabel!
  
  var defaultAlertStyle: UIAlertControllerStyle = .alert
  var btn: Int! = 0
  var tex: Int! = 0
  
  override func viewDidLoad() {
    buttonAmountLabel.text = "0"
    textfieldAmountLabel.text = "0"
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  @IBAction func increaseButton(_ sender: Any) {
    
    btn = btn + 1
    buttonAmountLabel.text = "\(btn!)"
  }
  
  
  @IBAction func decreaseButton(_ sender: Any) {
    
    if btn == 0 { return }
    
    btn = btn - 1
    buttonAmountLabel.text = "\(btn!)"
  }
  
  
  @IBAction func increaseTextfield(_ sender: Any) {
    
    tex = tex + 1
    textfieldAmountLabel.text = "\(tex!)"
  }
  
  
  @IBAction func decreaseTextfield(_ sender: Any) {
    
    if tex == 0 { return }
    
    tex = tex - 1
    textfieldAmountLabel.text = "\(tex!)"
  }
  
  @IBAction func segmentControlDidTap(_ sender: Any) {
    
    guard let segment = (sender as? UISegmentedControl) else {
      return
    }
    if segment.selectedSegmentIndex == 0 {
      defaultAlertStyle = .alert
    } else if segment.selectedSegmentIndex == 1 {
      defaultAlertStyle = .actionSheet
    }
  }
  
  @IBAction func presentAlert(_ sender: Any) {
    
    if btn == 0 {
      
      Alert.with(title: "Warning", message: "Button at least 1", style: .alert).bind(button: "I know!", style: .default, completion: nil).show()
			return
    }
    
    alertController = Alert.with(title: nil, message: nil, style: defaultAlertStyle)
    
    for i in 0 ..< btn {
      
      let _ = alertController.bind(button: "Button \(i + 1)", style: .default) {
        (action) in
      }
    }
    
    for j in 0 ..< tex {
      
      let _ = alertController.bind(textfield: "Textfield \(j + 1)", placeholder: "I am a textfield", secure: false, returnHandler: { (textfield) in
        
      })
    }
    
    alertController.show()
    
  }
  
}
