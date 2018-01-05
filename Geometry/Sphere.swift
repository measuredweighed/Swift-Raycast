//
//  Sphere.swift
//  BVH
//
//  Created by Nial Giacomelli on 05/01/2018.
//  Copyright © 2018 UglyApps. All rights reserved.
//

import Foundation

class Sphere : Intersectable {
    
    private var radius:Scalar
    var transform:Transform = Transform()
    var aabb:AABB
    
    init(position: Vector3, rotation: Quaternion, radius: Scalar) {
        self.radius = radius
        
        transform.position = position
        transform.rotation = rotation
        
        let origin = transform.matrix * Vector3.zero
        aabb = AABB(
            center: origin,
            min: origin - Vector3(radius, radius, radius),
            max: origin + Vector3(radius, radius, radius)
        )
    }
    
    /**
     Determines whether this sphere intersects a given ray
     
     - Parameter ray: a `Ray` instance
     - Returns: an instance of `RayHit` on success
     */
    func intersects(ray: Ray) -> RayHit? {
        
        let origin = transform.matrix * Vector3.zero
        let delta = origin - ray.origin
        let adj = delta.dot(ray.direction)
        
        let d2 = delta.dot(delta) - (adj * adj)
        let radiusSquared = radius * radius
        if d2 > radiusSquared { return nil }
        
        let thickness = sqrt(radiusSquared - d2)
        let t0 = adj - thickness
        let t1 = adj + thickness
        
        if t0 < 0 && t1 < 0 { return nil }
        
        var distance:Scalar = 0
        if t0 < 0 {
            distance = t1
        } else if t1 < 0 {
            distance = t0
        } else {
            distance = t0 < t1 ? t0 : t1
        }
        
        let point:Vector3 = ray.origin + (ray.direction * distance)
        let hitVec:Vector3 = transform.rotation * (point - origin)
        
        // calculate UV coordinates
        let uv:Vector2 = Vector2(
            ((1 + atan2(hitVec.z, hitVec.x)) / Scalar.pi) * 0.5,
            acos(hitVec.y / radius) / Scalar.pi
        )
        
        return RayHit(
            distance: distance,
            point: point,
            normal: (point - origin).normalized(),
            uv: uv
        )
    }
}
