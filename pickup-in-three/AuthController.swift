//
//  AuthController.swift
//  pickup-in-three
//
//  Created by Emily on 7/3/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class LoginController: UIViewController {
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    var ref: FIRDatabaseReference!
    
    @IBAction func login(_ sender: Any) {
        if self.email.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert);
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
            alertController.addAction(defaultAction);
            
            self.present(alertController, animated: true, completion: nil);
            
        }
        else {
            
            FIRAuth.auth()?.signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                
                if error == nil {
                    
                    // set groups array
                    self.ref = FIRDatabase.database().reference();
                    
                    // set logged user
                    UserDefaults.standard.set(self.email.text!, forKey: userDetails.username);
                    UserDefaults.standard.set(self.password.text!, forKey: userDetails.password);
                    
                    appFunctions().fadeTransition(identifier: "Home");
                    
                }
                else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert);
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
                    alertController.addAction(defaultAction);
                    
                    self.present(alertController, animated: true, completion: nil);
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.hideKeyboardWhenTappedAround();
        
        // no logged user
        if let username = UserDefaults.standard.string(forKey: userDetails.username), let password = UserDefaults.standard.string(forKey: userDetails.password) {
            if (username != "") {
                FIRAuth.auth()?.signIn(withEmail: username, password: password) { (user, error) in
                    appFunctions().fadeTransition(identifier: "Home");
                }
            }
        }

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
}

class RegisterController: UIViewController {
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var username: UITextField!
    
    var ref:FIRDatabaseReference!
    
    @IBAction func register(_ sender: Any) {
        self.ref = FIRDatabase.database().reference()
        if email.text! == "" || password.text! == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert);
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
            alertController.addAction(defaultAction);
            
            present(alertController, animated: true, completion: nil);
            
        } else {
            FIRAuth.auth()?.createUser(withEmail: email.text!, password: password.text!) { (user, error) in
                
                if error == nil {
                    // set user details
                    self.ref.child("users").child((user?.uid)!).setValue([
                        "username": self.username.text!,
                        "aboutMe" : "default",
                        "favorites": [
                            "0": "default",
                        ],
                        "liked" : [
                            "0": "default",
                        ],
                        "lines" : [
                            "0": "default",
                        ],
                        "points" : 0,
                        "requests" : [
                            "0": "default",
                        ],
                        "base64string": "default",
                    ]);
                    
                    appFunctions().fadeTransition(identifier: "Home");
                    
                }
                else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert);
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
                    alertController.addAction(defaultAction);
                    
                    self.present(alertController, animated: true, completion: nil);
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.hideKeyboardWhenTappedAround();
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
}
