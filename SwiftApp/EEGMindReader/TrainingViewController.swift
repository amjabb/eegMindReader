//
//  TrainingViewController.swift
//  EEGMindReader
//
//  Created by Amir Jabbari on 11/20/17.
//  Copyright © 2017 Amir Jabbari. All rights reserved.
//

import UIKit
import FirebaseDatabase

/*
 TrainingViewController to train, data, initial load on button press to initialize EEG sensor.
 Timer to train two values, options to change values labels.
 Once both values are trained segue to RunningViewController
 */

class TrainingViewController: UIViewController {

    // MARK: - UI Outlets

    @IBOutlet weak var trainingLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var selectionOne: UIButton!
    @IBOutlet weak var selectionTwo: UIButton!
    @IBOutlet weak var changeThemeButton: UIBarButtonItem!
    
    // MARK: - Globals -------------------------------------------------------------------------------------------------------------->

    var ref: DatabaseReference!
    let secondsConst = 15
    var seconds = 15 //This variable will hold a starting value of seconds.
    let timeForEEGSensorInit:UInt32 = 8
    var timer = Timer()
    var isSeletionOneSelected = false
    var isSelectionTwoSelected = false
    var isSelectionOneTrained = false
    var isSelectionTwoTrained = false
    var defaultTheme = "Control"
    var theme:String = ""
    
    
    // MARK: - Button Event Handlers -------------------------------------------------------------------------------------------------------------->
    
