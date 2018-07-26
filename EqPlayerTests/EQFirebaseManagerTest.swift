//
//  EQFirebaseManagerTest.swift
//  EqPlayerTests
//
//  Created by 大容 林 on 2018/6/13.
//  Copyright © 2018年 Django. All rights reserved.
//

@testable import EqPlayer
import XCTest

class EQFirebaseManagerTest: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_LoginUser() {
        let promise = expectation(description: "login user")
        var mockLoginOrCreateIsComplete = false
        EQFirebaseManager.createUserIfNotExist(withEmail: "unittest@test.com", password: "123456") {
            mockLoginOrCreateIsComplete = true
            promise.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(mockLoginOrCreateIsComplete)
    }

    func test_GetUserCovertCorrectly() {
        let promise = expectation(description: "get user")
        var eqUserModel: EQUserModel!
        EQFirebaseManager.createUserIfNotExist(withEmail: "unittest@test.com", password: "123456") {
            EQFirebaseManager.getUser(withUID: "njl3RZLeJbVEH0VZ1edoW6xGou82", failedHandler: {
                eqUserModel = EQUserModel()
                promise.fulfill()
            }) { model in
                eqUserModel = model
                promise.fulfill()
            }
        }
        waitForExpectations(timeout: 15, handler: nil)
        XCTAssertEqual(eqUserModel.email, "lock711210@ymail.com", "complete")
    }
}
