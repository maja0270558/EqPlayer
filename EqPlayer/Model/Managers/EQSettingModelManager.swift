//
//  EQSettingModelManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/18.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import ReactiveObjC

@objc class EQSettingModelManager: NSObject {
    @objc var isModify: Bool = false
    @objc var tempModel: EQProjectModel = EQProjectModel()
    init(model: EQProjectModel = EQProjectModel()) {
        tempModel = EQProjectModel(value: model)
    }
    
    override init() {
        super.init()
    }

    lazy var signal = self.tempModel.rac_values(forKeyPath: "tracks", observer: self)
    
    @objc func trackSignal() -> RACSignal<AnyObject> {
        return signal
    }
    
    @objc func checkIsAdded(uri: String) -> Bool {
        return tempModel.tracks.contains(where: {
           return $0.uri == uri
        })
    }
    
    @objc func getIndex(uri: String, completion: (Int)->Void) {
        if let index = tempModel.tracks.index(where: {
            $0.uri == uri
        }) {
            completion(index)
        } 
    }
    
    @objc func removeTrackAt(index: Int) {
        tempModel.tracks.remove(at: index)
    }
    
    @objc func appendTrackAt(track: EQTrack) {
        tempModel.tracks.append(track)
    }
    
   @objc func setEQSetting(values: [Double]) {
        tempModel.eqSetting.removeAll()
        values.forEach {
            tempModel.eqSetting.append($0)
        }
    }
    
    @objc func setEQSettingAt (index: Int, value: Double) {
        tempModel.eqSetting[index] = value
        EQSpotifyManager.shard.setGain(value: Float(value), atBand: UInt32(index))
    }

   @objc func saveObjectTo(status: EQProjectStatus) {
        let modelCopy = EQProjectModel(value: tempModel)
        modelCopy.status = status

        if EQRealmManager.shard.checkModelExist(filter: "uuid == %@", value: modelCopy.uuid) {
            let result: [EQProjectModel] = EQRealmManager.shard.findWithFilter(filter: "uuid == %@", value: modelCopy.uuid)
            let object = result.first!
            EQRealmManager.shard.updateObject {
                object.name = modelCopy.name
                object.status = modelCopy.status
                object.tracks.removeAll()
                object.tracks.append(objectsIn: modelCopy.tracks)
                object.eqSetting.removeAll()
                object.eqSetting.append(objectsIn: modelCopy.eqSetting)
            }
        } else {
            EQRealmManager.shard.save(object: modelCopy)
        }
    }
}
