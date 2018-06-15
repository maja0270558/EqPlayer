//
//  EqPlayerTests.swift
//  EqPlayerTests
//
//  Created by 大容 林 on 2018/6/12.
//  Copyright © 2018年 Django. All rights reserved.
//

@testable import EqPlayer
import XCTest
class EQSettingModelTest: XCTestCase {
    var setting: EQSettingModelManager!

    override func setUp() {
        super.setUp()
        setting = EQSettingModelManager()
    }

    override func tearDown() {
        setting = nil
        super.tearDown()
    }

    func test_SetBand() {
        var value: [Double] = [10, 10, 10, 10, 10, 10]
        setting.setEQSetting(values: value)
        XCTAssertEqual(setting.tempModel.eqSetting.count, value.count)
    }
}
