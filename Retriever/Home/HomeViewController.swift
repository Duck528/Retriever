//
//  HomeViewController.swift
//  Retriever
//
//  Created by thekan on 24/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import AppKit
import RxCocoa
import RxSwift

class HomeViewController: NSViewController {
    
    @IBOutlet weak var searchWordTextField: NSTextField!
    @IBOutlet weak var tagCollectionView: NSCollectionView!
    @IBOutlet weak var wordCollectionView: NSCollectionView!
    @IBOutlet weak var wordCollectionScrollView: NSScrollView!
    
    // 사용자로부터 Word가 입력되는 컨트롤 모음
    @IBOutlet weak var wordTextField: NSTextField!
    @IBOutlet weak var meanTextField: NSTextField!
    @IBOutlet weak var additionalInfoTextView: NSTextView!
    @IBOutlet weak var difficultyPopUpButton: NSPopUpButton!
    
    // Append Word Section
    @IBOutlet weak var appendWordSectionView: NSView!
    @IBOutlet weak var cancelAppendWordButton: NSButton!
    @IBOutlet weak var appendWordButton: NSButton!
    @IBOutlet weak var appendWordContinouslyButton: NSButton!
    @IBOutlet weak var appendWordToolSection: NSView!
    
    // Edit Word Section
    @IBOutlet weak var cancelEditWordButton: NSButton!
    @IBOutlet weak var updateWordButton: NSButton!
    @IBOutlet weak var deleteWordButton: NSButton!
    @IBOutlet weak var editWordToolSection: NSView!
    
    // 우측 하단 + 버튼
    @IBOutlet weak var presentAppendWordSectionView: NSView!
    @IBOutlet weak var presentAppendWordSectionButton: NSButton!
    
    // 하단 상태 대시보드
    @IBOutlet weak var statusDashboardView: NSView!
    @IBOutlet weak var needSyncronizeView: NSView!
    @IBOutlet weak var synchronizeWordButton: NSButton!
    @IBOutlet weak var syncProgressView: NSView!
    @IBOutlet weak var offlineStatusView: NSView!
    @IBOutlet weak var syncCompletedView: NSView!
    
    // 최근 동기화 상태 표시 섹션
    @IBOutlet weak var syncAnimationView: NSView!
    @IBOutlet weak var latestSyncTimeLabel: NSTextField!
    @IBOutlet weak var updateLatestSyncTimeButton: NSButton!
    
    let statusDashboardHeight: CGFloat = 30
    
    let viewModel: HomeViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    @IBAction func difficultyPopYpButtonItemChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        viewModel.difficulty.accept(index)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        viewModel = Assembler().resolve()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = Assembler().resolve()
        super.init(coder: coder)
    }
}

extension HomeViewController {
    private func setupViews() {
        setupCollectionView()
        hideAppendWordSection()
        showAppendWordToolSection()
    }
    
    private func setupCollectionView() {
        tagCollectionView.backgroundColors = [.clear]
        tagCollectionView.register(
            TagItemCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("TagCell"))
        
        wordCollectionView.backgroundColors = [.clear]
        wordCollectionView.register(
            WordItemCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("WordCell"))
    }
}

extension HomeViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        if collectionView == tagCollectionView {
            return calculateTagCellSize(at: indexPath)
        } else if collectionView == wordCollectionView {
            return calculateWordCellSize(in: collectionView, at: indexPath)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard collectionView == wordCollectionView, let indexPath = indexPaths.first else {
            return
        }
        viewModel.selectWordToEdit(at: indexPath)
    }
    
    private func calculateTagCellSize(at indexPath: IndexPath) -> CGSize {
        let tagTitle = viewModel.allTags.value[indexPath.item].tagItem.value.title
        let width = NSFont.helveticaNeueBold(size: 13)
            .size(text: tagTitle, constrainedToWidth: CGFloat.greatestFiniteMagnitude)
            .width + 25
        return CGSize(width: width, height: 20)
    }
    
    private func calculateWordCellSize(in collectionView: NSCollectionView, at indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 77)
    }
}

