//
//  User.swift
//  PerkingOpera
//
//  Created by admin on 28/11/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss

struct User: Glossy {
    
    let userId: Int
    let token: String
    let userName: String
    let depId: Int
    let RealName: String
    let DepName: String

    // MARK: - Deserialization
    
    init?(json: JSON) {
        guard let userId: Int = "userId" <~~ json,
            let token: String = "token" <~~ json,
            let userName: String = "userName" <~~ json,
            let depId: Int = "depId" <~~ json,
            let RealName: String = "RealName" <~~ json,
            let DepName: String = "DepName" <~~ json
            else {
                return nil
            }
        
        self.userId = userId
        self.token = token
        self.userName = userName
        self.depId = depId
        self.RealName = RealName
        self.DepName = DepName
    }
    
    // MARK: - Serialization
    
    func toJSON() -> JSON? {
        return jsonify([
            "userId" ~~> self.userId,
            "token" ~~> self.token,
            "userName" ~~> self.userName,
            "depId" ~~> self.depId,
            "RealName" ~~> self.RealName,
            "DepName" ~~> self.DepName
            ])
    }
}

// MARK: - Custom transformers

extension Decoder {
    
    static func decodeStringUppercase(key: String, json: JSON) -> String? {
        if let string = json[key] as? String {
            return string.uppercased()
        }
        
        return nil
    }
    
}

extension Encoder {
    
    static func encodeStringCapitalized(key: String, value: String?) -> JSON? {
        if let value = value {
            return [key : value.capitalized]
        }
        
        return nil
    }
    
}
