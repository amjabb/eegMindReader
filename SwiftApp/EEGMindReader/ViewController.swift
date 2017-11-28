//
//  ViewController.swift
//  EEGMindReader
//
//  Created by Amir Jabbari on 11/18/17.
//  Copyright © 2017 Amir Jabbari. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    var ref: DatabaseReference!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var trainButton: UIButton!
    
    @IBAction func sendTrainSignal(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Round button
        trainButton.layer.cornerRadius = 0.5 * trainButton.bounds.size.width
        trainButton.clipsToBounds = true
        
        //Access firebase
        ref = Database.database().reference()
        let initValues = ["letters":["A":0, "B":1], "training": ["trainingStart": 0, "trainingDone": 0, "trainingOne": 0, "trainingTwo": 0],  "theme": "Control", "appStart": 1, "appDone": 0] as [String : Any]
        ref.updateChildValues(initValues)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

