import UIKit
import SwiftUI
import RealityKit
import ARKit

struct ARViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        
        context.coordinator.view = view
        context.coordinator.setupView()
        
        return view
    }
    
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
    
    func makeCoordinator() -> ARViewCoordinator {
        return ARViewCoordinator()
    }
}

class ARViewCoordinator: NSObject {
    var view: ARView?
    var camera = PerspectiveCamera()
    
    func setupView() {
        guard let view else {
            return
        }
        
        var material = SimpleMaterial(color: .blue, isMetallic: true)
        material.roughness = 0.05
        
        let box = ModelEntity(mesh: .generateBox(size: 1), materials: [material])
        box.generateCollisionShapes(recursive: true)
        let boxAnchor = AnchorEntity(world: .zero)
        boxAnchor.addChild(box)
        
        view.installGestures(.scale, for: box)
        
        view.scene.addAnchor(boxAnchor)
        
        camera.camera.fieldOfViewInDegrees = 60
        
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        
        view.scene.addAnchor(cameraAnchor)
        
        let skyboxName = "city"
        let skyboxResource = try! EnvironmentResource.load(named: skyboxName)
        view.environment.lighting.resource = skyboxResource
        view.environment.background = .skybox(skyboxResource)
//        view.environment.background = .color(.darkGray)
        
        let cameraTranslation = SIMD3<Float>(3, 1.5 , 3)
        aimCamera(from: cameraTranslation, at: box.position)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panRecognizer)
    }
    
    @objc
    func handlePan(_ gesture: UIPanGestureRecognizer) {
        let panXFactor: CGFloat = 100
        let panYFactor: CGFloat = 75
        let cameraDistance: CGFloat = 3
        
//        print(gesture.translation(in: view))
        let translation = gesture.translation(in: view)
        let x = -sin(translation.x / panXFactor) * cameraDistance
        let z = cos(translation.x / panXFactor) * cameraDistance
        let y = sin(translation.y / panYFactor) * 3
        print(y)
        
        let cameraTranslation = SIMD3<Float>(Float(x), Float(y), Float(z))
        aimCamera(from: cameraTranslation, at: .zero)
    }
    
    private func aimCamera(from cameraTranslation: SIMD3<Float>, at target: SIMD3<Float>) {
        camera.transform = Transform(
            scale: .one,
            rotation: simd_quatf(),
            translation: cameraTranslation
        )
        
        camera.look(
            at: target,
            from: cameraTranslation,
            relativeTo: nil
        )
    }
}
