//
//  EQProjectModelProtocol.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/6.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
protocol EQProjectModelProtocol {
    func getProject() -> EQProjectModel
}

extension EQProjectModel: EQProjectModelProtocol {
    func getProject() -> EQProjectModel {
        return self
    }
}

extension EQPostCellModel: EQProjectModelProtocol {
    func getProject() -> EQProjectModel {
        return projectModel
    }
}
