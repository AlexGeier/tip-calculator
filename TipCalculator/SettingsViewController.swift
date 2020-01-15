//
//  SettingsViewController.swift
//  TipCalculator
//
//  Created by Alex Geier on 1/15/20.
//  Copyright © 2020 Alex Geier. All rights reserved.
//

import UIKit
import SwiftUI

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let settingsHostingController = SettingsHostingController()
        settingsHostingController.view.frame = view.bounds
        view.addSubview(settingsHostingController.view)
    }
}

struct SettingsFormView: View {
    @State var selectedIndex = UserDefaults.standard.integer(forKey: "tipPercent")
        
    let tipPercentages: [CGFloat] = [
        0.10,
        0.15,
        0.20
    ]
    
    var body: some View {
        Form {
            Picker("Default Tip Percent", selection: self.$selectedIndex) {
                ForEach(0 ..< tipPercentages.count) { index in
                    Text(String(format: "%.0f%%", self.tipPercentages[index] * 100))
                }
            }
            .onReceive([self.selectedIndex].publisher.first()) { (value) in
                UserDefaults.standard.set(self.selectedIndex, forKey: "tipPercent")
            }
        }
    }
}

class SettingsHostingController: UIHostingController<SettingsFormView> {
    init() {
        super.init(rootView: SettingsFormView())
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: SettingsFormView())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
