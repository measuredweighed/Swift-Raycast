//
//  ray.swift
//  Swift-Raycast
//
//  Created by @measuredweighed on 02/08/2017.
//  Copyright © 2017 UglyApps. All rights reserved.
//

import Foundation

struct Ray {
    
    /// the origin point of the ray
    var origin:Vector3
    
    /// the normalised direction of the ray
    var direction:Vector3
    
}

struct RayHit {
    
    /// the distance travelled by the ray (from its point of origin) before an intersection occurred
    var distance:Scalar
    
    /// the point in world space where the ray intersected with geometry
    var point:Vector3
    
    /// the normal at the point of intersection
    var normal:Vector3
    
    /// the UV coordinates at the point of intersection
    var uv:Vector2? = nil
    
}
