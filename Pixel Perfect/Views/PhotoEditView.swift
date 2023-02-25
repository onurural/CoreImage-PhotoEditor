//
//  ContentView.swift
//  Pixel Perfect
//
//  Created by Onur Ural on 5.02.2023.
//

import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct PhotoEditView: View {
    @StateObject private var filterViewModel = FilterViewModel()
    
    @State private var image = Image(systemName: "Example")
    @State private var filterIntensity = 0.5
    
    @State private var inputImage: UIImage?
    @State private var showImagePicker = false
    
    @State private var currentFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    var body: some View {
        
        VStack{
            HStack {
                Button(action: {
                    save()
                },
                       label: {
                    Text("Save")
                })
                Spacer()
                Button(
                    action: {
                        filterViewModel.showImagePicker = true
                    },
                    label: {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                        }
                    })
            }
            .padding(.all)
            Spacer()
            filterViewModel.image
                .resizable()
                .scaledToFit()
            Spacer()
            HStack {
                Text("Intensity")
                Slider(value: $filterViewModel.filterIntensity, in: 0.1...1.0)
                    .onChange(of: filterViewModel.filterIntensity) { _ in
                        filterViewModel.applyProcessing()
                    }
            }
            .padding(.all)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Filters.allCases, id: \.self) {filter in
                        Button(action: {
                            filterViewModel.setFilter(filter)
                        }, label: {
                            VStack {
                                Image(systemName: "camera.filters")
                                Text("\(filter.rawValue)")
                            }
                        })
                    }
                    Button(action: {
                        filterViewModel.detectFaces()
                    }, label: {
                        VStack {
                            Image(systemName: "camera.filters")
                            Text("Face Detection")
                        }
                    })
                }
                
            }
            .padding(.all)
            Spacer()
        }
        .sheet(isPresented: $filterViewModel.showImagePicker) {
            ImagePicker(image: $filterViewModel.inputImage)
        }
        .onChange(of: filterViewModel.inputImage) {_ in
            filterViewModel.loadImage()
            
        }
    }
    
    private func save() {
        
    }
}
struct PhotoEditView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoEditView()
    }
}
