//
//  EQProjectModel.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveObjC

@objc enum EQProjectStatus: Int {
    case new = 1
    case saved = 2
    case temp = 3
    case post = 4
    func getValue() -> String {
        return String(rawValue)
    }
}

@objc class EQProjectModel: Object {
    var dict: [String: Any] {
        return [
            "uuid": uuid,
            "name": name,
            "status": status.getValue(),
            "tracks": Array(tracks).map {
                $0.dict
            },
            "eqSetting": Array(eqSetting),
            "detailDescription": detailDescription
        ]
    }
    @objc var tracksForObjc: [EQTrack] {
        return Array(tracks)
    }

    @objc dynamic var uuid = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var detailDescription: String = ""
    @objc dynamic var status = EQProjectStatus.new
    let tracks = List<EQTrack>()
    let eqSetting = List<Double>()
}

@objc class EQTrack: Object, Codable, EQTrackProtocol {
    func getTrack() -> EQTrack {
        return self
    }

    var dict: [String: Any] {
        return [
            "duration": duration,
            "name": name,
            "uri": uri,
            "artist": artist,
            "previewURL": previewURL ?? "",
            "coverURL": coverURL ?? ""
        ]
    }

    @objc dynamic var duration: TimeInterval = 0
    @objc dynamic var name: String = ""
    @objc dynamic var uri: String = ""
    @objc dynamic var artist: String = ""
    @objc dynamic var previewURL: String?
    @objc dynamic var coverURL: String?
}

extension SPTPartialTrack: EQTrackProtocol {
    func getTrack() -> EQTrack {
        return convertSPTPartialTrackToEQTrack()
    }

    func convertSPTPartialTrackToEQTrack() -> EQTrack {
        let eqTrack = EQTrack()

        if let previewURL = self.previewURL {
            eqTrack.previewURL = previewURL.absoluteString
        }

        if let imageURL = self.album.largestCover {
            eqTrack.coverURL = imageURL.imageURL.absoluteString
        }

        guard let title = self.name, let artists = self.artists as? [SPTPartialArtist] else {
            return eqTrack
        }

        eqTrack.name = title
        var artistsString = ""

        for index in stride(from: 0, to: artists.count, by: 1) {
            if index == artists.count - 1 {
                artistsString += artists[index].name
            } else {
                artistsString += artists[index].name + ","
            }
        }

        eqTrack.artist = artistsString
        eqTrack.uri = uri.absoluteString
        eqTrack.duration = duration
        return eqTrack
    }
}
