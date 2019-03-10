//
//  GameModels.swift
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

enum Game {
    
    // MARK: Use cases
    
    enum LetterEvent {
        struct Request {
            let isRemoveEvent: Bool
            let letter: String?
        }
        struct Response {
            let lettersLeft: Int
        }
        struct ViewModel {
            let textToLabel: String
        }
    }
    
    enum ConfirmTurn {
        struct Request {
        }
        struct Response {
            let lettersToRemove: [String]
        }
        struct ViewModel {
            // When letters to remove is empty, should bypass
            let shouldBypassConfirmation: Bool
            let lettersToRemove: [String]
            let textToLabel: String
        }
    }
    
    enum SetupForConfirmDenyResponse {
        struct Request {
            let confirmRound: Bool
            let lettersToRemove: [String]
        }
        struct Response {
            let confirmRound: Bool
            let lettersToRemove: [String]
        }
        struct ViewModel {
            let confirmRound: Bool
            let lettersToRemove: [String]
        }
    }
    
    enum TurnConfirmed {
        struct Request {
            let confirmRound: Bool?
            let lettersToRemove: [String]?
        }
        struct Response {
            let confirmRound: Bool?
            let lettersToRemove: [String]?
        }
        struct ViewModel {
            let confirmRound: Bool
            let lettersToRemove: [String]
        }
    }
    
    enum SortLetter {
        struct Request {
        }
        struct Response {
            let letterIndex: Int
            let letter: String
        }
        struct ViewModel {
            let letterIndex: Int
            let letter: String
        }
    }
    
    enum RestartMatch {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
}
