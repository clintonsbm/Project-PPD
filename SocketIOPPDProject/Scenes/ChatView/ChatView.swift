//
//  ChatView.swift
//  SocketIOPPDProject
//
//  Created by Clinton de Sá Barreto Maciel on 11/02/19.
//  Copyright © 2019 Clinton de Sá. All rights reserved.
//

import UIKit

protocol ChatViewDelegate: NSObjectProtocol {
    func send(message: String)
    func refresh()
}

class ChatView: UIView {
    
    // MARK: Statics
    
    let nibName = "ChatView"

    // MARK: UI
    
    let tableView = UITableView()
    let textView = UITextView()
    let sendButton = UIButton()
    
    // MARK: Control variable
    
    weak var delegate: ChatViewDelegate?
    private var messages: [Message] = []
    private var timer: Timer!

    // MARK: View lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    init(delegate: ChatViewDelegate) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.delegate = delegate
        setupView()
    }

    private func setupView() {
        // Timer
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        timer.fire()
        // View
        backgroundColor = .gray
        setupConstraints()
        // Setup table view
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: MessageTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: MessageTableViewCell.identifier)
        tableView.separatorStyle = .none
        // Text view
        textView.delegate = self
        // Button
        sendButton.setTitle("Enviar", for: .normal)
        sendButton.isEnabled = false
        sendButton.addTarget(self, action: #selector(sendMessageTarget), for: .touchDown)
    }
    
    private func setupConstraints() {
        addSubview(tableView)
        addSubview(textView)
        addSubview(sendButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: textView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 60),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sendButton.heightAnchor.constraint(equalTo: textView.heightAnchor)
            ])
        
        layoutIfNeeded()
    }
    
    // MARK: Actions
    
    @objc
    func sendMessageTarget() {
        delegate?.send(message: textView.text)
        addMessage(isFromCurrentUser: true, message: textView.text)
        textView.text = ""
        sendButton.isEnabled = false
    }
    
    @objc
    func refresh() {
        tableView.refreshControl?.endRefreshing()
        delegate?.refresh()
    }
    
    // MARK: Public methods
    
    func addMessage(isFromCurrentUser: Bool, message: String) {
        messages.append(Message(isFromCurrentUser: isFromCurrentUser, text: message))
        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: UITableView.RowAnimation.bottom)
    }
    
    func add(allMessages: [Message]) {
        if !allMessages.isEmpty {
            for messageIndex in self.messages.count..<allMessages.count {
                let newMessage = allMessages[messageIndex]
                messages.append(newMessage)
                tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: UITableView.RowAnimation.bottom)
            }
        }
    }
}

extension ChatView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = textView.text.trimmingCharacters(in: .whitespaces).count != 0
    }
}

extension ChatView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath)
        
        (cell as? MessageTableViewCell)?.setup(message: message)
        
        return cell
    }
}
