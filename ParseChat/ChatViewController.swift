//
//  ChatViewController.swift
//  ParseChat
//
//  Created by Holly French on 5/1/15.
//  Copyright (c) 2015 Holly French. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var messageText: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onTimer", userInfo: nil, repeats: true)

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onSubmitMessage(sender: AnyObject) {
       submitMessage()
    }
    
    func submitMessage() {
        var message = PFObject(className:"Message")
        
        message["text"] = messageText.text
        messageText.text = ""
        
        message.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved, so get messages.
                self.getMessages()
            } else {
                // There was a problem, check error.description
                println("could not save the message")
                println(error)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MessageViewCell", forIndexPath: indexPath) as! MessageViewCell
        var messageText = messages![indexPath.row]
        cell.messageCellText.text = messageText["text"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func onTimer() {
        getMessages()
    }
    
    func getMessages() {
        self.messages = []
        var query = PFQuery(className:"Message")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.messages?.append(object)
                    }
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }


    }

}
