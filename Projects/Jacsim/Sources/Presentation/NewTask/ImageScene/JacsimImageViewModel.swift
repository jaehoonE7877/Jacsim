//
//  JacsimImageViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation
import Photos

import DSKit

import RxCocoa
import RxSwift
import UIKit

final class JacsimImageViewModel {
    
    private let _mainImage: BehaviorRelay<Data>
    private(set) var mainImage = UIImage()
    
    private let toastMessageRelay: PublishRelay<String> = .init()
    private let alertMessageRelay: PublishRelay<String> = .init()
    private let disposeBag = DisposeBag()
    
    init(jacsim: UserJacsimDTO) {
        self._mainImage = .init(value: jacsim.mainImage)
    }
    
    struct Input {
        let imageSourceSelected: Observable<ImageSource>
        let imageSelected: Observable<UIImage>
    }
    
    struct Output {
        let showImagePicker: Driver<Void>
        let showPhPicker: Driver<Void>
        let nextButtonValid: Driver<Bool>
        let toastMessage: Driver<String>
        let alertMessage: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        
        let showImagePicker = input.imageSourceSelected
            .filter { $0 == .camera }
            .filter { [weak self] _ -> Bool in
                guard let self else { return false }
                return self.checkCameraAuthorization()
            }
            .mapToVoid()
        
        let showPhPicker = input.imageSourceSelected
            .filter { $0 == .album }
            .mapToVoid()
        
        let nextButtonValid = input.imageSelected
            .do(onNext: { [weak self] image in
                self?.mainImage = image
            })
            .map { $0.compressTo(800) }
            .filterNil()
            .map { [weak self] data -> Bool in
                self?._mainImage.accept(data)
                return data.count >= 0
            }
        
        return Output(showImagePicker: showImagePicker.asDriverOnErrorWithNever(),
                      showPhPicker: showPhPicker.asDriverOnErrorWithNever(),
                      nextButtonValid: nextButtonValid.asDriverOnErrorWithNever(),
                      toastMessage: toastMessageRelay.asDriverOnErrorWithNever(),
                      alertMessage: alertMessageRelay.asDriverOnErrorWithNever())
    }
    
    private func checkCameraAuthorization() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                toastMessageRelay.accept("카메라 사용이 불가합니다")
                return false
            }
            return true
        case .notDetermined:
            var valid: Bool = false
            AVCaptureDevice.requestAccess(for: .video) { granted in
                valid = granted
            }
            return valid
        default:
            alertMessageRelay.accept("작심이(가) 카메라 접근 허용되어 있지 않습니다. \r\n 설정화면으로 가시겠습니까?")
            return false
        }
    }
}
