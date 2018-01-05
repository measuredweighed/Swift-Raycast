//
//  Intersectable.swift
//  Swift-Raycast
//
//  Created by @measuredweighed on 06/08/2017.
//  Copyright © 2017 UglyApps. All rights reserved.
//

import Foundation

/// the protocol used for any geometry capable of handling ray intersection tests
protocol Intersectable {
    var transform:Transform { get set }
    var aabb:AABB { get set }
    
    func intersects(ray: Ray) -> RayHit?
}
