//
//  dataModel.swift
//  3D Interaction
//
//  Created by Yuseok on 04/09/2019.
//  Copyright © 2019 Yuseok. All rights reserved.
//

import Foundation

class object {
    var position: [Double] = [0, 0, 0]
    var angleAtOrigin: [Double] = [0, 0, 0]
}

class roomInfo {
    var title: String = ""
    var objects = [object]()
}
