//
//  EQSpotifyCoreAudioController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQSpotifyCoreAudioController: SPTCoreAudioController {
    var eqNode: AUNode = 0
    var eqUnit: AudioUnit?

    func gainForBandAt(bandPosition: UInt32) -> AudioUnitParameterValue {
        if let unit = eqUnit {
            var gain: AudioUnitParameterValue = 0
            let parameterId = kAUNBandEQParam_Gain + bandPosition
            let status = AudioUnitGetParameter(unit, parameterId, kAudioUnitScope_Global, 0, &gain)
            if status != noErr {
                print(status.description)
            }
            return gain
        }
        return 0
    }

    func setGain(value: Float, forBandAt: UInt32) {
        if let unit = eqUnit {
            let parameterId = kAUNBandEQParam_Gain + forBandAt
            let status = AudioUnitSetParameter(unit, parameterId, kAudioUnitScope_Global, 0, value, 0)
            if status != noErr {
                print(status.description)
            }
        }
    }

    override func connectOutputBus(
        _ sourceOutputBusNumber: UInt32,
        ofNode sourceNode: AUNode,
        toInputBus destinationInputBusNumber: UInt32,
        ofNode destinationNode: AUNode,
        in graph: AUGraph!
    ) throws {
        // 定義nodetype
        var desc = AudioComponentDescription(
            componentType: kAudioUnitType_Effect,
            componentSubType: kAudioUnitSubType_NBandEQ,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0
        )
        AUGraphAddNode(graph, &desc, &eqNode)
        AUGraphNodeInfo(graph, eqNode, nil, &eqUnit)
     
      var maxFPS: UInt32 = 4096
      //要在出初始化之前不然會報錯
      //設定最大Ｆrame
      let status2 = AudioUnitSetProperty(
        eqUnit!,
        kAudioUnitProperty_MaximumFramesPerSlice,
        kAudioUnitScope_Global,
        0,
        &maxFPS,
        UInt32(MemoryLayout.size(ofValue: maxFPS))
      )
      if status2 != noErr {
        print(status2.description)
      }
        AudioUnitInitialize(eqUnit!)

        // 幾個band
        var eqFreq: [UInt32] = [25, 40, 63, 100, 160, 250, 400, 640, 1000, 1600, 2500, 4000, 6300, 10000, 16000]
        // 20 -band [32,44,63,88,125,180,250,355,500,710,1000,1400,2000,2800,4000,5600,8000,11300,16000,22000]
        // 6  -band [32, 250, 500, 1000, 2000, 16000]
        // 10 -band [32, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        // 15 -band [25,40, 63, 100, 250, 400, 640, 1000, 1600, 2500, 4000,6300,10000,16000]

        var eqBypass = Array(repeating: 0, count: eqFreq.count)
        var noBands: UInt32 = UInt32(eqFreq.count)

        // 設定幾個band
        let status = AudioUnitSetProperty(
            eqUnit!,
            kAUNBandEQProperty_NumberOfBands,
            kAudioUnitScope_Global,
            0,
            &noBands,
            UInt32(MemoryLayout.size(ofValue: noBands))
        )
        if status != noErr {
            print(status.description)
        }
        // 設定頻率
        for index in stride(from: 0, to: noBands, by: 1) {
            AudioUnitSetParameter(
                eqUnit!,
                kAUNBandEQParam_Frequency + UInt32(index),
                kAudioUnitScope_Global,
                0,
                AudioUnitParameterValue(eqFreq[Int(index)]),
                0)
        }
        // 設定bypass
        for index in stride(from: 0, to: noBands, by: 1) {
            AudioUnitSetParameter(
                eqUnit!,
                kAUNBandEQParam_BypassBand + UInt32(index),
                kAudioUnitScope_Global,
                0,
                AudioUnitParameterValue(eqBypass[Int(index)]),
                0)
        }

        // MARK: connect

        AUGraphConnectNodeInput(graph, sourceNode, sourceOutputBusNumber, eqNode, 0)
        AUGraphConnectNodeInput(graph, eqNode, 0, destinationNode, destinationInputBusNumber)
    }

    override func disposeOfCustomNodes(in graph: AUGraph!) {
        AudioUnitUninitialize(eqUnit!)
        eqUnit = nil
        AUGraphRemoveNode(graph, eqNode)
        eqNode = 0
    }
}
