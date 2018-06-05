//
//  EQSettingModelManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/18.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQSettingModelManager {
    var isModify: Bool = false
    var tempModel: EQProjectModel
    init(model: EQProjectModel = EQProjectModel()) {
        tempModel = EQProjectModel(value: model)
    }

    func setEQSetting(values: [Double]) {
        tempModel.eqSetting.removeAll()
        values.forEach {
            tempModel.eqSetting.append($0)
        }
    }

    func saveObjectTo(status: EQProjectStatus) {
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
