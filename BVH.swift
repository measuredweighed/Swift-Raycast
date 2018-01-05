//
//  BVH.swift
//  Swift-Raycast
//
//  Created by @measuredweighed on 06/08/2017.
//  Copyright © 2017 UglyApps. All rights reserved.
//

import Foundation

struct BVHNode {
    
    /// used to communicate the dominant axis during sorting and division
    private enum BVHAxis {
        case x
        case y
        case z
    }

    /// an AABB which fully contains the geometry in this node
    var aabb:AABB
    
    /// a flag denoting whether the node is a leaf (i.e: true when it contains geometry instances, false when it only contains additional `BVHNode`s
    var isLeaf:Bool = false
    
    /// a collection of `Intersectable` geometry that this node contains
    var intersectables:[Intersectable] = [Intersectable]()
    
    /// a collection of `BVHNode` instances this node contains
    var children:[BVHNode] = [BVHNode]()
    
    /// the maximum number of `Intersectable` objects this node can contain
    var threshold:Int = 10
    
    init(intersectables:[Intersectable], threshold:Int=10) {
        self.threshold = threshold
        
        aabb = AABB(containing: intersectables.map { return $0.aabb })
        
        if intersectables.count > threshold {
            let xAxis:Scalar = abs(aabb.maxExtent.x - aabb.minExtent.x)
            let yAxis:Scalar = abs(aabb.maxExtent.y - aabb.minExtent.y)
            let zAxis:Scalar = abs(aabb.maxExtent.z - aabb.minExtent.z)
            
            // determine the 'largest' or dominant axis to figure out how to best split this node
            var largestAxis:BVHAxis
            if(yAxis > xAxis && yAxis > zAxis) {
                largestAxis = .y
            } else if(zAxis > xAxis && zAxis > yAxis) {
                largestAxis = .z
            } else {
                largestAxis = .x
            }
            
            // sort intersectables along largest axis
            let sortedIntersectables = intersectables.sorted(by: { (a, b) -> Bool in
                
                switch largestAxis {
                    case .y: return a.aabb.center.y < b.aabb.center.y
                    case .z: return a.aabb.center.z < b.aabb.center.z
                    default: return a.aabb.center.x < b.aabb.center.x
                }
                
            })
            
            // determine the index where the mid-point split should occur along the prominent axis
            var splitIndex:Int = 0
            let numIntersectables = sortedIntersectables.count
            for i in 0 ..< numIntersectables {
                
                let intersectable = sortedIntersectables[i]
                if (largestAxis == .x && intersectable.aabb.center.x >= aabb.center.x) ||
                    (largestAxis == .y && intersectable.aabb.center.y >= aabb.center.y) ||
                    (largestAxis == .z && intersectable.aabb.center.z >= aabb.center.z) {
                    
                    splitIndex = i
                    break
                        
                }
                
            }
            
            // we can run into situations where all nodes have an identical value along the dominant axis...
            // in cases such as this, we just split right down the middle as a fallback
            if splitIndex == 0 || splitIndex == numIntersectables-1 {
                splitIndex = numIntersectables/2
            }
            
            let leftIntersectables:[Intersectable] = Array(sortedIntersectables[0 ..< splitIndex])
            let rightIntersectables:[Intersectable] = Array(sortedIntersectables[splitIndex ..< sortedIntersectables.count])
            if leftIntersectables.count > 0 {
                children.append(BVHNode(intersectables: leftIntersectables, threshold: threshold))
            }
            if rightIntersectables.count > 0 {
                children.append(BVHNode(intersectables: rightIntersectables, threshold: threshold))
            }
            
        } else {
            
            isLeaf = true
            self.intersectables = intersectables
            
        }
    }
    
    /**
     Recursively trace through this node and it's children, checking for ray -> AABB intersections.
     Returns `nil` or a set of `Intersectable`'s in the case of intersections
 
     - Parameter ray: the ray to test against
     */
    func trace(ray: Ray) -> [Intersectable]? {
        if aabb.intersects(ray: ray) {
            
            // if we're a leaf node and the ray intersects us return all of the `Intersectables` we contain
            if isLeaf {
                
                return intersectables
                
            } else {
                
                // if we're a branch node and the ray intersects us recurse down into our left and right nodes
                var intersectables:[Intersectable] = [Intersectable]()
                for child in children {
                    if let childIntersectables = child.trace(ray: ray) {
                        intersectables.append(contentsOf: childIntersectables)
                    }
                }
                return intersectables.count > 0 ? intersectables : nil
                
            }
        }
        
        return nil
    }
}

struct BVH {
    
    /// the root node of the BVH structure
    var root:BVHNode
    
    /**
     Initialises the BVH with a list of `Intersectable` objects
 
     - Parameters: a collection of `Intersectable` objects to populate the BVH with
     */
    init(intersectables:[Intersectable], threshold:Int = 2) {
        root = BVHNode(intersectables: intersectables, threshold: threshold)
    }
    
    /**
     A recursive trace function that works through the BVH
 
     - Parameter ray: the `Ray` instance to test against
     - Returns: an optional array of `Intersectable` instances for narrowphase testing
     */
    func trace(ray:Ray) -> [Intersectable]? {
        return root.trace(ray: ray)
    }
    
}
