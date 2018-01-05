//
//  transform.swift
//  Swift-BVH
//
//  Created by Nial Giacomelli on 01/08/2017.
//  Copyright © 2017 UglyApps. All rights reserved.
//

import Foundation

class Transform {
    
    /// position in world space
    public var position:Vector3 = Vector3.zero {
        didSet {
            matrixNeedsUpdate = true
        }
    }
    
    /// rotation
    public var rotation:Quaternion = Quaternion.identity {
        didSet {
            matrixNeedsUpdate = true
        }
    }
    
    /// scale
    public var scale:Vector3 = Vector3(1, 1, 1) {
        didSet {
            matrixNeedsUpdate = true
        }
    }
    
    private var _matrix:Matrix4 = Matrix4.identity
    public var matrix:Matrix4 {
        get {
            if matrixNeedsUpdate {
                let translation = Matrix4(translation: position)
                let rotation = Matrix4(quaternion: self.rotation)
                let scale = Matrix4(scale: self.scale)
                
                _matrix = translation * (rotation * scale)
                matrixNeedsUpdate = false
            }
            return _matrix
        }
    }
    
    /// denotes whether we need to recalculate this transforms matrix
    private var matrixNeedsUpdate:Bool = true
}
