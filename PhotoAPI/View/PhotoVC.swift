//
//  PhotoVC.swift
//  PhotoAPI
//
//  Created by Manish Parihar on 27.09.23.
//

import SwiftUI



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

