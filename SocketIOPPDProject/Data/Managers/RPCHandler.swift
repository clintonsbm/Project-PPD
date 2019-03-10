//
//  RPCHandler.swift
//  SocketIOPPDProject
//
//  Created by Clinton de Sá Barreto Maciel on 10/03/19.
//  Copyright © 2019 Clinton de Sá. All rights reserved.
//

import UIKit
import SocketIO

protocol RPCChatDelegate: NSObjectProtocol {
    func connected()
    func disconnected()
    func startChat(username: String?)
    func add(message: String?)
}

extension RPCChatDelegate {
    func connected() {
        print("Conneted")
    }
    
    func disconnected() {
        print("Disconnected")
    }
    
    func startChat(username: String?) {
        print("Received username: \(username ?? "Empty username error")")
    }
    
    func add(message: String?) {
        print("\n\nReceived message: \(message ?? "Empty message error")\n\n\n")
    }
}

protocol RPCGameDelegate: NSObjectProtocol {
    func remove(letter: String?)
    func add(letter: String?)
    func confirmTurn()
    func turnConfirmation(response: Bool?, lettersToRemove: [String]?)
    func sort(letter: String?, letterIndex: Int?)
    func otherUserResign()
    func otherUserWon()
    func restartMatch()
}

class RPCHandler: NSObject {
    
    // MARK: Singleton
    
    static let sharedOponent = RPCHandler()
    
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
    
    private weak var chatDelegate: RPCChatDelegate?
    private weak var gameDelegate: RPCGameDelegate?
    
    private var socketManager: SocketManager?
    private var chatSocket: SocketIOClient?
    private var gameSocket: SocketIOClient?
    
    private var oponentsOponentUsername: String = ""
    
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
            self.chatDelegate?.connected()
        }
        
        chatSocket!.on(clientEvent: .disconnect) { (_, _) in
            self.chatDelegate?.disconnected()
        }
        
        chatSocket!.on(startChatEvent) {data, ack in
            self.chatDelegate?.startChat(username: data[0] as? String)
        }
        
        chatSocket!.on(receiveMessageEvent) { (data, ack) in
            self.chatDelegate?.add(message: data[0] as? String)
        }
    }
    
    private func setupGameSocketEvents() {
        chatSocket!.on(receiveRemoveLetterEvent) { (data, ack) in
            self.gameDelegate?.remove(letter: data.first as? String)
        }
        chatSocket!.on(receiveAddLetterEvent) { (data, ack) in
            self.gameDelegate?.add(letter: data.first as? String)
        }
        chatSocket!.on(receiveRequestToConfirmEvent) { (_, _) in
            self.gameDelegate?.confirmTurn()
        }
        chatSocket!.on(receiveResponseToConfirmeEvent) { (data, ack) in
            self.gameDelegate?.turnConfirmation(response: data.first as? Bool, lettersToRemove: data[1] as? [String])
        }
        chatSocket!.on(receiveSortLetterEvent) { (data, ack) in
            self.gameDelegate?.sort(letter: data.first as? String, letterIndex: data[1] as? Int)
        }
        chatSocket!.on(receiveOtherUserResignEvent) { (data, ack) in
            self.gameDelegate?.otherUserResign()
        }
        chatSocket!.on(receiveOtherUserWonEvent) { (data, ack) in
            self.gameDelegate?.otherUserWon()
        }
        chatSocket!.on(receiveRestartMatchEvent) { (data, ack) in
            self.gameDelegate?.restartMatch()
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
    
    func set(newDelegate: RPCChatDelegate) {
        chatDelegate = newDelegate
    }
    
    func set(newDelegate: RPCGameDelegate) {
        gameDelegate = newDelegate
    }
    
    func setOponentsOponentUsername(newUsername: String) {
        oponentsOponentUsername = newUsername
    }
    
    func getOponentsOponentUsername() -> String {
        return oponentsOponentUsername
    }
}

extension RPCHandler: RPCChatDelegate {
    func add(message: String?) {
        guard let message = message else { return }
        socketManager!.defaultSocket.emit(sendMessageEvent, oponentsOponentUsername, message)
    }
}

extension RPCHandler: RPCGameDelegate {
    func remove(letter: String?) {
        guard let letter = letter else { return }
        socketManager!.defaultSocket.emit(sendRemoveLetterEvent, oponentsOponentUsername, letter)
    }
    
    func add(letter: String?) {
        guard let letter = letter else { return }
        socketManager!.defaultSocket.emit(sendAddLetterEvent, oponentsOponentUsername, letter)
    }
    
    func confirmTurn() {
        socketManager!.defaultSocket.emit(sendRequestToConfirmEvent, oponentsOponentUsername)
    }
    
    func turnConfirmation(response: Bool?, lettersToRemove: [String]?) {
        guard let response = response, let lettersToRemove = lettersToRemove else { return }
        socketManager!.defaultSocket.emit(sendResponseToConfirmEvent, oponentsOponentUsername, response, lettersToRemove)
    }
    
    func sort(letter: String?, letterIndex: Int?) {
        guard let newLetter = letter, let newLetterIndex = letterIndex else { return }
        socketManager!.defaultSocket.emit(sendSortLetterEvent, oponentsOponentUsername, newLetter, newLetterIndex)
    }
    
    func otherUserResign() {
        return
    }
    
    func otherUserWon() {
        return
    }

    func sendCurrentUserWon() {
        socketManager!.defaultSocket.emit(sendCurrentUserWonEvent, oponentsOponentUsername)
    }
    
    func restartMatch() {
        socketManager!.defaultSocket.emit(sendRestartMatchEvent)
    }
}
