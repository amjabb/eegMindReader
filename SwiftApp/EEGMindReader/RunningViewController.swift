//
//  RunningViewController.swift
//  EEGMindReader
//
//  Created by Amir Jabbari on 11/20/17.
//  Copyright © 2017 Amir Jabbari. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RunningViewController: UIViewController {

    // MARK: - UI Outlets
    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var runFirstSelectionButton: UIButton!
    @IBOutlet weak var runSecondSelectionButton: UIButton!
    
    // MARK: - Globals
    
    var ref: DatabaseReference!
    var theme: String?
    var optionOne: String = ""
    var optionTwo: String = ""
    
    // MARK: - Button Press Events
    
    @IBAction func firstSelectionRunning(_ sender: Any) {
        
    }
    
    @IBAction func secondSelectionRunning(_ sender: Any) {
    }
    
    // MARK: - User Functions
    
    /*******************************************************************************************************
        Name:  setThemeAndValues
        Brief: Set the theme from the firebase ref /theme save theme options in globals and assign to labels
     *******************************************************************************************************/
    func setThemeAndValues() {
        var _ = ref.child("theme").observeSingleEvent(of: .value, with: { (snapshot) in
            self.theme = snapshot.value as? String? ?? "Control"
            
            var _ = self.ref.child("\(self.theme?.lowercased() ?? "control")").observeSingleEvent(of: .value, with: { (snapshot) in
                let themeVal = snapshot.value
                if let themeDict = themeVal as? Dictionary<String, Int>? ?? [:]{
                    let themeArray = Array(themeDict.keys).sorted()
                    self.runFirstSelectionButton.setTitle(themeArray[0], for: [])
                    self.optionOne = themeArray[0]
                    self.runSecondSelectionButton.setTitle(themeArray[1], for: [])
                    self.optionTwo = themeArray[1]
                }
                
            })
            
        })
    }
    
    /*******************************************************************************************************
     Name:  enableCommandEventListener
     Brief: Enable the event listener for firebase ref /modelPrediction which is written too by the headset
            during the time which the data is being classified by the model.
     params: originalColorOne, originalColorTwo - load back the original color of the buttons if selected
     *******************************************************************************************************/
    func enableCommandEventListener(originalColorOne: UIColor?, originalColorTwo: UIColor?) {
        var _ = ref.child("modelPrediction").observe(DataEventType.value, with: { (snapshot) in
            if let value = snapshot.value as? String {
                if(Int(value) == 0){
                    self.actionLabel.text = "Running \(self.optionOne != "" ? self.optionOne : self.runFirstSelectionButton.titleLabel?.text  ?? "")"
                    self.runSecondSelectionButton.backgroundColor = UIColor.white
                    self.runSecondSelectionButton.setTitleColor(UIColor.black, for: [])
                    self.runFirstSelectionButton.backgroundColor = originalColorOne
                    self.runFirstSelectionButton.setTitleColor(UIColor.white, for: [])
                }
                else if(Int(value) == 1){
                    self.actionLabel.text = "Running \(self.optionTwo != "" ? self.optionTwo : self.runSecondSelectionButton.titleLabel?.text  ?? "")"
                    
                    self.runFirstSelectionButton.backgroundColor = UIColor.white
                    self.runFirstSelectionButton.setTitleColor(UIColor.black, for: [])
                    
                    self.runSecondSelectionButton.backgroundColor = originalColorTwo
                    self.runSecondSelectionButton.setTitleColor(UIColor.white, for: [])
                }
            }
        })
    }
    
    // MARK: - UI Event Handlers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        
        runFirstSelectionButton.layer.cornerRadius = 10
        runSecondSelectionButton.layer.cornerRadius = 10
        
        let originalColorOne = self.runFirstSelectionButton.backgroundColor
        let originalColorTwo = self.runSecondSelectionButton.backgroundColor
        
        setThemeAndValues()
        
        enableCommandEventListener(originalColorOne: originalColorOne, originalColorTwo: originalColorTwo)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
