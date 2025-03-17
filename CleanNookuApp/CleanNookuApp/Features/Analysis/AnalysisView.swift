import SwiftUI

struct AnalysisView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var analysisResults: [AnalysisResult] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("Analysis Type", selection: $selectedTab) {
                Text("Image").tag(0)
                Text("Video").tag(1)
                Text("Batch").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    // Media upload section
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .padding()
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                                    .frame(height: 200)
                                
                                VStack(spacing: 12) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                    
                                    Text("Tap to select an image for analysis")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding()
                            .onTapGesture {
                                showImagePicker = true
                            }
                        }
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Label("Select Image", systemImage: "photo.on.rectangle")
                            }
                            .buttonStyle(.bordered)
                            
                            if selectedImage != nil {
                                Button(action: {
                                    analyzeImage()
                                }) {
                                    Label("Analyze", systemImage: "magnifyingglass")
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(isAnalyzing || !appState.isConnected)
                            }
                        }
                        .padding(.bottom)
                    }
                    
                    // Analysis options
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Analysis Options")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        AnalysisOptionRow(icon: "person.fill", title: "Person Detection", isEnabled: true)
                        AnalysisOptionRow(icon: "cube.fill", title: "Object Recognition", isEnabled: true)
                        AnalysisOptionRow(icon: "text.viewfinder", title: "Text Recognition", isEnabled: true)
                        AnalysisOptionRow(icon: "exclamationmark.triangle.fill", title: "Anomaly Detection", isEnabled: false)
                    }
                    .padding(.vertical)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Results section
                    if !analysisResults.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Analysis Results")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(analysisResults) { result in
                                ResultRow(result: result)
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    if isAnalyzing {
                        ProgressView("Analyzing...")
                            .padding()
                    }
                }
                .padding(.bottom)
            }
            
            // Connection status
            if !appState.isConnected {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Not connected to server")
                        .font(.caption)
                    Spacer()
                    Button("Connect") {
                        appState.connect()
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
        }
        .navigationTitle("Media Analysis")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func analyzeImage() {
        guard let _ = selectedImage, appState.isConnected else { return }
        
        isAnalyzing = true
        analysisResults = []
        
        // Simulate analysis process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Generate sample results
            analysisResults = [
                AnalysisResult(id: UUID(), type: .person, confidence: 0.92, label: "Person"),
                AnalysisResult(id: UUID(), type: .object, confidence: 0.87, label: "Chair"),
                AnalysisResult(id: UUID(), type: .object, confidence: 0.76, label: "Table"),
                AnalysisResult(id: UUID(), type: .text, confidence: 0.95, label: "EXIT")
            ]
            isAnalyzing = false
        }
    }
}

struct AnalysisOptionRow: View {
    let icon: String
    let title: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(isEnabled ? .blue : .gray)
            
            Text(title)
                .foregroundColor(isEnabled ? .primary : .gray)
            
            Spacer()
            
            Toggle("", isOn: .constant(isEnabled))
                .labelsHidden()
                .disabled(!isEnabled)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ResultRow: View {
    let result: AnalysisResult
    
    var body: some View {
        HStack {
            Image(systemName: result.type.iconName)
                .frame(width: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(result.label)
                    .font(.headline)
                
                Text(result.type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(result.confidence * 100))%")
                .font(.headline)
                .foregroundColor(result.confidence > 0.8 ? .green : .orange)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct AnalysisResult: Identifiable {
    let id: UUID
    let type: AnalysisType
    let confidence: Double
    let label: String
}

enum AnalysisType {
    case person
    case object
    case text
    case anomaly
    
    var iconName: String {
        switch self {
        case .person: return "person.fill"
        case .object: return "cube.fill"
        case .text: return "text.viewfinder"
        case .anomaly: return "exclamationmark.triangle.fill"
        }
    }
    
    var description: String {
        switch self {
        case .person: return "Person Detection"
        case .object: return "Object Recognition"
        case .text: return "Text Recognition"
        case .anomaly: return "Anomaly Detection"
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnalysisView()
                .environmentObject(AppState())
        }
    }
}
