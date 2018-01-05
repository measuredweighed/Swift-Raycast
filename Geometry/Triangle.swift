//
//  Triangle.swift
//  Swift-Raycast
//
//  Created by @measuredweighed on 05/01/2018.
//  Copyright © 2018 UglyApps. All rights reserved.
//

import Foundation

class Vertex {
    var coord:Vector3
    var normal:Vector3? = nil
    var tangent:Vector3? = nil
    var bitangent:Vector3? = nil
    var uv:Vector2? = nil
    
    init(coord:Vector3, normal:Vector3? = nil, tangent:Vector3? = nil, bitangent:Vector3? = nil, uv:Vector2? = nil) {
        self.coord = coord
        self.normal = normal
        self.tangent = tangent
        self.bitangent = bitangent
        self.uv = uv
    }
}

class Triangle : Intersectable {
    
    var transform:Transform = Transform()
    var aabb:AABB
    
    var a:Vertex
    var b:Vertex
    var c:Vertex
    
    init(a:Vertex, b:Vertex, c:Vertex) {
        self.a = a
        self.b = b
        self.c = c
        
        self.aabb = AABB(points: [a.coord, b.coord, c.coord])
        self.transform.position = self.aabb.center
    }
    
    /**
     Determines whether this geometry intersects a given ray
     
     - Parameter ray: a `Ray` instance
     - Returns: an instance of `RayHit` on success
     */
    func intersects(ray: Ray) -> RayHit? {
        print("Here")
        if let hit = intersectsTriangle(ray: ray) {
            /*
             // face normal
             let u = face.b.coord - face.a.coord
             let v = face.c.coord - face.a.coord
             let normal = u.cross(v).normalized()
             */
            
            // interpolate the normal using gouraud's method
            let aN:Vector3 = a.normal ?? Vector3.zero
            let bN:Vector3 = b.normal ?? Vector3.zero
            let cN:Vector3 = c.normal ?? Vector3.zero
            let normal = (1 - hit.u - hit.v) * aN + hit.u * bN + hit.v * cN
            
            let distance = hit.distance
            let point = ray.origin + (ray.direction * distance)
            
            /*
            // if available interpolate the tangent vector using gouraud's method
            var tangent:Vector3? = nil
            if a.tangent != nil && b.tangent != nil && c.tangent != nil {
                let aT:Vector3 = a.tangent ?? Vector3.zero
                let bT:Vector3 = b.tangent ?? Vector3.zero
                let cT:Vector3 = c.tangent ?? Vector3.zero
                tangent = (1 - hit.u - hit.v) * aT + hit.u * bT + hit.v * cT
            }
            */
            
            // calculate a UV coordinate for this intersection
            var uv:Vector2? = nil
            if a.uv != nil && b.uv != nil && c.uv != nil {
                uv = (1 - hit.u - hit.v) * a.uv! + hit.u * b.uv! + hit.v * c.uv!
            }
            
            return RayHit(distance: distance, point: point, normal: normal, uv: uv)
        }
        
        return nil
    }
    
    /// based on https://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm
    private func intersectsTriangle(ray: Ray) -> (distance:Scalar, u:Scalar, v:Scalar)? {
        let edge1:Vector3 = b.coord - a.coord
        let edge2:Vector3 = c.coord - a.coord
        
        let pVec = ray.direction.cross(edge2)
        let det:Scalar = edge1.dot(pVec)
        
        let cullingEnabled:Bool = true
        let EPSILON:Scalar = 1e-8
        if (cullingEnabled && det < EPSILON) || (!cullingEnabled && abs(det) < EPSILON) {
            return nil
        }
        
        let invDet:Scalar = 1 / det
        let tVec:Vector3 = ray.origin - a.coord
        let u:Scalar = tVec.dot(pVec) * invDet
        if u < 0 || u > 1 { return nil }
        
        let qVec:Vector3 = tVec.cross(edge1)
        let v:Scalar = ray.direction.dot(qVec) * invDet
        if v < 0 || u + v > 1 { return nil }
        
        let distance:Scalar = edge2.dot(qVec) * invDet
        return (
            distance: distance,
            u: u,
            v: v
        )
    }
}
