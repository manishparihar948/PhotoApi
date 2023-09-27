//
//  PhotoVC.swift
//  PhotoAPI
//
//  Created by Manish Parihar on 27.09.23.
//

import SwiftUI
import Foundation
import Combine


struct PhotoApi: Codable {
    let success:Bool
    let total_photos: Int
    let message: String
    let offset: Int
    let limit: Int
    let photos: [Photo]
}


struct Photo: Codable, Identifiable {
    let description:String?
    let url : String?
    let title:String?
    let id, user: Int?
}

@MainActor
final class PhotoViewModel: ObservableObject {
    
    @Published var photoApi: PhotoApi
    var cancellables = Set<AnyCancellable>()
    
    var offset = 0
    let batchSize = 10
    
    init(){
        self.photoApi = PhotoApi(success: false, total_photos: 0, message: "", offset: 0, limit: 0, photos: [])

        getPhotos(limit: 10)
    }
    
    func getPhotos(limit:Int) {
        print("Getting photos...")
        
        //guard let url = URL(string: "https://api.slingacademy.com/v1/sample-data/photos")
        guard let url = URL(string: "https://api.slingacademy.com/v1/sample-data/photos?offset=5&limit=20")
        else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .tryMap(handleOutput)
            .decode(type: PhotoApi.self, decoder: JSONDecoder())
            //.replaceError(with:nil)
            .mapError { 
                error -> Never in
                        fatalError("Unhandled error: \(error)")
            }
            .sink( receiveValue: {[weak self](returnedPhotos) in
                self?.photoApi = returnedPhotos
                
                // Increment the offset for the next batch
                self?.offset += self?.batchSize ?? 0
            })
            .store(in: &cancellables)
    }
    
    func handleOutput(output:URLSession.DataTaskPublisher.Output) throws -> Data {
        guard
            let response = output.response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        return output.data
    }
    
    
}


struct PhotoVC: View {
    
    @StateObject private var viewModel = PhotoViewModel()
    var initialLimit = 10
    var batchLimit = 20
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.photoApi.photos) { photo in
                    HStack {
                        if let imageUrl = photo.url {
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let returnedImage):
                                    returnedImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                case .failure:
                                    Image(systemName: "questionmark")
                                        .font(.headline)
                                default:
                                    Image(systemName: "questionmark")
                                        .font(.headline)
                                }
                            }
                        }
                        
                        VStack {
                            // Title
                            if let title = photo.title {
                                Text(title)
                                    .font(.headline)
                                    .foregroundStyle(Color.blue)
                                    .padding(.top)
                            }
                            Spacer()
                        }
                    }
                }
                .onAppear{
                    // Check the user reached the end of the current list
                    if viewModel.photoApi.photos.count - 1 == viewModel.offset {
                        // Load the next batch of images
                        viewModel.getPhotos(limit: batchLimit)
                    }
                }
            }
            .onAppear{
                // Load the initial batch with the initil limit
                    viewModel.getPhotos(limit: initialLimit)
            }
            .navigationTitle("Show Photos")

        }
    }
}

#Preview {
    PhotoVC()
}

