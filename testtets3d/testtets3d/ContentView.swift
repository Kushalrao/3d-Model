import SwiftUI
import SceneKit
import ModelIO
import SceneKit.ModelIO

struct ContentView: View {
    @State private var fieldOfView: Double = 60.0
    
    var body: some View {
        ZStack {
            ProfessionalModelViewer(fieldOfView: fieldOfView)
                .ignoresSafeArea()
            
            // Field of View Slider - Fixed overlay at bottom
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
                    
                    Slider(value: $fieldOfView, in: 10...360, step: 1)
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
    }
}

struct ProfessionalModelViewer: UIViewRepresentable {
    let fieldOfView: Double
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        // Professional SceneKit setup
        setupSceneView(sceneView)
        
        // Create professional 3D scene
        let scene = createProfessionalScene()
        sceneView.scene = scene
        
        // Load the Dream On.glb model
        loadDreamOnModel(in: sceneView)
        
        // Setup professional camera controls
        setupCameraControls(sceneView, context: context)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update camera field of view and adjust position to maintain object size
        if let cameraNode = uiView.scene?.rootNode.childNodes.first(where: { $0.camera != nil }) {
            // Store original FOV and distance for calculations
            let originalFOV: CGFloat = 60.0
            let originalDistance: Float = 8.0
            
            // Update field of view
            cameraNode.camera?.fieldOfView = CGFloat(fieldOfView)
            
            // Calculate new distance to maintain object size - break into steps
            let originalFOVRadians = originalFOV * .pi / 180.0
            let newFOVRadians = CGFloat(fieldOfView) * .pi / 180.0
            let originalTan = tan(originalFOVRadians / 2.0)
            let newTan = tan(newFOVRadians / 2.0)
            let ratio = CGFloat(originalDistance) * (originalTan / newTan)
            let newDistance = Float(ratio)
            
            // Update camera position to maintain consistent object size
            cameraNode.position.z = newDistance
        }
    }
    
    private func setupSceneView(_ sceneView: SCNView) {
        // Professional SceneKit configuration
        sceneView.backgroundColor = UIColor(red: 0x22/255.0, green: 0x56/255.0, blue: 0xFF/255.0, alpha: 1.0)
        sceneView.antialiasingMode = .multisampling4X
        sceneView.preferredFramesPerSecond = 60
        sceneView.showsStatistics = false
        sceneView.allowsCameraControl = false // We'll implement custom controls
    }
    
    private func createProfessionalScene() -> SCNScene {
        let scene = SCNScene()
        
        // Professional lighting setup
        setupProfessionalLighting(scene)
        
        // Add environment
        setupEnvironment(scene)
        
        return scene
    }
    
    private func setupProfessionalLighting(_ scene: SCNScene) {
        // Key light (main directional light)
        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light!.type = .directional
        keyLight.light!.intensity = 1000
        keyLight.light!.color = UIColor.white
        keyLight.position = SCNVector3(5, 5, 5)
        keyLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(keyLight)
        
        // Fill light (softer, ambient)
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light!.type = .omni
        fillLight.light!.intensity = 300
        fillLight.light!.color = UIColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 1.0)
        fillLight.position = SCNVector3(-3, 2, 3)
        scene.rootNode.addChildNode(fillLight)
        
        // Rim light (for edge definition)
        let rimLight = SCNNode()
        rimLight.light = SCNLight()
        rimLight.light!.type = .omni
        rimLight.light!.intensity = 200
        rimLight.light!.color = UIColor(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0)
        rimLight.position = SCNVector3(0, -2, -5)
        scene.rootNode.addChildNode(rimLight)
        
