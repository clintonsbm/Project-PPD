//
//  MainMenuModels.swift
//  ProjectPPD
//
//  Created by Clinton de Sá Barreto Maciel on 06/02/19.
//  Copyright (c) 2019 Clinton de Sá. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

enum MainMenu {
    
    // MARK: Use cases
    
    enum ConnectionAccepted {
        struct Request {
            let playerUsername: String?
        }
        struct Response {
            let playerUsername: String?
        }
        struct ViewModel {
            let isValidUsername: Bool
        }
    }
    
}
