import Foundation
import SceneKit
import ModelIO

class ModelLoader: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadModel(from url: URL) -> SCNNode? {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "gltf", "glb":
            return loadGLTFModel(from: url)
        case "obj":
            return loadOBJModel(from: url)
        case "dae":
            return loadDAEModel(from: url)
        case "scn":
            return loadSCNModel(from: url)
        default:
            errorMessage = "Unsupported file format: \(fileExtension)"
            return nil
        }
    }
    
    private func loadGLTFModel(from url: URL) -> SCNNode? {
        do {
            // For GLTF/GLB files, we'll use ModelIO to convert to SceneKit
            let asset = MDLAsset(url: url)
            
            // Check if the asset loaded successfully
            guard asset.count > 0 else {
                errorMessage = "No objects found in GLTF/GLB file"
                return nil
            }
            
            let scene = SCNScene(mdlAsset: asset)
            
            // Get the root node
            guard let rootNode = scene.rootNode.childNodes.first else {
                errorMessage = "No model found in GLTF/GLB file"
                return nil
            }
            
            // Center the model
            centerModel(rootNode)
            
            // Add some debugging info
            print("GLTF/GLB model loaded successfully:")
            print("- Child nodes count: \(rootNode.childNodes.count)")
            print("- Geometry count: \(rootNode.childNodes.filter { $0.geometry != nil }.count)")
            
            return rootNode
            
        } catch {
            errorMessage = "Failed to load GLTF/GLB model: \(error.localizedDescription)"
            print("GLTF/GLB loading error: \(error)")
            return nil
        }
    }
    
    private func loadOBJModel(from url: URL) -> SCNNode? {
        do {
            // Load OBJ using ModelIO
            let asset = MDLAsset(url: url)
            let scene = SCNScene(mdlAsset: asset)
            
            guard let rootNode = scene.rootNode.childNodes.first else {
                errorMessage = "No model found in OBJ file"
                return nil
            }
            
            // Center the model
            centerModel(rootNode)
            
            return rootNode
            
        } catch {
            errorMessage = "Failed to load OBJ model: \(error.localizedDescription)"
            return nil
        }
    }
    
    private func loadDAEModel(from url: URL) -> SCNNode? {
        do {
            let scene = try SCNScene(url: url, options: nil)
            
            guard let rootNode = scene.rootNode.childNodes.first else {
                errorMessage = "No model found in DAE file"
                return nil
            }
            
            // Center the model
            centerModel(rootNode)
            
            return rootNode
            
        } catch {
            errorMessage = "Failed to load DAE model: \(error.localizedDescription)"
            return nil
        }
    }
    
    private func loadSCNModel(from url: URL) -> SCNNode? {
        do {
            let scene = try SCNScene(url: url, options: nil)
            
            guard let rootNode = scene.rootNode.childNodes.first else {
                errorMessage = "No model found in SCN file"
                return nil
            }
            
            // Center the model
            centerModel(rootNode)
            
            return rootNode
            
        } catch {
            errorMessage = "Failed to load SCN model: \(error.localizedDescription)"
            return nil
        }
    }
    
    private func centerModel(_ node: SCNNode) {
        // Calculate bounding box
        let boundingBox = node.boundingBox
        let center = SCNVector3(
            (boundingBox.max.x + boundingBox.min.x) / 2,
            (boundingBox.max.y + boundingBox.min.y) / 2,
            (boundingBox.max.z + boundingBox.min.z) / 2
        )
        
        // Move the node so it's centered at origin
        node.position = SCNVector3(-center.x, -center.y, -center.z)
        
        // Scale the model to fit in a reasonable size
        let size = max(
            boundingBox.max.x - boundingBox.min.x,
            max(
                boundingBox.max.y - boundingBox.min.y,
                boundingBox.max.z - boundingBox.min.z
            )
        )
        
        if size > 0 {
            let scale = 2.0 / size // Scale to fit in a 2-unit cube
            node.scale = SCNVector3(scale, scale, scale)
        }
    }
    
    func createDefaultScene() -> SCNScene {
        let scene = SCNScene()
        
        // Add ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
        ambientLight.intensity = 300
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        // Add directional light
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.color = UIColor.white
        directionalLight.intensity = 1000
        directionalLight.castsShadow = true
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.position = SCNVector3(5, 5, 5)
        directionalNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directionalNode)
        
        return scene
    }
}