        // Ambient light
        scene.lightingEnvironment.intensity = 0.3
    }
    
    private func setupEnvironment(_ scene: SCNScene) {
        // Set up environment for better reflections
        scene.lightingEnvironment.contents = UIColor.darkGray
        scene.background.contents = UIColor(red: 0x22/255.0, green: 0x56/255.0, blue: 0xFF/255.0, alpha: 1.0)
    }
    
    private func loadDreamOnModel(in view: SCNView) {
        print("🔍 ProfessionalModelViewer: Loading 3D model...")
        
        // Try to load GLB first, then OBJ
        var modelURL: URL?
        var fileFormat: String = ""
        
        // Try GLB first
        if let glbURL = Bundle.main.url(forResource: "Dream On", withExtension: "glb") {
            modelURL = glbURL
            fileFormat = "GLB"
            print("✅ Found Dream On.glb at: \(glbURL.path)")
        }
        // Try OBJ if GLB not found
        else if let objURL = Bundle.main.url(forResource: "Dream On", withExtension: "obj") {
            modelURL = objURL
            fileFormat = "OBJ"
            print("✅ Found Dream On.obj at: \(objURL.path)")
        }
        // Try any OBJ file if specific file not found
        else if let anyObjURL = Bundle.main.url(forResource: "Dream On", withExtension: "obj") {
            modelURL = anyObjURL
            fileFormat = "OBJ"
            print("✅ Found OBJ file at: \(anyObjURL.path)")
        }
        
        guard let url = modelURL else {
            print("❌ No 3D model file found in app bundle")
            print("🔍 Looking for: Dream On.glb or Dream On.obj")
            print("🔍 Bundle path: \(Bundle.main.bundlePath)")
            print("🔍 Bundle contents: \(try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath))")
            createProfessionalPlaceholder(in: view)
            return
        }
        
        print("🎯 Loading \(fileFormat) model from: \(url.path)")
        
        // Professional 3D model loading with format-specific options
        let loadingOptions: [SCNSceneSource.LoadingOption: Any]
        
        switch fileFormat {
        case "GLB":
            loadingOptions = [
                SCNSceneSource.LoadingOption.checkConsistency: true,
                SCNSceneSource.LoadingOption.convertToYUp: true,
                SCNSceneSource.LoadingOption.flattenScene: false
            ]
        case "OBJ":
            loadingOptions = [
                SCNSceneSource.LoadingOption.checkConsistency: true,
                SCNSceneSource.LoadingOption.convertToYUp: true,
                SCNSceneSource.LoadingOption.flattenScene: false,
                SCNSceneSource.LoadingOption.createNormalsIfAbsent: true
            ]
        default:
            loadingOptions = [
                SCNSceneSource.LoadingOption.checkConsistency: true,
                SCNSceneSource.LoadingOption.convertToYUp: true
            ]
        }
        
        // Load the scene with format-specific handling
        do {
            let scene: SCNScene
            
            if fileFormat == "OBJ" {
                // Use ModelIO for OBJ files to properly load materials
                print("🎨 Loading OBJ with ModelIO for proper material support...")
                let asset = MDLAsset(url: url)
                
                // Configure asset for better material loading
                asset.loadTextures()
                
                // Create scene from MDLAsset
                scene = SCNScene(mdlAsset: asset)
                
                print("📦 OBJ scene loaded with ModelIO")
                print("- MDL objects count: \(asset.count)")
                print("- Root node child count: \(scene.rootNode.childNodes.count)")
                
                // Debug material information
                debugMaterials(in: scene.rootNode)
                
            } else {
                // Use direct loading for GLB and other formats
                scene = try SCNScene(url: url, options: loadingOptions)
                
                print("📦 \(fileFormat) scene loaded successfully")
                print("- Root node child count: \(scene.rootNode.childNodes.count)")
            }
            
            // Professional model processing
            processLoadedModel(scene, in: view, format: fileFormat)
            
        } catch {
            print("❌ Failed to load \(fileFormat) model from: \(url.path)")
            print("❌ Error: \(error.localizedDescription)")
            createProfessionalPlaceholder(in: view)
        }
    }
    
    private func debugMaterials(in node: SCNNode) {
        if let geometry = node.geometry {
            print("🎨 Node '\(node.name ?? "unnamed")' materials:")
            for (index, material) in geometry.materials.enumerated() {
                print("  Material \(index):")
                print("    - Name: \(material.name ?? "unnamed")")
                print("    - Diffuse: \(material.diffuse.contents ?? "none")")
                print("    - Ambient: \(material.ambient.contents ?? "none")")
                print("    - Specular: \(material.specular.contents ?? "none")")
                print("    - Emission: \(material.emission.contents ?? "none")")
                
                // Fix common material issues for OBJ files
                if material.emission.contents != nil {
                    print("    - Setting emission to black to fix lighting")
                    material.emission.contents = UIColor.black
                }
            }
        }
        
        for child in node.childNodes {
            debugMaterials(in: child)
        }
    }
    
    private func processLoadedModel(_ scene: SCNScene, in view: SCNView, format: String) {
        // Find all geometry nodes
        var allGeometryNodes: [SCNNode] = []
        scene.rootNode.enumerateChildNodes { (node, _) in
            if node.geometry != nil {
                allGeometryNodes.append(node)
            }
        }
        
        print("🔍 Found \(allGeometryNodes.count) geometry nodes")
        
        if allGeometryNodes.isEmpty {
            print("❌ No geometry found in \(format) file - using placeholder")
            createProfessionalPlaceholder(in: view)
            return
        }
        
        // Create a container node for the entire model
        let modelContainer = SCNNode()
        modelContainer.name = "DreamOnModel"
        
        // Add all geometry nodes to container
        for node in allGeometryNodes {
            node.removeFromParentNode()
            modelContainer.addChildNode(node)
        }
        
        // Professional model centering and scaling
        centerAndScaleModel(modelContainer)
        
        // Add to scene
        view.scene?.rootNode.addChildNode(modelContainer)
        
        print("🎉 Successfully loaded \(format) model!")
        print("- Model container created with \(modelContainer.childNodes.count) child nodes")
    }
    
    private func centerAndScaleModel(_ node: SCNNode) {
        // Get bounding box of the entire model
        let boundingBox = node.boundingBox
        let center = SCNVector3(
            (boundingBox.max.x + boundingBox.min.x) / 2,
            (boundingBox.max.y + boundingBox.min.y) / 2,
            (boundingBox.max.z + boundingBox.min.z) / 2
        )
        
        // Center the model
        node.position = SCNVector3(-center.x, -center.y, -center.z)
        
        // Professional scaling - fit model in a 3x3x3 cube
        let size = max(boundingBox.max.x - boundingBox.min.x,
                      max(boundingBox.max.y - boundingBox.min.y,
                          boundingBox.max.z - boundingBox.min.z))
        
        if size > 0 {
            let targetSize: Float = 3.0
            let scale = targetSize / size
            node.scale = SCNVector3(scale, scale, scale)
            print("📏 Model scaled by factor: \(scale)")
        }
    }
    
    private func createProfessionalPlaceholder(in view: SCNView) {
        print("🔧 Creating professional placeholder model")
        
        // Create a more sophisticated placeholder
        let geometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0.2)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        material.specular.contents = UIColor.white
        material.shininess = 0.8
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        node.name = "PlaceholderModel"
        view.scene?.rootNode.addChildNode(node)
    }
    
    private func setupCameraControls(_ sceneView: SCNView, context: Context) {
        // Professional camera setup
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // Calculate appropriate distance for the field of view - break into steps
        let originalFOV: CGFloat = 60.0
        let originalDistance: Float = 8.0
        let originalFOVRadians = originalFOV * .pi / 180.0
        let newFOVRadians = CGFloat(fieldOfView) * .pi / 180.0
        let originalTan = tan(originalFOVRadians / 2.0)
        let newTan = tan(newFOVRadians / 2.0)
        let ratio = CGFloat(originalDistance) * (originalTan / newTan)
        let calculatedDistance = Float(ratio)
        
        cameraNode.camera?.fieldOfView = CGFloat(fieldOfView)
        cameraNode.camera?.zNear = 0.1
        cameraNode.camera?.zFar = 100
        cameraNode.position = SCNVector3(0, 0, calculatedDistance)
        sceneView.scene?.rootNode.addChildNode(cameraNode)
        
        // Setup professional gesture controls
        setupProfessionalGestures(sceneView, context: context, cameraNode: cameraNode)
    }
    
    private func setupProfessionalGestures(_ view: SCNView, context: Context, cameraNode: SCNNode) {
        // Orbit control (pan gesture)
        let orbitGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleOrbit(_:)))
        view.addGestureRecognizer(orbitGesture)
        
        // Zoom control (pinch gesture)
        let zoomGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleZoom(_:)))
        view.addGestureRecognizer(zoomGesture)
        
        // Store camera reference in coordinator
        context.coordinator.cameraNode = cameraNode
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var cameraNode: SCNNode?
        private var lastPanTranslation: CGPoint = .zero
        private var lastScale: CGFloat = 1
        private var orbitRadius: Float = 8.0
        
        @objc func handleOrbit(_ gesture: UIPanGestureRecognizer) {
            guard let view = gesture.view as? SCNView,
                  let camera = cameraNode else { return }
            
            let translation = gesture.translation(in: view)
            let deltaX = Float(translation.x - lastPanTranslation.x) * 0.01
            let deltaY = Float(translation.y - lastPanTranslation.y) * 0.01
            
            // Professional orbit controls
            let currentPosition = camera.position
            let distance = sqrt(currentPosition.x * currentPosition.x + 
                               currentPosition.z * currentPosition.z)
            
            // Horizontal rotation (around Y axis)
            let angleX = atan2(currentPosition.z, currentPosition.x) - deltaX
            let newX = distance * cos(angleX)
            let newZ = distance * sin(angleX)
            
            // Vertical rotation (around X axis) - with limits
            let currentY = currentPosition.y
            let newY = max(-5, min(5, currentY - deltaY * 2))
            
            camera.position = SCNVector3(newX, newY, newZ)
            camera.look(at: SCNVector3(0, 0, 0))
            
            lastPanTranslation = translation
            
            if gesture.state == .ended {
                lastPanTranslation = .zero
            }
        }
        
        @objc func handleZoom(_ gesture: UIPinchGestureRecognizer) {
            guard let camera = cameraNode else { return }
            
            let scale = Float(gesture.scale / lastScale)
            let currentPosition = camera.position
            let distance = sqrt(currentPosition.x * currentPosition.x + 
                               currentPosition.y * currentPosition.y + 
                               currentPosition.z * currentPosition.z)
            
            // Professional zoom with limits
            let newDistance = max(2.0, min(20.0, distance / scale))
            let direction = SCNVector3(
                currentPosition.x / distance,
                currentPosition.y / distance,
                currentPosition.z / distance
            )
            
            camera.position = SCNVector3(
                direction.x * newDistance,
                direction.y * newDistance,
                direction.z * newDistance
            )
            
            lastScale = gesture.scale
            
            if gesture.state == .ended {
                lastScale = 1
            }
        }
    }
}

#Preview {
    ContentView()
}
