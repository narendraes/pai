import SwiftUI
import AVFoundation
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        // Set up the preview layer
        cameraManager.setPreviewLayer(for: view)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the preview layer frame when the view is updated
        cameraManager.updatePreviewLayerFrame(for: uiView)
    }
}

struct CameraControlButton: View {
    let systemName: String
    let action: () -> Void
    let color: Color
    let isDisabled: Bool
    
    init(systemName: String, action: @escaping () -> Void, color: Color = .white, isDisabled: Bool = false) {
        self.systemName = systemName
        self.action = action
        self.color = color
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24))
                .foregroundColor(isDisabled ? .gray : color)
                .padding()
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
        }
        .disabled(isDisabled)
    }
}

struct CaptureButton: View {
    let action: () -> Void
    let isRecording: Bool
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white, lineWidth: 3)
                    .frame(width: 70, height: 70)
                
                if isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: 30, height: 30)
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 54, height: 54)
                }
            }
        }
    }
}

struct PhotoPreviewView: View {
    let image: UIImage
    let onDismiss: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: onSave) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding(.bottom)
            }
        }
    }
} 