//
//  GameInteractor.swift
//  SocketIOPPDProject
//
//  Created by Clinton de Sá Barreto Maciel on 20/02/19.
//  Copyright (c) 2019 Clinton de Sá. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol GameBusinessLogic {
    func removeLetter(request: Game.ReceivedLetterEvent.Request)
    func requestToConfirm(request: Game.ReceivedRequestToConfim.Request)
    func setupForConfirmDeny(request: Game.SetupForConfirmDenyResponse.Request)
    func responseToConfirm(request: Game.ReceivedResponseToConfirm.Request)
    func sortLetter(request: Game.SortLetter.Request)
    func restartMatch(request: Game.RestartMatch.Request)
}

protocol GameDataStore {
}

class GameInteractor: GameBusinessLogic, GameDataStore {
    var presenter: GamePresentationLogic?
    var worker: GameWorker?
    
    // MARK: Control variables
    
    private let alphabet: [String] = ["A", "B", "C", "D", "E", "F", "G", "H",
                                      "I", "J", "K", "L", "M", "N", "O", "P",
                                      "Q", "R", "S", "T", "U", "V", "W", "X",
                                      "Y", "Z"]
    private var oponentLettersLeft: Int = 26
    private var lettersToRemove: [String] = []
    
    // MARK: Remove letter
    
    func removeLetter(request: Game.ReceivedLetterEvent.Request) {
        if let letter = request.letter {
            if request.isRemoveEvent {
                lettersToRemove.append(letter)
            } else {
                lettersToRemove = lettersToRemove.filter({$0 != letter})
            }
        }
        
        let response = Game.ReceivedLetterEvent.Response(lettersLeft: oponentLettersLeft - lettersToRemove.count)
        presenter?.presentRemoveLetter(response: response)
    }
    
    // MARK: Request to confirm
    
    func requestToConfirm(request: Game.ReceivedRequestToConfim.Request) {
        let response = Game.ReceivedRequestToConfim.Response(lettersToRemove: lettersToRemove)
        presenter?.presentRequestToConfirm(response: response)
    }
    
    // MARK: Setup for confirm deny
    
    func setupForConfirmDeny(request: Game.SetupForConfirmDenyResponse.Request) {
        ConnectionHandler.shared.sendResponseToConfirm(response: request.confirmRound, andLettersToRemove: request.lettersToRemove)
        
        if request.confirmRound {
            oponentLettersLeft = oponentLettersLeft - lettersToRemove.count
            lettersToRemove = []
        }
        
        let response = Game.SetupForConfirmDenyResponse.Response(confirmRound: request.confirmRound, lettersToRemove: request.lettersToRemove)
        presenter?.presentSetupForConfirmDeny(response: response)
    }
    
    // MARK: Response to confirm
    
    func responseToConfirm(request: Game.ReceivedResponseToConfirm.Request) {
        let response = Game.ReceivedResponseToConfirm.Response(confirmRound: request.confirmRound, lettersToRemove: request.lettersToRemove)
        presenter?.presentResponseToConfirm(response: response)
    }
    
    // MARK: Sort letter
    
    func sortLetter(request: Game.SortLetter.Request) {
        let randomLetterIndex = Int.random(in: 0...25)
        let letter = alphabet[randomLetterIndex]
        
        ConnectionHandler.shared.sendSort(letter: letter, andLetterIndex: randomLetterIndex)
        
        let response = Game.SortLetter.Response(letterIndex: randomLetterIndex, letter: letter)
        presenter?.presentSortLetter(response: response)
    }
    
    // MARK: Restart match
    
    func restartMatch(request: Game.RestartMatch.Request) {
        oponentLettersLeft = 26
        lettersToRemove = []
        
        let response = Game.RestartMatch.Response()
        presenter?.presentRestartMatch(response: response)
    }
}
