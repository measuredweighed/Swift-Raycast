//
//  AABB.swift
//  Swift-BVH
//
//  Created by @measuredweighed on 06/08/2017.
//  Copyright © 2017 UglyApps. All rights reserved.
//

import Foundation

struct AABB {
    
    /// centroid of the AABB, expressed in world coordinates
    var center:Vector3
    
    /// min value of the AABB, expressed in world coodinates
    var minExtent:Vector3 = Vector3(Scalar.infinity, Scalar.infinity, Scalar.infinity)
    
    /// max value of the AABB, expressed in world coodinates
    var maxExtent:Vector3 = Vector3(-Scalar.infinity, -Scalar.infinity, -Scalar.infinity)
    
    /**
     Generates an `AABB` with a given center point and min/max values
     - Parameter center: center point in world coordinates
     - Parameter min: minimum point in world coordinates
     - Parameter max: maximum point in world coordinates
     */
    init(center: Vector3, min:Vector3, max:Vector3) {
        self.center = center
        self.minExtent = min
        self.maxExtent = max
    }
    
    /**
     Generates an `AABB` which fully contains the provided `AABB` set
 
     - Parameter aabbs: a list of `AABB` instances
     */
    init(containing aabbs:[AABB]) {
       
        var _min:Vector3 = Vector3(Scalar.infinity, Scalar.infinity, Scalar.infinity)
        var _max:Vector3 = Vector3(-Scalar.infinity, -Scalar.infinity, -Scalar.infinity)
        
        var sum:Vector3 = Vector3.zero
        for aabb in aabbs {
            _min.x = min(_min.x, aabb.minExtent.x)
            _min.y = min(_min.y, aabb.minExtent.y)
            _min.z = min(_min.z, aabb.minExtent.z)
            
            _max.x = max(_max.x, aabb.maxExtent.x)
            _max.y = max(_max.y, aabb.maxExtent.y)
            _max.z = max(_max.z, aabb.maxExtent.z)
            
            sum = sum + aabb.center
        }
        
        center = sum / Scalar(aabbs.count)
        minExtent = _min
        maxExtent = _max
        
    }
    
    /**
     Generates an `AABB` given a list of `Vector3` instances
 
     - Parameter points: a list of `Vector3` instances
     */
    init(points: [Vector3]) {
        assert(points.count > 0)
        
        var sum:Vector3 = Vector3.zero
        for point in points {
            minExtent.x = min(minExtent.x, point.x)
            minExtent.y = min(minExtent.y, point.y)
            minExtent.z = min(minExtent.z, point.z)
            
            maxExtent.x = max(maxExtent.x, point.x)
            maxExtent.y = max(maxExtent.y, point.y)
            maxExtent.z = max(maxExtent.z, point.z)
            
            sum = sum + point
        }
        center = sum / Scalar(points.count)
    }
    
    /**
     Performs a ray -> AABB intersection test
 
     - Parameter ray: the ray to test against
     */
    func intersects(ray: Ray) -> Bool {
        var tMin:Scalar = (minExtent.x - ray.origin.x) / ray.direction.x
        var tMax:Scalar = (maxExtent.x - ray.origin.x) / ray.direction.x
        if tMin > tMax { swap(&tMin, &tMax) }
        
        var tyMin:Scalar = (minExtent.y - ray.origin.y) / ray.direction.y
        var tyMax:Scalar = (maxExtent.y - ray.origin.y) / ray.direction.y
        if tyMin > tyMax { swap(&tyMin, &tyMax) }
        
        if (tMin > tyMax) || (tyMin > tMax) { return false }
        
        if tyMin > tMin { tMin = tyMin }
        if tyMax < tMax { tMax = tyMax }
        
        var tzMin:Scalar = (minExtent.z - ray.origin.z) / ray.direction.z
        var tzMax:Scalar = (maxExtent.z - ray.origin.z) / ray.direction.z
        if tzMin > tzMax { swap(&tzMin, &tzMax) }
        
        if (tMin > tzMax) || (tzMin > tMax) { return false }
        if tzMin > tMin { tMin = tzMin }
        if tzMax < tMax { tMax = tzMax }
        
        return true
    }
}
