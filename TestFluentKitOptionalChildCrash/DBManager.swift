//
//  DBManager.swift
//  TestFluentKitOptionalChildCrash
//
//  Created by Erik Hatfield on 1/29/25.
//

import Foundation
import SwiftUI

import NIO
import Fluent

@Observable class DBManager {
    var databases: Databases
    let dbName = "TestDB301"
    
    let numThreads = 6
    
    var logger: Logger = {
        var logger = Logger(label: "database.logger")
        logger.logLevel = .info
        return logger
    }()
    
    var database: Database {
        return self.databases.database(
            logger: logger,
            on: self.databases.eventLoopGroup.next()
        )!
    }
    
    var dbLoading: Bool = false
    var dbLoaded: Bool = false
    
    
    init() {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: self.numThreads)
        let threadPool = NIOThreadPool(numberOfThreads: self.numThreads)
        
        threadPool.start()
        
        self.databases = Databases(threadPool: threadPool, on: eventLoopGroup)
        
        databases.use(.sqlite(.memory), as: .sqlite)
        databases.default(to: .sqlite)
        
        setup()
    }
    
    func setup() {
        do {
            try ParentModel.ModelMigration()
              .prepare(on: database)
              .wait()
            
            try OptionalChildModel.ModelMigration()
              .prepare(on: database)
              .wait()
        } catch let err {
            print("err \(err)")
        }
    }
}


