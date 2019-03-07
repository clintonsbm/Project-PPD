//
//  MainMenuRouter.swift
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

@objc protocol MainMenuRoutingLogic {
    func routeToGameplayFlux()
}

protocol MainMenuDataPassing {
    var dataStore: MainMenuDataStore? { get }
}

class MainMenuRouter: NSObject, MainMenuRoutingLogic, MainMenuDataPassing {
    weak var viewController: MainMenuViewController?
    var dataStore: MainMenuDataStore?
    
    // MARK: Routing
    
    func routeToGameplayFlux() {
        let gameViewController = GameViewController(nibName: GameViewController.nibIdentifier, bundle: nil)
        let chatController = ChatViewController()
        
        ConnectionHandler.shared.set(newDelegate: gameViewController)
        ConnectionHandler.shared.set(newDelegate: chatController)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [UINavigationController(rootViewController: gameViewController), chatController]
        tabBarController.tabBar.items?[0].image = #imageLiteral(resourceName: "gameIcon")
        tabBarController.tabBar.items?[0].title = "Jogo"
        tabBarController.tabBar.items?[1].image = #imageLiteral(resourceName: "chatIcon")
        tabBarController.tabBar.items?[1].title = "Chat"
        
        viewController?.present(tabBarController, animated: true, completion: nil)
    }
}
