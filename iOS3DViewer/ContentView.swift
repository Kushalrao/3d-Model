import SwiftUI

struct ContentView: View {
    @State private var selectedModel: String = "Dream On.glb"
    @State private var showingFilePicker = false
    @State private var modelExists = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("3D Model Viewer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text(modelExists ? "Dream On.glb Model Ready" : "Dream On.glb Not Found")
                    .font(.subheadline)
                    .foregroundColor(modelExists ? .secondary : .red)
                
                Spacer()
                
                VStack(spacing: 16) {
                    // Show the Dream On.glb model info
                    VStack(spacing: 8) {
                        Image(systemName: modelExists ? "cube.box.fill" : "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(modelExists ? .blue : .red)
                        
                        Text("Dream On.glb")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(modelExists ? "GLB 3D Model" : "File not found in Downloads")
                            .font(.caption)
                            .foregroundColor(modelExists ? .secondary : .red)
                    }
                    .padding()
                    .background(modelExists ? Color.blue.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Optional: Still allow loading other models
                    Button(action: {
                        showingFilePicker = true
                    }) {
                        HStack {
                            Image(systemName: "folder")
                                .font(.title2)
                            Text("Load Other Model")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // Direct link to view the Dream On.glb model (only if file exists)
                if modelExists {
                    NavigationLink(destination: ModelViewer(modelName: selectedModel)) {
                        Text("View Dream On Model")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                } else {
                    Text("Please ensure 'Dream On.glb' is in your Downloads folder")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .onAppear {
                checkModelExists()
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker { url in
                    selectedModel = url.lastPathComponent
                }
            }
        }
    }
    
    private func checkModelExists() {
        let documentsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let modelURL = documentsPath.appendingPathComponent("Dream On.glb")
        modelExists = FileManager.default.fileExists(atPath: modelURL.path)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onDocumentPicked(url)
        }
    }
}

#Preview {
    ContentView()
}
