//
//  RequestController.swift
//  pickup-in-three
//
//  Created by Emily on 9/27/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RequestController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref: FIRDatabaseReference!
    var requests: [[String]] = []
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference();
        ref.child("request").observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            for line in snapshot.children {
                if ((line as AnyObject).key != "0") {
                    let fields = ((line as AnyObject).value).components(separatedBy: .whitespaces).filter {!$0.isEmpty}
                    self.requests.append(fields);
                    self.tableView.reloadData();
                }
            }
        }
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // tableView -- START MARKER
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count;
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RequestCell = self.tableView.dequeueReusableCell(withIdentifier: "RequestCell") as! RequestCell
        
        cell.first.text = requests[indexPath.row][0];
        cell.second.text = requests[indexPath.row][1];
        cell.third.text = requests[indexPath.row][2];
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Create", message: "The required words are: \(requests[indexPath.row][0]), \(requests[indexPath.row][1]), and \(requests[indexPath.row][2]).", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
        }

        let defaultAction = UIAlertAction(title: "Submit", style: .cancel, handler: { (_) in
            let textField = alertController.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")

            if  (alertController.textFields![0].text?.range(of: self.requests[indexPath.row][0].lowercased()) != nil) &&
                (alertController.textFields![0].text?.range(of: self.requests[indexPath.row][1].lowercased()) != nil) &&
                (alertController.textFields![0].text?.range(of: self.requests[indexPath.row][2].lowercased()) != nil) {
                
                self.ref.child("lines").child(alertController.textFields![0].text!).setValue([
                    "keys": [
                        "1" : "\(self.requests[indexPath.row][0])",
                        "2" : "\(self.requests[indexPath.row][1])",
                        "3" : "\(self.requests[indexPath.row][2])",
                    ],
                    "likes" : 0,
                    "username" : FIRAuth.auth()!.currentUser!.uid,
                ] as NSDictionary);
                
                // TODO: Remove request after x pickup lines submitted
            }
            else {
                let alertController = UIAlertController(title: "Error", message: "Required words were not present.", preferredStyle: .alert);
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil);
                alertController.addAction(defaultAction);
                self.present(alertController, animated: true, completion: nil);
            }
        });
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // tableView -- END MARKER
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class RequestCell: UITableViewCell {
    @IBOutlet var first: UILabel!
    @IBOutlet var second: UILabel!
    @IBOutlet var third: UILabel!
}
