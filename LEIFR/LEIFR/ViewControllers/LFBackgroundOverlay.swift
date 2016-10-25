 //
//  LFBackgroundOverlay.swift
//  LEIFR
//
//  Created by Lei Mingyu on 25/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFBackgroundOverlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let fileName = "\(path.z)-\(path.x)-\(path.y)"
        
        if path.z >= 7 {
            // from 7 onwards we load from mapbox
            let url = URL(string: "https://api.mapbox.com/styles/v1/echx/cit1xa01k00112wljpa9qu6dg/tiles/256/\(path.z)/\(path.x)/\(path.y)?access_token=pk.eyJ1IjoiZWNoeCIsImEiOiJjaXBwZjhhZDcwM3RzZm1uYzVmM2E5MjhtIn0.Z3Qh-zpuvIf7KlVZLCRutA")!
            return url
        } else {
            if let url = Bundle.main.path(forResource: fileName, ofType: "png") {
                return URL(fileURLWithPath: url)
            } else {
                return URL(string: "https://api.mapbox.com/styles/v1/echx/cit1xa01k00112wljpa9qu6dg/tiles/256/\(path.z)/\(path.x)/\(path.y)?access_token=pk.eyJ1IjoiZWNoeCIsImEiOiJjaXBwZjhhZDcwM3RzZm1uYzVmM2E5MjhtIn0.Z3Qh-zpuvIf7KlVZLCRutA")!
            }
        }
    }
    
    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let _ = self.url(forTilePath: path)
        super.loadTile(at: path, result: result)
    }
}
