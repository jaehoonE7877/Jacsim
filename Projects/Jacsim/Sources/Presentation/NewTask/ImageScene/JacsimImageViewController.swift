//
//  JacsimImageViewController.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//
import Photos
import PhotosUI
import UIKit

import Core
import DSKit

import CropViewController
import RxSwift
import RxCocoa
import SnapKit
import Then

final class JacsimImageViewController: BaseViewController {
    
    private let titleLabel: UILabel = .init().then {
        $0.attributedText = "작심의 대표 이미지를 정해주세요".heading3(color: .labelStrong)
    }
    
    private let mainImageView: UIImageView = .init().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 6
        $0.image = DSKitAsset.Assets.thumbnail.image
        $0.isUserInteractionEnabled = true
    }
    
    private let imageButton: UIButton = .init(type: .system).then {
        $0.showsMenuAsPrimaryAction = true
    }
    
    private let nextButton = PrimaryButton(state: .disable,
                                           disableTouchWhenDisabled: true).then {
        $0.setAttributedTitle("다음".body1(color: .labelNormal, alignment: .center), for: .normal)
        $0.setAttributedTitle("다음".body1(color: .labelDisable, alignment: .center), for: .disabled)
    }
    
    private var imageSourceMenu: UIMenu {
        let actions = ImageSource.allCases.map { source -> UIAction in                   
            UIAction(title: source.title, image: source.thumbnail) { [weak self] _ in
            self?.imageSourceSelectRelay.accept(source)
        }}
        return UIMenu(title: "대표 사진의 경로를 정해주세요", options: .displayInline, children: actions)
    }
    
    private let viewModel: JacsimImageViewModel
    
    private let imageSourceSelectRelay: PublishRelay<ImageSource> = .init()
    
    private let imageSelectRelay: PublishRelay<UIImage> = .init()
    //MARK: - initializer
    init(viewModel: JacsimImageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        bind()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        self.imageButton.menu = self.imageSourceMenu
    }
    
    override func setNavigationController() {
        super.setNavigationController()
        setBackButton(type: .pop)
    }
    
    private func bind() {
        
        let input = JacsimImageViewModel.Input(imageSourceSelected: imageSourceSelectRelay.asObservable(),
                                               imageSelected: imageSelectRelay.asObservable())
        let output = self.viewModel.transform(input: input)
        
        output.showImagePicker
            .drive(with: self, onNext: { _self, _ in
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = _self
                _self.present(picker, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.showPhPicker
            .drive(with: self) { _self, _ in
                var config = PHPickerConfiguration()
                config.filter = .images
                config.selectionLimit = 1
                let picker = PHPickerViewController(configuration: config)
                picker.delegate = _self
                _self.present(picker, animated: true)
            }
            .disposed(by: disposeBag)
            
        output.nextButtonValid
            .drive(with: self, onNext: { _self, valid in
                _self.mainImageView.image = _self.viewModel.mainImage
                _self.nextButton.buttonState = valid ? .enable : .disable
            })
            .disposed(by: disposeBag)
    }
    
}

    //MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension JacsimImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let style = CropViewCroppingStyle.default
            let cropVC = CropViewController(croppingStyle: style, image: image)
            cropVC.delegate = self
            self.present(cropVC, animated: true)
        }
    }
}

    //MARK: - PHPickerViewControllerDelegate

extension JacsimImageViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        func errorHandle() {
            self.showAlertMessage(title: "지원하지 않는 형식의 파일입니다.", message: "다른 파일을 선택해 주세요", button: "확인")
        }
        
        func handleLoadedImage(_ image: UIImage) {
            DispatchQueue.main.async {
                let style = CropViewCroppingStyle.default
                let cropVC = CropViewController(croppingStyle: style, image: image)
                cropVC.delegate = self
                cropVC.doneButtonTitle = "완료"
                cropVC.cancelButtonTitle = "취소"
                self.present(cropVC, animated: true)
            }
        }
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self else { return }
                guard let image = image as? UIImage else {
                    errorHandle()
                    return
                }
                handleLoadedImage(image)
            }
        } else {
            guard let itemProvider else { return }
            itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { url, _ in
                if let url = url,
                   let data = NSData(contentsOf: url),
                   let source = CGImageSourceCreateWithData(data, nil),
                   let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
                    let image = UIImage(cgImage: cgImage)
                    handleLoadedImage(image)
                }
            }
        }
    }
}

    //MARK: - CropViewControllerDelegate

extension JacsimImageViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        dismiss(animated: true)
        let width = CGFloat.screenWidth - 32
        let resizeImage = image.resizeImage(CGFloat(width), opaque: true, contentMode: .scaleAspectFit)
        self.imageSelectRelay.accept(resizeImage)
    }
}

extension JacsimImageViewController {
    
    private func setView() {
        self.view.addSubviews([titleLabel, mainImageView, nextButton])
        
        mainImageView.addSubview(imageButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        mainImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(mainImageView.snp.width)
        }
        
        imageButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
