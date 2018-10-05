//
//  ChatController.swift
//  convenience-calling
//
//  Created by Eric Giannini on 5/30/18.
//  Copyright © 2018 Nexmo, Inc. All rights reserved.
//

import UIKit
import Stitch

class ChatController: UIViewController {
    
    // conversation for passing client
    var conversation: Conversation?
    
    @IBOutlet weak var tableView: UITableView!
    
    // textField for capturing text
    @IBOutlet weak var textField: UITextField!
    
    
    // create a call
    @IBAction func createCall(_ sender: Any) {
        
        call()
        
    }
    
    // sendBtn for sending text
    @IBAction func sendBtn(_ sender: Any) {
        
        do {
            // send method
            try conversation?.send(textField.text!)
            
        } catch let error {
            print(error)
        }
        
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self as? UITableViewDelegate
        tableView.dataSource = self
        
        // a handler for updating the textView with TextEvents
        conversation?.events.newEventReceived.subscribe(onSuccess: { (event) in
            guard let event = event as? TextEvent, event.isCurrentlyBeingSent == false else { return }
            
            guard let text = event.text else { return }
            
            self.textField.insertText(" \(text) \n ")

        }, onError: { (error) in
            
        })
        
    }

    // MARK: - Call Convenience Methods
    private func call() {
        
        let callAlert = UIAlertController(title: "Call", message: "Who would you like to call?", preferredStyle: .actionSheet)
        
        conversation?.members.forEach{ member in
            callAlert.addAction(UIAlertAction(title: member.user.name, style: .default, handler: { (action) in
                ConversationClient.instance.media.call([member.user.name], onSuccess: { result in
                    // if you would like to display a UI for calling...
                }, onError: { networkError in
                    // if you would like to display a log for error...
                })
            }))
        }
        
        self.present(callAlert, animated: true, completion: nil)

    }
    
}

extension ChatController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation!.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellWithIdentifier", for: indexPath)
        
        let message = conversation?.events[indexPath.row] as? TextEvent
        
        cell.textLabel?.text = message?.text
        
        return cell;
    }

}

