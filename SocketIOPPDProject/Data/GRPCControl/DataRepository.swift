//
//  DataRepository.swift
//  grpc_note
//
//  Created by Alfian Losari on 9/9/18.
//  Copyright © 2018 Alfian Losari. All rights reserved.
//

import Foundation
import SwiftGRPC

class DataRepository {
    
    private var client = NoteServiceServiceClient.init(address: "127.0.0.1:50051", secure: false)
    
    private init(port: String) {
        
    }
    
    func listChatMessages(completion: @escaping([ChatMessage]?, CallResult?) -> Void) {
        _ = try? client.list(Empty(), completion: { (notes, result) in
            DispatchQueue.main.async {
                completion(notes?.messages, result)
            }
        })
    }
    
    
    func insertChatMessage(note: ChatMessage) {
//        _ = try? client.insert(note, completion: { (createdChatMessage, result) in
//            return
//        })
    }
    
    func delete(noteId: String, completion: @escaping(Bool) -> ()) {
        _ = try? client.delete(ChatMessageRequestId(id: noteId), completion: { (success, result) in
            DispatchQueue.main.async {
                if let _ = success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        })
    }

}

extension ChatMessageRequestId {
    
    init(id: String) {
        self.id = id
    }
}

extension ChatMessage {
    
    init(user: String, content: String) {
        self.user = user
        self.content = content
    }
    
}