extension HomeViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagCollectionView {
            return numberOfTagItems(in: section)
        } else if collectionView == wordCollectionView {
            return numberOfWordItems(in: section)
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if collectionView == tagCollectionView {
            return configureTagItem(collectionView, at: indexPath)
        } else if collectionView == wordCollectionView {
            return configureWordItem(collectionView, at: indexPath)
        } else {
            return NSCollectionViewItem()
        }
    }
    
    private func numberOfTagItems(in section: Int) -> Int {
        return viewModel.allTags.value.count
    }
    
    private func numberOfWordItems(in section: Int) -> Int {
        return viewModel.wordItems.value.count
    }
    
    private func configureTagItem(_ collectionView: NSCollectionView, at indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TagCell"),
            for: indexPath) as? TagItemCell else {
                return NSCollectionViewItem()
        }
        let cellViewModel = viewModel.allTags.value[indexPath.item]
        item.bind(to: cellViewModel)
        return item
    }
    
    private func configureWordItem(_ collectionView: NSCollectionView, at indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("WordCell"),
            for: indexPath) as? WordItemCell else {
                return NSCollectionViewItem()
        }
        let cellViewModel = viewModel.wordItems.value[indexPath.item]
        item.bind(to: cellViewModel)
        return item
    }
}


extension HomeViewController {
    func bindViewModel() {
        bindViewAction()
        bindSearchToWord()
        bindTagCollectionView()
        bindWordCollectionView()
        bindCancelAppendWordButton()
        bindPresentAppendWordSectionButton()
        bindSaveWordButton()
        bindWordTextField()
        bindMeanTextField()
        bindAdditionalInfoTextView()
        bindWordAppendableStatus()
        bindLatestSyncTime()
        bindEditWordToolSection()
        bindBottomStatusDashboardSection()
    }
    
    private func bindViewAction() {
        viewModel.viewAction
            .subscribe(onNext: {
                switch $0 {
                case .hideAppendWordSection:
                    self.hideAppendWordSection()
                case .showAppendWordSection:
                    self.showAppendWordSection()
                case .updateWordAppendMode:
                    self.showAppendWordToolSection()
                case .updateWordEditMode:
                    self.showEditWordToolSection()
                case .reloadWordAtIndex(let indexPath):
                    self.wordCollectionView.reloadItems(at: [indexPath])
                }
            }).disposed(by: disposeBag)
    }
    
    private func hideAppendWordSection() {
        wordCollectionScrollView.contentInsets.bottom = 0
        appendWordSectionView.findConstraint(for: .bottom)?.constant = -appendWordSectionView.bounds.height
        presentAppendWordSectionView.findConstraint(for: .bottom)?.constant = 0
    }
    
    private func showAppendWordSection() {
        wordCollectionScrollView.contentInsets.bottom = 300
        appendWordSectionView.findConstraint(for: .bottom)?.constant = 0
        presentAppendWordSectionView.findConstraint(for: .bottom)?.constant = -presentAppendWordSectionView.bounds.height
    }
    
    private func showAppendWordToolSection() {
        editWordToolSection.isHidden = true
        appendWordToolSection.isHidden = false
    }
    
    private func showEditWordToolSection() {
        editWordToolSection.isHidden = false
        appendWordToolSection.isHidden = true
    }
    
