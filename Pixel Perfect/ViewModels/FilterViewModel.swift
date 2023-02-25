//
//  FilterViewModel.swift
//  Pixel Perfect
//
//  Created by Onur Ural on 6.02.2023.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

@MainActor class FilterViewModel: ObservableObject {
    @Published var image = Image("Example")
    @Published var filterIntensity = 0.5
    @Published var inputImage: UIImage?
    @Published var showImagePicker = false
    @Published var currentFilter: CIFilter?
    
    let context = CIContext()
    
    public func loadImage() {
        guard let inputImage = inputImage else { return }
        guard var beginImage = CIImage(image: inputImage) else { return }
        
        let orientation = inputImage.imageOrientation
        
        switch orientation {
        case .up :
            beginImage = beginImage.oriented(.up)
        case .right:
            beginImage = beginImage.oriented(.right)
        case .left:
            beginImage = beginImage.oriented(.up)
        case .down:
            beginImage = beginImage.oriented(.up)
        case .upMirrored:
            beginImage = beginImage.oriented(.up)
        case .downMirrored:
            beginImage = beginImage.oriented(.up)
        case .leftMirrored:
            beginImage = beginImage.oriented(.up)
        case .rightMirrored:
            beginImage = beginImage.oriented(.up)
        @unknown default:
            beginImage = beginImage.oriented(.up)
        }
        
        
        guard let currentFilter = currentFilter else {
            if let cgimg = context.createCGImage(beginImage, from: beginImage.extent) {
                let uiImage = UIImage(cgImage: cgimg)
                
                image = Image(uiImage: uiImage)
            }
            return
        }
        
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        guard let outputImage: CIImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            
            image = Image(uiImage: uiImage)
        }
    }
    
    public func applyProcessing() {
        guard let currentFilter = currentFilter else { return }
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) && currentFilter.name == "CISepiaTone" {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) && inputKeys.contains(kCIInputIntensityKey) && currentFilter.name == "CIUnsharpMask" {
            currentFilter.setValue(filterIntensity * 5.0, forKey: kCIInputIntensityKey)
            currentFilter.setValue(filterIntensity * 2.0, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey) && inputKeys.contains(kCIInputIntensityKey) && currentFilter.name == "CIGloom" {
            currentFilter.setValue(filterIntensity * 5.0, forKey: kCIInputIntensityKey)
            currentFilter.setValue(filterIntensity * 2.0, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputSaturationKey) && inputKeys.contains(kCIInputContrastKey) && inputKeys.contains(kCIInputBrightnessKey) && currentFilter.name == "CIColorControls"{
            currentFilter.setValue(filterIntensity * 0.5, forKey: ColorAdjustment.Saturation.rawValue)
            currentFilter.setValue(filterIntensity * 0.5, forKey: ColorAdjustment.Brightness.rawValue)
            currentFilter.setValue(filterIntensity * 1.5, forKey: ColorAdjustment.Contrast.rawValue)
        }
        
        if inputKeys.contains(kCIInputEVKey) && currentFilter.name == "CIExposureAdjust"{
            currentFilter.setValue(filterIntensity, forKey: kCIInputEVKey)
        }
        
        
        loadImage()
    }
    
    public func setFilter(_ filter: Filters) {
        
        switch filter {
        case .Sepia_Tone:
            currentFilter = CIFilter.sepiaTone()
        case .UnSharpMask:
            currentFilter = CIFilter.unsharpMask()
        case .CIColorControls:
            currentFilter = CIFilter.colorControls()
        case .Exposure:
            currentFilter = CIFilter.exposureAdjust()
        case .Gloom:
            currentFilter = CIFilter.gloom()
        case .AcneRemover:
            removeAcne()
        case .AutoEnhancement:
            autoEnhancement()
        }
        applyProcessing()
    }
    
    public func autoEnhancement() {
        guard let inputImage = inputImage else { return }
        guard var beginImage = CIImage(image: inputImage) else { return }
        
        
        let filters: [CIFilter] = beginImage.autoAdjustmentFilters()
        
        
        
        for filter in filters {
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            guard let outputImage = filter.outputImage else { return }
            beginImage = outputImage
        }
        
        let orientation = inputImage.imageOrientation
        
        switch orientation {
        case .up :
            beginImage = beginImage.oriented(.up)
        case .right:
            beginImage = beginImage.oriented(.right)
        case .left:
            beginImage = beginImage.oriented(.up)
        case .down:
            beginImage = beginImage.oriented(.up)
        case .upMirrored:
            beginImage = beginImage.oriented(.up)
        case .downMirrored:
            beginImage = beginImage.oriented(.up)
        case .leftMirrored:
            beginImage = beginImage.oriented(.up)
        case .rightMirrored:
            beginImage = beginImage.oriented(.up)
        @unknown default:
            beginImage = beginImage.oriented(.up)
        }
        
        
        if let cgimg = context.createCGImage(beginImage, from: beginImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            
            image = Image(uiImage: uiImage)
        }
    }
    
    public func removeAcne() {
        guard let inputImage = inputImage else { return }
        guard var beginImage = CIImage(image: inputImage) else { return }
        
        let maskGenerator = CIFilter(name: "CISmoothLinearGradient",
                                    parameters: [
                                        "inputPoint0": CIVector(x: beginImage.extent.midX, y: beginImage.extent.midY + 100),
                                        "inputPoint1": CIVector(x: beginImage.extent.midX, y: beginImage.extent.midY - 100),
                                        "inputColor0": CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                                        "inputColor1": CIColor(red: 0, green: 0, blue: 0, alpha: 0)
                                    ])
        
        let mask = maskGenerator?.outputImage
        
        guard let acneRemover = CIFilter(name: "CIBlendWithMask", parameters: [
            kCIInputImageKey: inputImage,
            kCIInputMaskImageKey: mask!
        ]) else { return }
        
        guard let outputImage: CIImage = acneRemover.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            
            image = Image(uiImage: uiImage)
        }
        
    }
    
    
    public func detectFaces() {
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context)
        
        guard let inputImage = inputImage else { return }
        guard let beginImage = CIImage(image: inputImage) else { return }
        
        let oriantation = [CIDetectorImageOrientation: 1 ]
        //        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        
        guard let faces = detector?.features(in: beginImage, options: oriantation) else { return }
        
        
        for face in faces as! [CIFaceFeature] {
            print(face.hasSmile)
            
        }
    }
}

