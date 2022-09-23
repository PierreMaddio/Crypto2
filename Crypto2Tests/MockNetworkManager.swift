//
//  MockNetworkManager.swift
//  Crypto2Tests
//
//  Created by Pierre on 24/09/2022.
//

import Foundation
@testable import Crypto2

struct MockNetworkManager : NetworkProtocol {
    var data: Data?
    
    // comment 
    func download(url: URL) async throws -> Data {
        if Bool.random(){
            return self.data ?? " ".data(using: .utf8)!
        }else{
            throw NetworkingManager.NetworkingError.badURLResponse(url: url)
        }
    }
}