    private func bindWordCollectionView() {
        viewModel.wordItems
            .skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.wordCollectionView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func bindSearchToWord() {
        searchWordTextField.rx.text
            .filterOptional()
            .bind(to: viewModel.wordToSearch)
            .disposed(by: disposeBag)
    }
    
    private func bindTagCollectionView() {
        viewModel.allTags
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.tagCollectionView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func bindCancelAppendWordButton() {
        cancelAppendWordButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { 
                self.viewModel.cancelAppendWordButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    private func bindPresentAppendWordSectionButton() {
        presentAppendWordSectionButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.presentAppendWordButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    private func bindSaveWordButton() {
        appendWordButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.saveWordButtonTapped()
            }).disposed(by: disposeBag)
        
        appendWordContinouslyButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.saveWordContinouslyButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    private func bindWordTextField() {
        // Two-Way 바인딩
        wordTextField.rx.text
            .filterOptional()
            .bind(to: viewModel.wordText)
            .disposed(by: disposeBag)
        
        viewModel.wordText
            .bind(to: wordTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func bindMeanTextField() {
        // Two-Way 바인딩
        meanTextField.rx.text
            .filterOptional()
            .bind(to: viewModel.meanText)
            .disposed(by: disposeBag)
        
        viewModel.meanText
            .bind(to: meanTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func bindAdditionalInfoTextView() {
        // Two-Way 바인딩
        additionalInfoTextView.rx.string
            .bind(to: viewModel.additionalInfoText)
            .disposed(by: disposeBag)
        
        viewModel.additionalInfoText
            .bind(to: additionalInfoTextView.rx.string)
            .disposed(by: disposeBag)
    }
    
    private func bindWordAppendableStatus() {
        viewModel.wordAppendable
            .subscribe(onNext: { appendable in
                self.appendWordButton.isEnabled = appendable
                self.appendWordContinouslyButton.isEnabled = appendable
                self.updateWordButton.isEnabled = appendable
            }).disposed(by: disposeBag)
    }
    
    private func bindEditWordToolSection() {
        cancelEditWordButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.cancelEditWordButtonTapped()
            }).disposed(by: disposeBag)
        
        deleteWordButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.deleteSelectedWordButtonTapped()
            }).disposed(by: disposeBag)
        
        updateWordButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.updateSelectedWordButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    private func bindLatestSyncTime() {
        viewModel.latestSyncTime
            .map { $0?.offsetFromCurrentDate() ?? "기록없음" }
            .bind(to: latestSyncTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        updateLatestSyncTimeButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.syncButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    private func bindBottomStatusDashboardSection() {
        synchronizeWordButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.syncButtonTapped()
            }).disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                viewModel.internetConnected.skip(1),
                viewModel.syncStatus.skip(1))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { internetConnected, syncStatus in
                guard internetConnected else {
                    self.showStatusDashboard()
                    self.showOfflineStatusToDashboard()
                    return
                }
                
                switch syncStatus {
                case .stable:
                    self.showSyncCompletedStatusToDashboard()
                    self.hideStatusDashboard()
                case .progress:
                    self.showSyncProgressStatusToDashboard()
                    self.showStatusDashboard()
                case .unSynced:
                    self.showUnSyncedStatusToDashboard()
                    self.showStatusDashboard()
                }
            }).disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                viewModel.numberOfUpdatedWords.skip(1),
                viewModel.numberOfDeletedWords.skip(1))
            .distinctUntilChanged({ before, after -> Bool in
                if before.0 == after.0 && before.1 == after.1 {
                    return true
                } else {
                    return false
                }
            }).map { numberOfUpdated, numberOfDeleted in
                "동기화 하시려면 여기를 눌러주세요 (업데이트: \(numberOfUpdated), 삭제: \(numberOfDeleted))"
            }.observeOn(MainScheduler.instance)
            .subscribe(onNext: { buttonTitle in
                self.synchronizeWordButton.title = buttonTitle
            }).disposed(by: disposeBag)
    }
    
    private func hideStatusDashboard() {
        statusDashboardView.findConstraint(for: .height)?.constant = 0
    }
    
    private func showStatusDashboard() {
        statusDashboardView.findConstraint(for: .height)?.constant = statusDashboardHeight
    }
    
    private func showOfflineStatusToDashboard() {
        offlineStatusView.isHidden = false
        needSyncronizeView.isHidden = true
        syncProgressView.isHidden = true
        syncCompletedView.isHidden = true
    }
    
    private func showUnSyncedStatusToDashboard() {
        needSyncronizeView.isHidden = false
        offlineStatusView.isHidden = true
        syncProgressView.isHidden = true
        syncCompletedView.isHidden = true
    }
    
    private func showSyncProgressStatusToDashboard() {
        syncProgressView.isHidden = false
        needSyncronizeView.isHidden = true
        offlineStatusView.isHidden = true
        syncCompletedView.isHidden = true
    }
    
    private func showSyncCompletedStatusToDashboard() {
        syncCompletedView.isHidden = false
        syncProgressView.isHidden = true
        needSyncronizeView.isHidden = true
        offlineStatusView.isHidden = true
    }
}
