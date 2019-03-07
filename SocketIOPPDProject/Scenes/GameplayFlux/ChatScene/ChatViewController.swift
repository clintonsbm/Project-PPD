//
//  ChatViewController.swift
//  SocketIOPPDProject
//
//  Created by Clinton de Sá Barreto Maciel on 11/02/19.
//  Copyright (c) 2019 Clinton de Sá. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ChatDisplayLogic: class {
}

class ChatViewController: UIViewController {
    var interactor: ChatBusinessLogic?
    var router: (NSObjectProtocol & ChatRoutingLogic & ChatDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = ChatInteractor()
        let presenter = ChatPresenter()
        let router = ChatRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
        
        // Intantiave chat view to show messages
        view = ChatView(delegate: self)
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
}

extension ChatViewController: ChatViewDelegate {
    func send(message: String) {
        ConnectionHandler.shared.send(message: message)
    }
}

extension ChatViewController: ConnectionHandlerDelegate {
    func received(message: String?) {
        guard let message = message else { return }
        (view as! ChatView).addMessage(isFromCurrentUser: false, message: message)
    }
}

extension ChatViewController: ChatDisplayLogic {
    
}
