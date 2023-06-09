//
//  HomeViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/12.
//

import Foundation

import RxCocoa
import RxSwift

final class HomeViewModel {
    struct Input {
        let viewWillAppear: Observable<Void>
        let sortButtonTap: Observable<Void>
    }
    
    struct Output {
        let fetchSuccess: Driver<Void>
        
    }
    //MARK: - Dependency
    private let repository: JacsimRepository
    
    private(set) var jacsim: BehaviorRelay<[UserJacsim]> = .init(value: [])
    private let disposeBag = DisposeBag()
    //MARK: -- Initializer
    init(repository: JacsimRepository = JacsimRepository.shared) {
        self.repository = repository
    }
    
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                self?.checkIsDone()
                self?.fetch()
            })
            .disposed(by: disposeBag)
        
        let fetchSuccess = Observable.merge(jacsim.mapToVoid(), input.sortButtonTap)
        
        return Output(fetchSuccess: fetchSuccess.asDriver(onErrorDriveWith: .never()))
    }
}

extension HomeViewModel {
    
    private func fetch() {
        let task = Array(repository.fetchRealm())
        jacsim.accept(task)
    }
    
    func fetchDate(date: Date) {
        let task = Array(repository.fetchDate(date: date))
        jacsim.accept(task)
    }
    
    func checkIsDone() {
        repository.checkIsDone(items: jacsim.value)
    }
    
    func fetchIsNotDone() -> Int {
        return repository.fetchIsNotDone()
    }
    
}
