import SwiftUI
import SceneKit

struct ModelViewer: View {
    let modelName: String
    @State private var fieldOfView: Double
    @StateObject private var modelLoader = ModelLoader()
    @State private var sceneView: SCNView?
    @State private var modelNode: SCNNode?
    @State private var cameraNode: SCNNode?
    @State private var showingControls = true
    
    init(modelName: String, fieldOfView: Double) {
        self.modelName = modelName
        self._fieldOfView = State(initialValue: fieldOfView)
    }
    
    var body: some View {
        ZStack {
            // 3D Scene View
            SceneViewWrapper(
                modelName: modelName,
                fieldOfView: fieldOfView,
                modelLoader: modelLoader,
                sceneView: $sceneView,
                modelNode: $modelNode,
                cameraNode: $cameraNode
            )
            .ignoresSafeArea()
            
            // Control Panel
            VStack {
                HStack {
                    Button(action: {
                        showingControls.toggle()
                    }) {
                        Image(systemName: showingControls ? "eye.slash" : "eye")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        resetCamera()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
                
                if showingControls {
                    ControlPanel(
                        modelNode: modelNode,
                        cameraNode: cameraNode,
                        sceneView: sceneView
                    )
                    .padding()
                }
            }
            
            // Loading Indicator
            if modelLoader.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading 3D Model...")
                        .font(.headline)
                        .padding(.top)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
            }
            
            // Error Message
            if let errorMessage = modelLoader.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
            }
            
            // Field of View Slider - Fixed overlay at bottom (LAST ELEMENT)
            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Field of View:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(Int(fieldOfView))°")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    Slider(value: Binding(
                        get: { fieldOfView },
                        set: { newValue in
                            fieldOfView = newValue
                            cameraNode?.camera?.fieldOfView = CGFloat(newValue)
                        }
                    ), in: 10...360, step: 1)
                        .accentColor(.blue)
                    
                    HStack {
                        Text("10°")
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text("360°")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.8))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(modelName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func resetCamera() {
        guard let cameraNode = cameraNode else { return }
        
        // Reset camera position
        cameraNode.position = SCNVector3(0, 0, 5)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        
        // Reset model rotation
        modelNode?.eulerAngles = SCNVector3(0, 0, 0)
    }
}

struct SceneViewWrapper: UIViewRepresentable {
    let modelName: String
    let fieldOfView: Double
    @ObservedObject var modelLoader: ModelLoader
    @Binding var sceneView: SCNView?
    @Binding var modelNode: SCNNode?
    @Binding var cameraNode: SCNNode?
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = UIColor.systemBackground
        
        // Create scene
        let scene = modelLoader.createDefaultScene()
        view.scene = scene
        
        // Set up camera
        let camera = SCNCamera()
        camera.fieldOfView = CGFloat(fieldOfView)
        cameraNode = SCNNode()
        cameraNode?.camera = camera
        cameraNode?.position = SCNVector3(0, 0, 5)
        scene.rootNode.addChildNode(cameraNode!)
        
        // Set up gestures
        setupGestures(for: view)
        
        // Load model
        loadModel(in: view)
        
        sceneView = view
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update camera field of view when it changes
        cameraNode?.camera?.fieldOfView = CGFloat(fieldOfView)
    }
    
    private func loadModel(in view: SCNView) {
        // Load the Dream On.glb file from Downloads
        let documentsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let modelURL = documentsPath.appendingPathComponent("Dream On.glb")
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: modelURL.path) else {
            print("Dream On.glb file not found at: \(modelURL.path)")
            // Fallback to placeholder cube
            createPlaceholderModel(in: view)
            return
        }
        
        // Load the actual GLB model
        if let loadedNode = modelLoader.loadModel(from: modelURL) {
            loadedNode.name = "model"
            view.scene?.rootNode.addChildNode(loadedNode)
            modelNode = loadedNode
            print("Successfully loaded Dream On.glb model")
        } else {
            print("Failed to load Dream On.glb model")
            // Fallback to placeholder cube
            createPlaceholderModel(in: view)
        }
    }
    
    private func createPlaceholderModel(in view: SCNView) {
        // Create a simple cube as placeholder
        let geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        node.name = "model"
        view.scene?.rootNode.addChildNode(node)
        modelNode = node
    }
    
    private func setupGestures(for view: SCNView) {
        // Pan gesture for rotation
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        view.addGestureRecognizer(panGesture)
        
        // Pinch gesture for zoom
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        // Rotation gesture
        let rotationGesture = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotation(_:)))
        view.addGestureRecognizer(rotationGesture)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: SceneViewWrapper
        
        init(_ parent: SceneViewWrapper) {
            self.parent = parent
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let modelNode = parent.modelNode else { return }
            
            let translation = gesture.translation(in: gesture.view)
            let sensitivity: Float = 0.01
            
            // Rotate around Y axis (horizontal pan)
            let rotationY = Float(translation.x) * sensitivity
            // Rotate around X axis (vertical pan)
            let rotationX = Float(translation.y) * sensitivity
            
            modelNode.eulerAngles.y += rotationY
            modelNode.eulerAngles.x += rotationX
            
            gesture.setTranslation(.zero, in: gesture.view)
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let cameraNode = parent.cameraNode else { return }
            
            let scale = Float(gesture.scale)
            let currentPosition = cameraNode.position
            
            // Move camera closer/farther based on pinch
            let newZ = currentPosition.z / scale
            cameraNode.position = SCNVector3(currentPosition.x, currentPosition.y, max(1, min(20, newZ)))
            
            gesture.scale = 1.0
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let modelNode = parent.modelNode else { return }
            
            let rotation = Float(gesture.rotation)
            modelNode.eulerAngles.z += rotation
            
            gesture.rotation = 0
        }
    }
}

struct ControlPanel: View {
    let modelNode: SCNNode?
    let cameraNode: SCNNode?
    let sceneView: SCNView?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Controls")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                // Reset button
                Button(action: {
                    resetModel()
                }) {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(8)
                }
                
                // Auto rotate toggle
                Button(action: {
                    toggleAutoRotate()
                }) {
                    VStack {
                        Image(systemName: "rotate.3d")
                        Text("Auto Rotate")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(8)
                }
                
                // Wireframe toggle
                Button(action: {
                    toggleWireframe()
                }) {
                    VStack {
                        Image(systemName: "grid")
                        Text("Wireframe")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange.opacity(0.8))
                    .cornerRadius(8)
                }
            }
            
            // Instructions
            Text("Pan to rotate • Pinch to zoom • Rotate gesture for Z-axis rotation")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
    }
    
    private func resetModel() {
        modelNode?.eulerAngles = SCNVector3(0, 0, 0)
        cameraNode?.position = SCNVector3(0, 0, 5)
    }
    
    private func toggleAutoRotate() {
        guard let modelNode = modelNode else { return }
        
        if modelNode.action(forKey: "rotation") != nil {
            modelNode.removeAction(forKey: "rotation")
        } else {
            let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 10)
            let repeatRotation = SCNAction.repeatForever(rotation)
            modelNode.runAction(repeatRotation, forKey: "rotation")
        }
    }
    
    private func toggleWireframe() {
        guard let modelNode = modelNode else { return }
        
        modelNode.geometry?.firstMaterial?.fillMode = 
            modelNode.geometry?.firstMaterial?.fillMode == .lines ? .fill : .lines
    }
}

#Preview {
    ModelViewer(modelName: "Sample Model", fieldOfView: 60.0)
}