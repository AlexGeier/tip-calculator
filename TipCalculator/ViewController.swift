//
//  ViewController.swift
//  TipCalculator
//
//  Created by Alex Geier on 1/13/20.
//  Copyright © 2020 Alex Geier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var tipPercentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipValueLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    
    var tipPercent = 0.1
    
    @IBAction func onBillAmountChanged(_ sender: Any) {
        // Hide the tip and total labels when the bill text field becomes empty
        if (billAmountTextField.text!.isEmpty) {
            UIView.animate(withDuration: 0.2) {
                self.tipLabel.alpha = 0
                self.totalLabel.alpha = 0
                self.tipValueLabel.alpha = 0
                self.totalValueLabel.alpha = 0
            }
        } else {
            // Update tip and total values every time the bill amount changes
            self.updateTotals()
            
            // If the tip and total labels are hidden, unhide them
            if (self.tipLabel.alpha == 0) {
                UIView.animate(withDuration: 0.2) {
                    self.tipLabel.alpha = 1
                    self.totalLabel.alpha = 1
                    self.tipValueLabel.alpha = 1
                    self.totalValueLabel.alpha = 1
                }
            }
        }
    }
    
    func updateTotals() {
        let bill = Double(billAmountTextField.text!) ?? 0
            
        let tip = bill * self.tipPercent
            self.tipValueLabel.text = String(format: "$%.2f", tip)
            
            let total = bill + tip
            self.totalValueLabel.text = String(format: "$%.2f", total)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Autofocus the bill amount text field when the view loads
        self.billAmountTextField.becomeFirstResponder()
        
        // Puts the tip percent segmented control directly above the keyboard
        self.startAvoidingKeyboard()
    }
    
    // Hide the keyboard when the background is tapped
    @IBAction func onTap(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func onTipPercentChanged(_ sender: Any) {
        switch self.tipPercentSegmentedControl.selectedSegmentIndex {
        case 0:
            self.tipPercent = 0.1
        case 1:
            self.tipPercent = 0.15
        case 2:
            self.tipPercent = 0.2
        default:
            self.tipPercent = 0.1
        }
        self.updateTotals()
    }
    
    func startAvoidingKeyboard()
    {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(onKeyboardFrameWillChangeNotificationReceived(_:)),
                         name: UIResponder.keyboardWillChangeFrameNotification,
                         object: nil)
    }
        
    // Logic from https://stackoverflow.com/questions/45399178/extend-ios-11-safe-area-to-include-the-keyboard/46566119
    @objc
    private func onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification)
    {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else {
                return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        
        
        // Show / Hide the tip percent segmented control depending on whether or not the keyboard is being shown
        UIView.animate(withDuration: 0.2) {
            self.tipPercentSegmentedControl.alpha = intersection.height == 0 ? 0 : 1
        }
        
        let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        let animationDuration: TimeInterval = (keyboardAnimationDuration as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveLinear.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: animationCurve,
                       animations: {
                        self.additionalSafeAreaInsets.bottom = intersection.height
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
