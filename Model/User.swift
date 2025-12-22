//
//  User.swift
//  AVREntertainment
//
//  Created by Prajwal S S Reddy on 6/26/25.
//

import Foundation
import FirebaseFirestore

enum UserRole: String, CaseIterable, Codable {
    case BUSINESSHEAD = "BUSINESSHEAD"
    case APPROVER = "APPROVER" 
    case USER = "USER"
    case HEAD = "HEAD"
    
    var displayName: String {
        switch self {
        case .BUSINESSHEAD: return "BusinessHead"
        case .APPROVER: return "Approver"
        case .USER: return "User"
        case .HEAD: return "Head"
        }
    }
}

enum UserDataError: Error {
    case userNotFound
    case missingNameField
    case invalidUserId
}

struct User: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var phoneNumber: String
    var name: String
    var role: UserRole
    var createdAt: Date
    var isActive: Bool
    var ownerID: String // UID of the customer/businessHead who created this user
    
    // Only for BUSINESSHEAD users (email-based login)
    var email: String?
    
    init(phoneNumber: String, name: String, role: UserRole, email: String? = nil, ownerID: String) {
        self.phoneNumber = phoneNumber
        self.name = name
        self.role = role
        self.email = email
        self.ownerID = ownerID
        self.createdAt = Date()
        self.isActive = true
    }
    
    // BusinessHead initializer (no Firebase document needed)
    static func businessHeadUser(email: String, name: String = "BusinessHead", ownerID: String) -> User {
        return User(phoneNumber: "", name: name, role: .BUSINESSHEAD, email: email, ownerID: ownerID)
    }
    
    func hash(into hasher: inout Hasher) {
        if role == .BUSINESSHEAD, let email = email {
            hasher.combine(email)
        } else {
            hasher.combine(phoneNumber)
        }
        hasher.combine(role)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        if lhs.role == .BUSINESSHEAD && rhs.role == .BUSINESSHEAD {
            return lhs.email == rhs.email
        } else {
            return lhs.phoneNumber == rhs.phoneNumber && lhs.role == rhs.role
        }
    }
    
    // Sample data for preview
    static let sampleData: [User] = [
        User(phoneNumber: "9876543210", name: "John Doe", role: .APPROVER, ownerID: "sample_owner_1"),
        User(phoneNumber: "9876543211", name: "Jane Smith", role: .APPROVER, ownerID: "sample_owner_1"),
        User(phoneNumber: "9876543212", name: "Mike Johnson", role: .USER, ownerID: "sample_owner_1")
    ]
}
