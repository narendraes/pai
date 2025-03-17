import SwiftUI
import AVKit

struct MediaLibraryView: View {
    @StateObject private var cameraManager = CameraManager()
    @State private var photos: [URL] = []
    @State private var videos: [URL] = []
    @State private var selectedTab = 0
    @State private var selectedMedia: URL?
    @State private var showMediaViewer = false
    @State private var showDeleteConfirmation = false
    @State private var showSaveToPhotosConfirmation = false
    @State private var isLoading = true
    @State private var showCleanupConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Media Library")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Menu {
                    Button(action: {
                        loadMedia()
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    
                    Button(action: {
                        showCleanupConfirmation = true
                    }) {
                        Label("Clean Old Media", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
            }
            .padding()
            
            // Tab selector
            Picker("Media Type", selection: $selectedTab) {
                Text("Photos").tag(0)
                Text("Videos").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            if isLoading {
                Spacer()
                ProgressView("Loading media...")
                Spacer()
            } else if (selectedTab == 0 && photos.isEmpty) || (selectedTab == 1 && videos.isEmpty) {
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: selectedTab == 0 ? "photo" : "video")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)
                    
                    Text("No \(selectedTab == 0 ? "Photos" : "Videos") Found")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Captured \(selectedTab == 0 ? "photos" : "videos") will appear here")
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                // Media grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 10)], spacing: 10) {
                        ForEach(selectedTab == 0 ? photos : videos, id: \.self) { url in
                            MediaThumbnail(url: url, mediaType: selectedTab == 0 ? .photo : .video)
                                .frame(height: 150)
                                .cornerRadius(8)
                                .onTapGesture {
                                    selectedMedia = url
                                    showMediaViewer = true
                                }
                                .contextMenu {
                                    Button(action: {
                                        selectedMedia = url
                                        showSaveToPhotosConfirmation = true
                                    }) {
                                        Label("Save to Photos", systemImage: "square.and.arrow.down")
                                    }
                                    
                                    Button(action: {
                                        selectedMedia = url
                                        showDeleteConfirmation = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            loadMedia()
        }
        .sheet(isPresented: $showMediaViewer) {
            if let url = selectedMedia {
                MediaViewer(url: url, mediaType: selectedTab == 0 ? .photo : .video)
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Media"),
                message: Text("Are you sure you want to delete this \(selectedTab == 0 ? "photo" : "video")?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let url = selectedMedia {
                        deleteMedia(url: url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showSaveToPhotosConfirmation) {
            Alert(
                title: Text("Save to Photos"),
                message: Text("Do you want to save this \(selectedTab == 0 ? "photo" : "video") to your Photos library?"),
                primaryButton: .default(Text("Save")) {
                    if let url = selectedMedia {
                        saveToPhotos(url: url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showCleanupConfirmation) {
            Alert(
                title: Text("Clean Old Media"),
                message: Text("This will delete all media older than one week. Continue?"),
                primaryButton: .destructive(Text("Clean")) {
                    cleanupOldMedia()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func loadMedia() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let photos = cameraManager.getAllPhotos()
            let videos = cameraManager.getAllVideos()
            
            DispatchQueue.main.async {
                self.photos = photos
                self.videos = videos
                self.isLoading = false
            }
        }
    }
    
    private func deleteMedia(url: URL) {
        if cameraManager.deleteMedia(at: url) {
            // Remove from our arrays
            if selectedTab == 0 {
                photos.removeAll { $0 == url }
            } else {
                videos.removeAll { $0 == url }
            }
        }
    }
    
    private func saveToPhotos(url: URL) {
        if selectedTab == 0 {
            // It's a photo
            if let image = UIImage(contentsOfFile: url.path) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        } else {
            // It's a video
            UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
        }
    }
    
    private func cleanupOldMedia() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            cameraManager.cleanupOldMedia()
            
            DispatchQueue.main.async {
                loadMedia()
            }
        }
    }
}

struct MediaThumbnail: View {
    let url: URL
    let mediaType: MediaType
    @State private var thumbnail: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                
                // Video indicator
                if mediaType == .video {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                            
                            Spacer()
                        }
                        .padding(5)
                    }
                }
            } else if isLoading {
                ProgressView()
            } else {
                Color.gray
                Image(systemName: mediaType == .photo ? "photo" : "video")
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            var image: UIImage?
            
            if mediaType == .photo {
                // Load photo thumbnail
                image = UIImage(contentsOfFile: url.path)
            } else {
                // Generate video thumbnail
                let asset = AVAsset(url: url)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                
                do {
                    let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 60), actualTime: nil)
                    image = UIImage(cgImage: cgImage)
                } catch {
                    print("Error generating thumbnail: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.thumbnail = image
                self.isLoading = false
            }
        }
    }
}

struct MediaViewer: View {
    let url: URL
    let mediaType: MediaType
    @Environment(\.presentationMode) var presentationMode
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if mediaType == .photo, let image = image {
                // Photo viewer
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .edgesIgnoringSafeArea(.all)
            } else if mediaType == .video {
                // Video player
                VideoPlayer(player: AVPlayer(url: url))
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Close button
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .onAppear {
            if mediaType == .photo {
                loadImage()
            }
        }
    }
    
    private func loadImage() {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = UIImage(contentsOfFile: url.path)
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}

struct MediaLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        MediaLibraryView()
    }
} 