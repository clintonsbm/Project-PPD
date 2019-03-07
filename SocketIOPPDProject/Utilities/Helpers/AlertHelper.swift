//
//  AlertHelper.swift
//  SocketIOPPDProject
//
//  Created by Clinton de Sá Barreto Maciel on 07/02/19.
//  Copyright © 2019 Clinton de Sá. All rights reserved.
//

import UIKit
import SCLAlertView

class AlertHelper: NSObject {
    
    static private let appearance = SCLAlertView.SCLAppearance (
        showCloseButton: false
    )
    
    @discardableResult
    static func showWaiting(withTitle title: String, andSubTitle subTitle: String, andCancelCompletion completion: @escaping(() -> Void)) -> SCLAlertViewResponder {
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Cancelar") {
            completion()
        }
        return alert.showWait(title, subTitle: subTitle)
    }
    
    @discardableResult
    static func showConfirmDeny(withTitle title: String, andSubtitle subtitle: String, andCompletion completion: @escaping((_ success: Bool) -> Void)) -> SCLAlertViewResponder {
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Inválido") {
            completion(false)
        }
        alert.addButton("Válido") {
            completion(true)
        }
        return alert.showNotice(title, subTitle: subtitle)
    }
    
    @discardableResult
    static func showUserFeedbackAlert(confirmRound: Bool) -> SCLAlertViewResponder {
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("OK") {
            return
        }

        if confirmRound {
            return alert.showInfo("Sua vez!", subTitle: "Agora é sua vez de retirar as letras do seu oponente.")
        }
        
        return alert.showError("Jogada inválida!", subTitle: "O oponente não aprovou sua jogada, fale com ele pelo chat e depois tente novamente.")
    }
    
    static func showFinalAlert(didUserWon: Bool, didUserOtherResign: Bool, mainViewCompletion completion: @escaping(() -> Void)) {
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Tela inicial") {
            completion()
            return
        }
        if !didUserOtherResign {
            alert.addButton("Reiniciar partida") {
                ConnectionHandler.shared.restartMatch()
                return
            }
        }
        
        if didUserWon {
            alert.showSuccess("Parabéns!", subTitle: "Você ganhou.")
            return
        }
        
        alert.showNotice("Você perdeu", subTitle: "Não foi dessa vez, mas sempre podemos jogar novamente")
    }
    
    @discardableResult
    static func showFieldAlert(withTitle title: String, andSubtitle subtitle: String, andCompletion completion: @escaping((_ text: String) -> Void)) -> SCLAlertViewResponder {
        let alert = SCLAlertView(appearance: appearance)
        
        let textField = alert.addTextField()
        
        alert.addButton("OK") {
            completion(textField.text ?? "")
        }
        
        alert.addButton("Cancelar") {
            ConnectionHandler.shared.disconnectSockets()
        }
        
        return alert.showEdit(title, subTitle: subtitle)
    }
}
