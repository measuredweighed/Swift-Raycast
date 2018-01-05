# Swift-Raycast
A Swift raycasting and [Bounding Volume Hierarchy](https://en.wikipedia.org/wiki/Bounding_volume_hierarchy) (BVH) implementation presented as a loose collection of classes. Hopefully they'll be helpful to someone.

## Raycasting
The `Intersectable` protocol defines a data structure that is capable of testing for intersections against a `Ray` instance and producing a `RayHit` upon successful detection of an intersection.

Below is an example of a successful Ray -> Sphere intersection test:

```swift
let sphere = Sphere(position: Vector3.zero, rotation: Quaternion.identity, radius: 5)
let ray = Ray(origin: Vector3(0, 0, 10), direction: Vector3(0, 0, -1))
if let intersection = sphere.intersects(ray: ray) {
    print(intersection)
}
```

Also included is a primitive `Triangle` implementation (which may seem oddly primitive but is in fact extremely useful for testing collisions against more complex triangle-based meshes).

Below is an example of a successful Ray -> Triangle intersection test:

```swift
let vA = Vertex(coord: Vector3(0, 1, 0))
let vB = Vertex(coord: Vector3(-1, 0, 0))
let vC = Vertex(coord: Vector3(1, 0, 0))
let triangle = Triangle(a: vA, b: vB, c: vC)

let ray = Ray(origin: Vector3(0, 0, 10), direction: Vector3(0, 0, -1))
if let intersection = triangle.intersects(ray: ray) {
    print(intersection)
}
```

## Bounding Volume Hierarchy
Large numbers of intersection tests can be a performance bottleneck. One way of avoiding some of this overhead is to use a [Bounding Volume Hierarchy](https://en.wikipedia.org/wiki/Bounding_volume_hierarchy) - which performs simplified AABB -> Ray intersection tests to produce a subset of objects for more extensive raycasting.

Below is an example of using a BVH that queries a collection of 40,000 `Sphere` instances and returns a small subset for further testing.

```swift
var intersectables = [Intersectable]()
for y:Scalar in stride(from: -100, to: 100, by: 1) {
    for x:Scalar in stride(from: -100, to: 100, by: 1) {
        let sphere = Sphere(position: Vector3(x, y, 0), rotation: Quaternion.identity, radius: 0.5)
        intersectables.append(sphere)
    }
}

var bvh = BVH(intersectables: intersectables, threshold: 10)
if let intersections = bvh.trace(ray: ray) {
    print(intersections)
}
```

It's important to note that the BVH implementation here is by no means optimised, and hasn't been used for real-time work, but was incredibly helpful in cutting down intersection test counts for stuff like raytracing.

## Transforms
Also included is a very bare-bones implementation of a `Transform` class - useful for describing the position, rotation and scale of a 3D object. `Transform` objects can be queried for their worldMatrix (and will cache the resultant object until being dirtied again):

```swift
object.matrix
```

## Vectors and Matrices
This collection of code makes use of Nick Lockwood's excellent [VectorMath](https://github.com/nicklockwood/VectorMath) library - which I've included a (slightly modified) version of here for completeness.

All code makes use of a `Scalar` type, which is simply typealiased in `VectorMath.swift` like so:

```swift
public typealias Scalar = Double
```