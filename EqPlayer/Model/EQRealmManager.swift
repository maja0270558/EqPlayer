//
//  File.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import RealmSwift

class EQRealmManager {
    static let shard = EQRealmManager()
    private init(){
        
    }
    let realm = try? Realm()
    
    func remove(object: Object){
        realm!.delete(object)
    }
    
    func save(object: Object)  {
        try? realm!.write {
            realm!.add(object)
        }
    }
    
    func checkModelExist (filter: String, value: String) -> Bool {
        if let result = realm!.objects(EQProjectModel.self).filter(filter,value).first {
            return true
        } else {
            return false
        }
    }
    
    func findAll<T: Object>() -> [T] {
        return Array(realm!.objects(T.self))
    }
    
    func findWithFilter<T: Object>(filter: String, value: String) -> [T] {
        return realm!.objects(T.self).filter(filter,value).map { $0 }
    }
    
    func updateObject(process: () -> Void) {
        try? realm!.write {
            process()
        }
    }
}
