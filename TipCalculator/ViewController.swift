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
    
    let tipPercents = [
        0.10,
        0.15,
        0.20
    ]
    
    var selectedIndex = UserDefaults.standard.integer(forKey: "tipPercent")
    
    @IBAction func onBillAmountChanged(_ sender: Any) {
        // Automatically add a dollar sign to the textField when a number is entered
        if (!billAmountTextField.text!.contains("$")) {
            billAmountTextField.text = "$\(billAmountTextField.text!)"
        }
        
        // If the textField is empty (contains only a dollar sign), clear the bill text field and hide the labels
        if (billAmountTextField.text! == "$") {
            billAmountTextField.text = ""
            self.hideTotals()
            return
        }
        
        // Update tip and total values every time the bill amount changes
        self.updateTotals()
        
        // If the tip and total labels are hidden, unhide them
        if (self.tipLabel.alpha == 0) {
            self.showTotals()
        }
    }
    
    func showTotals() {
        self.setTotalsAlpha(1)
    }
    
    func hideTotals() {
        self.setTotalsAlpha(0)
    }
    
    func setTotalsAlpha(_ alpha: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.tipLabel.alpha = alpha
            self.totalLabel.alpha = alpha
            self.tipValueLabel.alpha = alpha
            self.totalValueLabel.alpha = alpha
        }
    }
    
    func updateTotals() {
        let bill = Double(billAmountTextField.text!.replacingOccurrences(of: "$", with: "")) ?? 0
        
        let tip = bill * self.tipPercents[selectedIndex]
        self.tipValueLabel.text = String(format: "$%.2f", tip)
        
        let total = bill + tip
        self.totalValueLabel.text = String(format: "$%.2f", total)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Update the selectedIndex here when the default value changes from the settings page
        self.selectedIndex = UserDefaults.standard.integer(forKey: "tipPercent")
        self.tipPercentSegmentedControl.selectedSegmentIndex = self.selectedIndex
        self.updateTotals()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Autofocus the bill amount text field when the view loads
        self.billAmountTextField.becomeFirstResponder()
        
        // Select the user's default tip percent when the view loads
        tipPercentSegmentedControl.selectedSegmentIndex = self.selectedIndex
        
        // Puts the tip percent segmented control directly above the keyboard
        self.startAvoidingKeyboard()
    }
    
    // Hide the keyboard when the background is tapped
    @IBAction func onTap(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func onTipPercentChanged(_ sender: Any) {
        self.selectedIndex = self.tipPercentSegmentedControl.selectedSegmentIndex
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
