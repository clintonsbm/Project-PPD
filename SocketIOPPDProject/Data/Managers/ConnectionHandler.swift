//
//  SocketManager.swift
//  ProjectPPD
//
//  Created by Clinton de Sá Barreto Maciel on 06/02/19.
//  Copyright © 2019 Clinton de Sá. All rights reserved.
//

import UIKit
import SocketIO

protocol ConnectionHandlerDelegate: NSObjectProtocol {
    func connected()
    func disconnected()
    func startChat(username: String?)
    func received(message: String?)
}

extension ConnectionHandlerDelegate {
    func connected() {
        print("Conneted")
    }
    
    func disconnected() {
        print("Disconnected")
    }
    
    func startChat(username: String?) {
        print("Received username: \(username ?? "Empty username error")")
    }
    
    func received(message: String?) {
        print("\n\nReceived message: \(message ?? "Empty message error")\n\n\n")
    }
}

protocol GameHandlerDelegate: NSObjectProtocol {
    func receiveRemove(letter: String?)
    func receiveAdd(letter: String?)
    func receiveRequestToConfirm()
    func receiveResponseToConfirm(response: Bool?, lettersToRemove: [String]?)
    func receiveSortLetter(letter: String?, letterIndex: Int?)
    func receiveOtherUserResign()
    func receiveOtherUserWon()
    func receiveRestartMatch()
}

class ConnectionHandler: NSObject {
    
    // MARK: Singleton
    
    static let shared = ConnectionHandler()
    
    // MARK: Connection configuration
    
    private let chatPort = "8900"
    private let chatSocketName = "/Chat"
    
    // MARK: Default names
    
    static let playerOne = "1"
    static let playerTwo = "2"
    
    // MARK: Event names
    // Chat
    private let startChatEvent = "startChat"
    private let sendMessageEvent = "sendMessage"
    private let receiveMessageEvent = "receiveMessage"
    // Game
    private let sendRemoveLetterEvent = "sendRemoveLetter"
    private let receiveRemoveLetterEvent = "removeLetter"
    private let sendAddLetterEvent = "sendAddLetter"
    private let receiveAddLetterEvent = "addLetter"
    private let sendRequestToConfirmEvent = "sendRequestToConfirm"
    private let receiveRequestToConfirmEvent = "requestToConfirm"
    private let sendResponseToConfirmEvent = "sendResponseToConfirm"
    private let receiveResponseToConfirmeEvent = "responseToConfirm"
    private let sendSortLetterEvent = "sendSortLetter"
    private let receiveSortLetterEvent = "sortLetter"
    private let receiveOtherUserResignEvent = "otherUserResign"
    private let sendCurrentUserWonEvent = "sendCurrentUserWon"
    private let receiveOtherUserWonEvent = "otherUserWon"
    private let sendRestartMatchEvent = "sendRestartMatch"
    private let receiveRestartMatchEvent = "restartMatch"
    
    // MARK: Control variables
    
    private weak var delegate: ConnectionHandlerDelegate?
    private weak var gameDelegate: GameHandlerDelegate?
    private var socketManager: SocketManager?
    private var chatSocket: SocketIOClient?
    private var gameSocket: SocketIOClient?
    
    private var username: String = ""
    
    override init() {
        super.init()
        
        socketManager = SocketManager(socketURL: URL(string: "http://localhost:\(chatPort)")!, config: [.log(true), .compress])
        socketManager?.reconnects = false
        chatSocket = socketManager!.defaultSocket
        
        setupChatSocketEvents()
        setupGameSocketEvents()
    }
    
    // MARK: Setup events
    
    private func setupChatSocketEvents() {
        chatSocket!.on(clientEvent: .connect) {data, ack in
            self.delegate?.connected()
        }
        
        chatSocket!.on(clientEvent: .disconnect) { (_, _) in
            self.delegate?.disconnected()
        }
        
        chatSocket!.on(startChatEvent) {data, ack in
            self.delegate?.startChat(username: data[0] as? String)
        }
        
        chatSocket!.on(receiveMessageEvent) { (data, ack) in
            self.delegate?.received(message: data[0] as? String)
        }
    }
    
    private func setupGameSocketEvents() {
        chatSocket!.on(receiveRemoveLetterEvent) { (data, ack) in
            self.gameDelegate?.receiveRemove(letter: data.first as? String)
        }
        chatSocket!.on(receiveAddLetterEvent) { (data, ack) in
            self.gameDelegate?.receiveAdd(letter: data.first as? String)
        }
        chatSocket!.on(receiveRequestToConfirmEvent) { (_, _) in
            self.gameDelegate?.receiveRequestToConfirm()
        }
        chatSocket!.on(receiveResponseToConfirmeEvent) { (data, ack) in
            self.gameDelegate?.receiveResponseToConfirm(response: data.first as? Bool, lettersToRemove: data[1] as? [String])
        }
        chatSocket!.on(receiveSortLetterEvent) { (data, ack) in
            self.gameDelegate?.receiveSortLetter(letter: data.first as? String, letterIndex: data[1] as? Int)
        }
        chatSocket!.on(receiveOtherUserResignEvent) { (data, ack) in
            self.gameDelegate?.receiveOtherUserResign()
        }
        chatSocket!.on(receiveOtherUserWonEvent) { (data, ack) in
            self.gameDelegate?.receiveOtherUserWon()
        }
        chatSocket!.on(receiveRestartMatchEvent) { (data, ack) in
            self.gameDelegate?.receiveRestartMatch()
        }
    }
    
    // MARK: Public methods
    
    func connectSockets() {
        chatSocket?.connect()
        gameSocket?.connect()
    }
    
    func disconnectSockets() {
        chatSocket?.disconnect()
        gameSocket?.disconnect()
    }
    
    func set(newDelegate: ConnectionHandlerDelegate) {
        delegate = newDelegate
    }
    
    func set(newDelegate: GameHandlerDelegate) {
        gameDelegate = newDelegate
    }
    
    func setUsername(newUsername: String) {
        username = newUsername
    }
    
    func getUsername() -> String {
        return username
    }
    
    // MARK: Chat emit methods
    
    func send(message: String) {
        socketManager!.defaultSocket.emit(sendMessageEvent, username, message)
    }
    
    // MARK: Game emit methods
    
    func sendRemove(letter: String) {
        socketManager!.defaultSocket.emit(sendRemoveLetterEvent, username, letter)
    }
    
    func sendAdd(letter: String) {
        socketManager!.defaultSocket.emit(sendAddLetterEvent, username, letter)
    }
    
    func sendRequestToConfirm() {
        socketManager!.defaultSocket.emit(sendRequestToConfirmEvent, username)
    }
    
    func sendResponseToConfirm(response: Bool, andLettersToRemove lettersToRemove: [String]) {
        socketManager!.defaultSocket.emit(sendResponseToConfirmEvent, username, response, lettersToRemove)
    }
    
    func sendSort(letter: String, andLetterIndex index: Int) {
        socketManager!.defaultSocket.emit(sendSortLetterEvent, username, letter, index)
    }
    
    func sendCurrentUserWon() {
        socketManager!.defaultSocket.emit(sendCurrentUserWonEvent, username)
    }
    
    func restartMatch() {
        socketManager!.defaultSocket.emit(sendRestartMatchEvent)
    }
}
