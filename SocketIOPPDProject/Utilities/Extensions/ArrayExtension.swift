//
//  ArrayExtension.swift
//  SocketIOPPDProject
//
//  Created by Clinton de Sá Barreto Maciel on 21/02/19.
//  Copyright © 2019 Clinton de Sá. All rights reserved.
//

import Foundation

extension Array {
    var tail: Array {
        return Array(self.dropFirst())
    }
}
