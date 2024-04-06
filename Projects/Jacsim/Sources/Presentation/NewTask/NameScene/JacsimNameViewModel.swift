//
//  JacsimNameViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 4/6/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import Foundation

import Core

import RxCocoa
import RxSwift

final class JacsimNameViewModel {
    
    private(set) var name: String
    private let disposeBag = DisposeBag()
    
    init(name: String = "") {
        self.name = name
    }
    
    struct Input {
        let jacsimTitleText: Observable<String>
        let nextButtonTap: Observable<Void>
    }
    
    struct Output {
        let nextButtonValidation: Driver<Bool>
        let showJacsimImageView: Driver<UserJacsimDTO>
        let textCount: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let buttonValidation: BehaviorRelay<Bool> = .init(value: false)
        let textCount: BehaviorRelay<String> = .init(value: self.name.count.toString())
        
        input.jacsimTitleText
            .subscribe(with: self) { _self, text in
                _self.name = text
                let trimmed = _self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                textCount.accept(trimmed.count.toString())
                buttonValidation.accept(trimmed.isNotEmpty)
            }
            .disposed(by: disposeBag)
        
        let showJacsimImageView = input.nextButtonTap
            .map { [weak self] _ -> UserJacsimDTO? in
                guard let self else { return nil }
                let title = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                return UserJacsimDTO(title: title)
            }
            .filterNil()
        
        return Output(nextButtonValidation: buttonValidation.asDriverOnErrorWithNever(),
                      showJacsimImageView: showJacsimImageView.asDriverOnErrorWithNever(),
                      textCount: textCount.asDriverOnErrorWithNever())
    }
}