    /*******************************************************************************************************
     Name:  changeThemeButtonPress
     Brief: Top right corner '+' button press display alert controller to show existing theme options.
     *******************************************************************************************************/
    @IBAction func changeThemeButtonPress(_ sender: Any) {
        
        //init controller
        let changeThemeAlertController = UIAlertController(title: "Change Theme", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        //Default Action
        let controlAction = UIAlertAction(title: "Control", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.selectTheme(themeName: "Control", option1: "Start", option2: "Stop")})
        //Actions
        let colorsAction = UIAlertAction(title: "Colors", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.selectTheme(themeName: "Colors", option1: "Red", option2: "Blue")})
        let lettersAction = UIAlertAction(title: "Letters", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.selectTheme(themeName: "Letters", option1: "A", option2: "B")})
        let addNewAction = UIAlertAction(title: "Add New...", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.addNewOption()})
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
        
        //Bind actions to controller
        changeThemeAlertController.addAction(controlAction)
        changeThemeAlertController.addAction(colorsAction)
        changeThemeAlertController.addAction(lettersAction)
        changeThemeAlertController.addAction(addNewAction)
        changeThemeAlertController.addAction(cancelAction)
        
        self.present(changeThemeAlertController, animated: true, completion:{})
    }
    
    /*******************************************************************************************************
     Name:  selectSelectionOne
     Brief: On button press, if first button to be pressed toggle training start, start timer and update
            firebase ref /training ["trainingOne"] to indicate that training is happening.
     *******************************************************************************************************/
    @IBAction func selectSelectionOne(_ sender: Any) {
        if(!isSelectionTwoTrained){
            var updateValues = ["trainingStart":1]
            ref.child("training").updateChildValues(updateValues)
            //toggle training start so that sequence_mgmt.js receives start signal and launches open_bci.py
            updateValues = ["trainingStart":0]
            ref.child("training").updateChildValues(updateValues)
            
            addLoadingOverlay(timeToLoad: timeForEEGSensorInit, messageToDisplay: "Starting EEG Headset...")
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
    
    /*******************************************************************************************************
     Name:  selectSelectionTwo
     Brief: On button press, if first button to be pressed toggle training start, start timer and update
            firebase ref /training ["trainingTwo"] to indicate that training is happening.
     *******************************************************************************************************/
    @IBAction func selectSelectionTwo(_ sender: Any) {
        if(!isSelectionOneTrained){
            var updateValues = ["trainingStart":1]
            ref.child("training").updateChildValues(updateValues)
            //toggle training start so that sequence_mgmt.js receives start signal and launches open_bci.py
            updateValues = ["trainingStart":0]
            ref.child("training").updateChildValues(updateValues)
            
            addLoadingOverlay(timeToLoad: timeForEEGSensorInit, messageToDisplay: "Starting EEG Headset...")
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
    
    // MARK: - User Functions -------------------------------------------------------------------------------------------------------------->
    
    /*******************************************************************************************************
     Name:  initStoryAlertController
     Brief: Modal Alert view is displayed with instructions upon first thing when view loads.
     *******************************************************************************************************/
    func initStoryAlertController() {
        let storyAlertController = UIAlertController(title: "Before you begin...", message:
            "This is where it all begins, you have \(secondsConst) seconds, to train each action.\n So think about something vivid, picture it in your head.\n Once you are finished with the first action the timer will reset and you can train the second action.\n Once you are finished the world is at your command(or maybe just this app).", preferredStyle: UIAlertControllerStyle.alert)
        storyAlertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(storyAlertController, animated: true, completion: nil)
    }
    
    /*******************************************************************************************************
     Name:  updateTimer
     Brief: Function gets called every second once on button press training is occuring update label
            noting which option is training, count down the timer label showing number of seconds
            remaining and update values of option training in firebase ref /training. Once both options
            are trained segue to next VC.
     *******************************************************************************************************/
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
    
    /*******************************************************************************************************
     Name:  runTimer
     Brief: Start the timer and bind it to the updateTimer function
     *******************************************************************************************************/
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(TrainingViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    /*******************************************************************************************************
     Name:  getThemeFromFirebase
     Brief: Register event listener to update global theme
     *******************************************************************************************************/
    func getThemeFromFirebase() {
        var _ = ref.child("theme").observe(DataEventType.value, with: { (snapshot) in
            self.theme = snapshot.value as? String ?? ""
        })
    }
    
    /*******************************************************************************************************
     Name:  adjustLabelFonts
     Brief: Make the labels in the button such that the text size will adapt to the available size.
     *******************************************************************************************************/
    func adjustLabelFonts(){
        self.selectionOne.titleLabel?.adjustsFontSizeToFitWidth = true
        self.selectionOne.titleLabel?.minimumScaleFactor = 0.2
        
        self.selectionTwo.titleLabel?.adjustsFontSizeToFitWidth = true
        self.selectionTwo.titleLabel?.minimumScaleFactor = 0.2
    }
    
    /*******************************************************************************************************
     Name:  selectTheme
     Brief: Adjust the font size if required, then set the title of buttons and the theme, update firebase.
     param: themeName
     param: option1
     param: option2
     *******************************************************************************************************/
    func selectTheme(themeName:String, option1:String, option2:String){
        adjustLabelFonts()
        
        self.selectionOne.setTitle(option1, for: UIControlState.normal)
        self.selectionTwo.setTitle(option2, for: UIControlState.normal)
    
        self.theme = themeName
        
        let updateTheme = ["theme": themeName, themeName.lowercased():[option2:0, option1:1]] as [String : Any]
        ref.updateChildValues(updateTheme)
        
    }
    
    /*******************************************************************************************************
     Name:  addNewOption
     Brief: Modal alert view with input fields for new theme and options.
     *******************************************************************************************************/
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
        
        storyAlertController.addAction(UIAlertAction(title: "Cancel", style: .destructive ,handler: nil))
        
        self.present(storyAlertController, animated: true, completion: nil)
    }
    
    /*******************************************************************************************************
     Name:  saveNewTheme
     Brief: TODO: New options should be cached and loaded
     *******************************************************************************************************/
    func saveNewTheme() {
        
    }
    
    /*******************************************************************************************************
     Name:  resetGlobalVariablesForSession
     Brief: Reset globals every time page appears, even on back button from Navigation Controller
     *******************************************************************************************************/
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
    
    /*******************************************************************************************************
     Name:  addLoadingOverlay
     Brief: Wait for EEG sensor to initialize, displays a modal Alert view loading icon.
     param: timeToLoad
     *******************************************************************************************************/
    func addLoadingOverlay(timeToLoad:UInt32, messageToDisplay:String ){
        let alert = UIAlertController(title: nil, message: messageToDisplay, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 55, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: {sleep(timeToLoad)})
    }
    
    // MARK: - UI Event Handlers -------------------------------------------------------------------------------------------------------------->
    
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

}
