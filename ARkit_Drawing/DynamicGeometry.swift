//
//  DynamicGeometry.swift
//
//  Created by Shuichi Tsutsumi on 2016/12/01.
//  Copyright © 2016 Shuichi Tsutsumi. All rights reserved.
//

import SceneKit

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func += (left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

func / (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

func /= (left: inout SCNVector3, right: Float) {
    left = left / right
}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}

extension matrix_float4x4 {
    func position() -> SCNVector3 {
        let mat = SCNMatrix4(self)
        return SCNVector3(mat.m41, mat.m42, mat.m43)
    }
}

open class DynamicGeometryNode: SCNNode {
    
    private var vertices: [SCNVector3] = []
    private var indices: [Int32] = []
    private let lineWidth: Float
    private let color: UIColor
    private var verticesPool: [SCNVector3] = []

    public init(color: UIColor, lineWidth: Float) {
        self.color = color
        self.lineWidth = lineWidth
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addVertice(_ vertice: SCNVector3) {
        var smoothed = SCNVector3Zero
        if verticesPool.count < 3 {
            if !SCNVector3EqualToVector3(vertice, SCNVector3Zero) {
                verticesPool.append(vertice)
            }
            return
        } else {
            for vertice in verticesPool {
                smoothed += vertice
            }
            smoothed /= Float(verticesPool.count)
            verticesPool.removeAll()
        }
        vertices.append(SCNVector3Make(smoothed.x, smoothed.y - lineWidth, smoothed.z))
        vertices.append(SCNVector3Make(smoothed.x, smoothed.y + lineWidth, smoothed.z))
        let count = vertices.count
        indices.append(Int32(count-2))
        indices.append(Int32(count-1))
        
        updateGeometryIfNeeded()
    }
    
    private func updateGeometryIfNeeded() {
        guard vertices.count >= 3 else {
//            print("not enough vertices")
            return
        }
        
        let source = SCNGeometrySource(vertices: vertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangleStrip)
        geometry = SCNGeometry(sources: [source], elements: [element])
        if let material = geometry?.firstMaterial {
            material.diffuse.contents = color
            material.isDoubleSided = true
        }
    }
    
    public func reset() {
        verticesPool.removeAll()
        vertices.removeAll()
        indices.removeAll()
        geometry = nil
    }
    
}

