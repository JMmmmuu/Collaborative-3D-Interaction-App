//
//  dataModel.swift
//  3D Interaction
//
//  Created by Yuseok on 04/09/2019.
//  Copyright © 2019 Yuseok. All rights reserved.
//

import Foundation
import RealmSwift

class object: Object {
    convenience init(name: String, geomeryType: String) {
        self.init()
        self.name = name
        self.geoType = geomeryType
    }
    
    @objc dynamic var name: String = ""
    @objc dynamic var geoType: String = ""
    @objc dynamic var x: Double = 0.0
    @objc dynamic var y: Double = 0.0
    @objc dynamic var z: Double = 0.0
    
    @objc dynamic var angleAtOrigin_x: Double = 0.0
    @objc dynamic var angleAtOrigin_y: Double = 0.0
    @objc dynamic var angleAtOrigin_z: Double = 0.0
    
    @objc dynamic var scale: Double = 0.0
    
    var room = LinkingObjects(fromType: roomInfo.self, property: "objects")
}

class roomInfo: Object {
    @objc dynamic var title: String = ""
    let objects = List<object>()
}
