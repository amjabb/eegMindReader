//
//  TrainingViewController.swift
//  EEGMindReader
//
//  Created by Amir Jabbari on 11/20/17.
//  Copyright © 2017 Amir Jabbari. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TrainingViewController: UIViewController {

    @IBOutlet weak var trainingLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var selectionOne: UIButton!
    @IBOutlet weak var selectionTwo: UIButton!
    @IBOutlet weak var changeThemeButton: UIBarButtonItem!
    
    var ref: DatabaseReference!
    let secondsConst = 15
    var seconds = 15 //This variable will hold a starting value of seconds.
    var timer = Timer()
    var isSeletionOneSelected = false
    var isSelectionTwoSelected = false
    var isSelectionOneTrained = false
    var isSelectionTwoTrained = false
    var defaultTheme = "Control"
    var theme:String = ""
    
    
    @IBAction func changeThemeButtonPress(_ sender: Any) {
        
        let changeThemeAlertController = UIAlertController(title: "Change Theme", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //Default Action
        let controlAction = UIAlertAction(title: "Control", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.selectTheme(themeName: "Control", option1: "Start", option2: "Stop")})

        
        let colorsAction = UIAlertAction(title: "Colors", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.selectTheme(themeName: "Colors", option1: "Red", option2: "Blue")})
        
        let lettersAction = UIAlertAction(title: "Letters", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.selectTheme(themeName: "Letters", option1: "A", option2: "B")})
        
        let addNewAction = UIAlertAction(title: "Add New...", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.addNewOption()})
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
        
        changeThemeAlertController.addAction(controlAction)
        changeThemeAlertController.addAction(colorsAction)
        changeThemeAlertController.addAction(lettersAction)
        changeThemeAlertController.addAction(addNewAction)
        changeThemeAlertController.addAction(cancelAction)
        
        self.present(changeThemeAlertController, animated: true, completion:{})
        
    }
    
    @IBAction func selectSelectionOne(_ sender: Any) {
        if(!isSelectionTwoTrained){
            var updateValues = ["trainingStart":1]
            ref.child("training").updateChildValues(updateValues)
            //toggle training start so that sequence_mgmt.js receives start signal and launches open_bci.py
            updateValues = ["trainingStart":0]
            ref.child("training").updateChildValues(updateValues)
            addLoadingOverlay(timeToLoad: 4)
            dismiss(animated: false, completion: nil)
        }
        selectionTwo.isEnabled = false
        isSeletionOneSelected = true
        seconds = secondsConst
        timer.invalidate()
        runTimer() //async timer call
        isSelectionOneTrained = true
        trainingLabel.text = "Training \(selectionOne.titleLabel?.text ?? "")"
        let updateValues = ["trainingOne":1]
        ref.child("training").updateChildValues(updateValues)
    }
    
    @IBAction func selectSelectionTwo(_ sender: Any) {
        if(!isSelectionOneTrained){
            var updateValues = ["trainingStart":1]
            ref.child("training").updateChildValues(updateValues)
            //toggle training start so that sequence_mgmt.js receives start signal and launches open_bci.py
            updateValues = ["trainingStart":0]
            ref.child("training").updateChildValues(updateValues)
            addLoadingOverlay(timeToLoad: 4)
            dismiss(animated: false, completion: nil)
        }
        selectionOne.isEnabled = false
        isSelectionTwoSelected = true
        timer.invalidate()
        seconds = secondsConst
        runTimer() //async timer call
        isSelectionTwoTrained = true
        trainingLabel.text = "Training \(selectionTwo.titleLabel?.text ?? "")"
        let updateValues = ["trainingTwo":1]
        ref.child("training").updateChildValues(updateValues)
    }
    
    @objc func updateTimer() {
        seconds -= 1     //This will decrement(count down)the seconds.
        timerLabel.text = "\(seconds)" //This will update the label.
        if(seconds == 0){
            timer.invalidate()
            if(isSeletionOneSelected){
                selectionOne.isEnabled = false
                selectionTwo.isEnabled = true
                trainingLabel.text = "Select \(selectionTwo.titleLabel?.text ?? "")"
                let updateValues = ["trainingOne":0]
                ref.child("training").updateChildValues(updateValues)
            }
            if(isSelectionTwoSelected) {
                selectionOne.isEnabled = true
                selectionTwo.isEnabled = false
                trainingLabel.text = "Select \(selectionOne.titleLabel?.text ?? "")"
                let updateValues = ["trainingTwo":0]
                ref.child("training").updateChildValues(updateValues)
            }
            if(isSelectionOneTrained && isSelectionTwoTrained){
                let updateValues = ["trainingDone":1]
                ref.child("training").updateChildValues(updateValues)
                performSegue(withIdentifier: "finishedTraining", sender: Any?.self)
            }
            
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(TrainingViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func initStoryAlertController() {
        let storyAlertController = UIAlertController(title: "Before you begin...", message:
            "This is where it all begins, you have \(secondsConst) seconds, to train each action.\n So think about something vivid, picture it in your head.\n Once you are finished with the first action the timer will reset and you can train the second action.\n Once you are finished the world is at your command(or maybe just this app).", preferredStyle: UIAlertControllerStyle.alert)
        storyAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(storyAlertController, animated: true, completion: nil)
    }
    
    func getThemeFromFirebase() {
        var _ = ref.child("theme").observe(DataEventType.value, with: { (snapshot) in
            self.theme = snapshot.value as? String ?? ""
        })
    }
    
    func adjustLabelFonts(){
        self.selectionOne.titleLabel?.adjustsFontSizeToFitWidth = true
        self.selectionOne.titleLabel?.minimumScaleFactor = 0.2
        
        self.selectionTwo.titleLabel?.adjustsFontSizeToFitWidth = true
        self.selectionTwo.titleLabel?.minimumScaleFactor = 0.2
    }
    
    func selectTheme(themeName:String, option1:String, option2:String){
        adjustLabelFonts()
        
        self.selectionOne.setTitle(option1, for: UIControlState.normal)
        self.selectionTwo.setTitle(option2, for: UIControlState.normal)
    
        self.theme = themeName
        
        let updateTheme = ["theme": themeName, themeName.lowercased():[option2:0, option1:1]] as [String : Any]
        ref.updateChildValues(updateTheme)
        
    }
    
    func addNewOption() {
        let storyAlertController = UIAlertController(title: "Add New Theme", message:
            "", preferredStyle: UIAlertControllerStyle.alert)
        
        storyAlertController.addTextField { textField in
            textField.placeholder = "Theme Name"
        }
        storyAlertController.addTextField { textField in
            textField.placeholder = "Option 1"
        }
        storyAlertController.addTextField { textField in
            textField.placeholder = "Option 2"
        }
        
        let themeNameTextField = storyAlertController.textFields![0] as UITextField
        let optionOneTextField = storyAlertController.textFields![1] as UITextField
        let optionTwoTextField = storyAlertController.textFields![2] as UITextField
        
        storyAlertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (alert: UIAlertAction!)  in self.selectTheme(themeName: themeNameTextField.text ?? "", option1: optionOneTextField.text ?? "", option2: optionTwoTextField.text ?? "")}))
        
        //storyAlertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (alert: UIAlertAction!)  in self.saveNewTheme()}))
        storyAlertController.addAction(UIAlertAction(title: "Cancel", style: .destructive ,handler: nil))
        
        self.present(storyAlertController, animated: true, completion: nil)
    }
    
    func saveNewTheme() {
        
    }
    
    func resetGlobalVariablesForSession(){
        timer.invalidate()
        selectionOne.isEnabled = true
        selectionTwo.isEnabled = false
        isSeletionOneSelected = false
        isSelectionTwoSelected = false
        isSelectionOneTrained = false
        isSelectionTwoTrained = false
        defaultTheme = "Control"
        theme = ""
        
        adjustLabelFonts()
        self.selectionOne.setTitle("Start", for: UIControlState.normal)
        self.selectionTwo.setTitle("Stop", for: UIControlState.normal)
    }
    
    func addLoadingOverlay(timeToLoad:UInt32){
        let alert = UIAlertController(title: nil, message: "Starting EEG Headset...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 55, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: {sleep(timeToLoad)})
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        ref = Database.database().reference()
        
        resetGlobalVariablesForSession()
        
        initStoryAlertController()
        
        getThemeFromFirebase()
        
        //Buttons round edge
        selectionOne.layer.cornerRadius = 10
        selectionTwo.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
