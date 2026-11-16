//
//  JorunalDatabase.swift
//  Journal
//
//  Created by IOS EST on 11/16/26.
//

import Foundation
import SwiftData

@Model

final class JorunalDatabase: Identifiable {
    var id = UUID()
    var title: String
    var content: String
    var createdAt = Date()
    var category: String
    var tags: [String]
    
    init(title: String, content: String, tags: [String]) {
        self.title = title
        self.content = content
        self.tags = tags
    }
}
