//
//  MessageTableViewCell.swift
//  SocketIOPPDProject
//
//  Created by Clinton de Sá Barreto Maciel on 11/02/19.
//  Copyright © 2019 Clinton de Sá. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    // MARK: Static
    
    static let nibName = "MessageTableViewCell"
    static let identifier = "messageCell"
    
    // MARK: Outlets
    
    @IBOutlet weak var chatBallonImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Setup

    func setup(message: Message) {
        textView.text = message.text
        
        textView.textAlignment = message.isFromCurrentUser == true ? NSTextAlignment.right : NSTextAlignment.left
//        chatBallonImageView.image = message.isFromCurrentUser == true ? UIImage(named: "chatBalloonSelf")! : UIImage(named: "chatBalloonRemote")!
    }
}
