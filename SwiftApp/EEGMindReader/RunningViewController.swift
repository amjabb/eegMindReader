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

    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var runFirstSelectionButton: UIButton!
    @IBOutlet weak var runSecondSelectionButton: UIButton!
    var ref: DatabaseReference!
    
    @IBAction func firstSelectionRunning(_ sender: Any) {
        
    }
    
    @IBAction func secondSelectionRunning(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        
        runFirstSelectionButton.layer.cornerRadius = 10
        runSecondSelectionButton.layer.cornerRadius = 10
        
        var _ = ref.child("modelPrediction").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? Int ?? 0
            if(value == 0){
                self.actionLabel.text = "Value of A is \(value)"
                self.runSecondSelectionButton.backgroundColor = UIColor.darkGray
                self.runFirstSelectionButton.backgroundColor = UIColor.blue
            }
            else if(value == 1){
                self.actionLabel.text = "Value of B is \(value)"
                self.runFirstSelectionButton.backgroundColor = UIColor.white
                self.runSecondSelectionButton.backgroundColor = UIColor.blue
            }
        })
        
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
