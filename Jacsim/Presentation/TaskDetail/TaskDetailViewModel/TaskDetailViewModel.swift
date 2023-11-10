//
//  TaskDetailViewModel.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/10/14.
//

import Foundation

import RxCocoa
import RxSwift

final class TaskDetailViewModel {
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let fetchSuccess: Driver<UserJacsim>
        let jacsimSuccess: Driver<String>
        let jacsimDelete: Driver<Void>
        let jacsimAlarm: Driver<String>
    }
    //MARK: -- Private Property
    private(set) var jacsimTask: BehaviorRelay<UserJacsim>
    private let jacsimSuccessRelay: PublishRelay<String> = .init()
    private let jacsimAlarm: PublishRelay<String> = .init()
    private let disposeBag: DisposeBag = .init()
    //MARK: - Dependecy
    private let documentManager: DocumentManager
    private let repository: JacsimRepository
    
    init(jacsimTask: UserJacsim, repository: JacsimRepository = JacsimRepository.shared, doucumentManager: DocumentManager = DocumentManager.shared) {
        self.jacsimTask.accept(jacsimTask)
        self.repository = repository
        self.documentManager = doucumentManager
    }
    
    //MARK: -- Action
    var jacsimDeleteRelay: PublishRelay<Void> = .init()
    var alarmDeleteRelay: PublishRelay<Void> = .init()
    
    func transform(input: Input) -> Output {
        let fetchSuccessRelay: PublishRelay<UserJacsim> = .init()
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.jacsimCertified()
                self.repository.checkIsSuccess(item: self.jacsimTask.value)
            })
            .disposed(by: disposeBag)
        
        jacsimTask
            .subscribe(onNext: { value in
                fetchSuccessRelay.accept(value)
            })
            .disposed(by: disposeBag)
        
        let jacsimDeleteDriver = jacsimDeleteRelay
            .flatMap { [weak self] _ -> Single<Void> in
                guard let self else { return Single.never() }
                return self.deleteJacsim()
            }
            .asDriver(onErrorDriveWith: .never())
        
        alarmDeleteRelay
            .subscribe(onNext: { [weak self] _ in
                self?.deleteAlarm()
            })
            .disposed(by: disposeBag)
            
        return Output(fetchSuccess: fetchSuccessRelay.asDriverOnErrorJustComplete(),
                      jacsimSuccess: jacsimSuccessRelay.asDriver(onErrorDriveWith: .never()),
                      jacsimDelete: jacsimDeleteDriver,
                      jacsimAlarm: jacsimAlarm.asDriver(onErrorDriveWith: .never()))
    }
    
    // collectionView cell개수
    func configCellTitle() -> [Date] {
        
        var dayArray: [Date] = []
        
        for date in stride(from: jacsimTask.value.startDate, to: (jacsimTask.value.endDate) + 86400, by: 86400 ){
            dayArray.append(date)
        }
        
        return dayArray
    }
    
}

extension TaskDetailViewModel {
    
    var showStartDate: String {
        return DateFormatType.toString(jacsimTask.value.startDate, to: .full)
    }
    
    var showEndDate: String {
        return DateFormatType.toString(jacsimTask.value.endDate, to: .full)
    }
    
    var showAlarm: String {
        if let alarm = jacsimTask.value.alarm {
            return DateFormatType.toString(alarm, to: .time)
        } else {
             return "설정된 알람이 없습니다."
        }
    }
    
    var loadMainImage: UIImage {
        return documentManager.loadImageFromDocument(fileName: "\(String(describing: jacsimTask.id)).jpg") ?? UIImage.jacsimImage
    }
    
    private func jacsimCertified() {
        if jacsimTask.value.success - repository.checkCertified(item: jacsimTask.value) > 0 {
            let message = "작심 성공까지 \(jacsimTask.value.success - repository.checkCertified(item: jacsimTask.value))회 남았습니다!"
            self.jacsimSuccessRelay.accept(message)
        } else {
            self.jacsimSuccessRelay.accept("목표를 달성했습니다! 끝까지 힘내세요!!")
        }
    }
    
    func checkIsToday(indexPath: IndexPath) -> Bool {
        
        let dayArray = configCellTitle()
        
        let dateText = DateFormatType.toString(dayArray[indexPath.item], to: .fullWithoutYear)
        
        return DateFormatType.toString(Date(), to: .fullWithoutYear) == dateText
    }
    
    var scrollToCurrentDate: Int {
        // 시작일이 오늘과 같거나, 다음 날이면 그대로 이후면 이후 날짜(순서 2번)를 왼쪽으로
        let now = Date()
        let dateArray = configCellTitle()
        var count = 0
        
        for index in 0...dateArray.count - 1 {
            if dateArray[index].year == now.year,
               dateArray[index].month == now.month,
               dateArray[index].day == now.day {
                count = index
            }
        }
        return count
    }
    
    func fetchTodayImage(index: Int) -> UIImage {
        let dayArray = configCellTitle()
        let dateText = DateFormatType.toString(dayArray[index], to: .fullWithoutYear)
        return documentManager.loadImageFromDocument(fileName: "\(jacsimTask.id)_\(dateText).jpg") ?? UIImage.jacsimImage
    }
    
    private func checkIsSuccess() {
        repository.checkIsSuccess(item: jacsimTask.value)
    }
    
    private func deleteAlarm() {
        repository.deleteAlarm(item: jacsimTask.value)
        if let alarm = jacsimTask.value.alarm {
            let alarmText = DateFormatType.toString(alarm, to: .time)
            self.jacsimAlarm.accept(alarmText)
        } else {
            self.jacsimAlarm.accept("설정된 알람이 없습니다.")
        }
    }
    
    private func deleteJacsim() -> Single<Void> {
        
        return Single.create { [weak self] single in
            guard let self else { return }
            if self.repository.checkCertified(item: jacsimTask.value) == 0 {
                self.repository.deleteJacsim(item: jacsimTask.value)
                single(.success(Void()))
                return Disposables.create()
            } else {
                // 인증이 있을 때
                let dayArray = configCellTitle()
                
                for index in 0...self.repository.checkCertified(item: jacsimTask.value) - 1 {
                    let dateText = DateFormatType.toString(dayArray[index], to: .fullWithoutYear)
                    self.repository.removeImageFromDocument(fileName: "\(jacsimTask.value.id)_\(dateText).jpg")
                }
                self.repository.deleteJacsim(item: jacsimTask.value)
                single(.success(Void()))
                return Disposables.create()
            }
        }
    }
}

//MARK: CollectionView
extension TaskDetailViewModel {
    
    func cellForItemAt(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskDetailCollectionViewCell.reuseIdentifier, for: indexPath) as? TaskDetailCollectionViewCell
        else { return UICollectionViewCell() }
        
        let dayArray = configCellTitle()
        
        let dateText = DateFormatType.toString(dayArray[indexPath.item], to: .fullWithoutYear)
        
        cell.dateLabel.text = dateText
        cell.certifiedMemo.text = jacsimTask.memoList[indexPath.row].memo
        
        guard let image = self.documentManager.loadImageFromDocument(fileName: "\(jacsimTask.id)_\(dateText).jpg") else { return UICollectionViewCell()}
        cell.certifiedImageView.image = image
        
        return cell
        
    }
    
}
