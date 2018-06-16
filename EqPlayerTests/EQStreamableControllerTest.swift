//
//  SpotifyManagerTest.swift
//  EqPlayerTests
//
//  Created by 大容 林 on 2018/6/15.
//  Copyright © 2018年 Django. All rights reserved.
//
@testable import EqPlayer
import XCTest

class EQStreamableControllerTest: XCTestCase {
    var player: MockPlayer!
    class MockPlayer: StreamableController {
        var streamableControllerDelegate: SPTAudioStreamingDelegate!

        var streamableControllerPlaybackDelegate: SPTAudioStreamingPlaybackDelegate!

        var loginFlag: Bool = false
        var startFlag: Bool = false
        var seekToPosition: TimeInterval = 0

        func seekTo(_ position: TimeInterval) {
            seekToPosition = position
        }

        func startPlayer(withClientId _: String,
                         audioController _: SPTCoreAudioController?,
                         allowCaching _: Bool) {
            startFlag = true
        }

        func loginPlayer(withAccessToken _: String) {
            loginFlag = true
        }
    }

    override func setUp() {
        super.setUp()
        player = MockPlayer()
    }

    override func tearDown() {
        player = nil
        super.tearDown()
    }

    func test_Seek() {
        let input = TimeInterval(20)
        player.seekTo(input)
        let output = player.seekToPosition
        XCTAssertEqual(input, output)
    }

    func test_Login() {
        player.loginPlayer(withAccessToken: "")
        let output = player.loginFlag
        XCTAssertTrue(output)
    }

    func test_Start() {
        player.startPlayer(withClientId: "", audioController: nil, allowCaching: false)
        let output = player.startFlag
        XCTAssertTrue(output)
    }
}
