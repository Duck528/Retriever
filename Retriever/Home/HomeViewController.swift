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
    // 좌측 필터링 섹션
    @IBOutlet weak var searchWordTextField: NSTextField!
    @IBOutlet weak var filterTagCollectionView: NSCollectionView!
    @IBOutlet weak var wordCollectionView: NSCollectionView!
    @IBOutlet weak var wordCollectionScrollView: NSScrollView!
    
    // 사용자로부터 Word가 입력되는 컨트롤 모음
    @IBOutlet weak var inputTagTextField: NSTextField!
    @IBOutlet weak var wordTextField: NSTextField!
    @IBOutlet weak var meanTextField: NSTextField!
    @IBOutlet weak var additionalInfoTextView: NSTextView!
    @IBOutlet weak var difficultyPopUpButton: NSPopUpButton!
    @IBOutlet weak var inputTagCollectionView: NSCollectionView!
    @IBOutlet weak var inputTagSectionView: NSView!
    
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
    
    // 난이도 필터 옵션
    @IBOutlet weak var easyDifficultyCheckBox: NSButton!
    @IBOutlet weak var mediumDifficultyCheckBox: NSButton!
    @IBOutlet weak var hardDifficultyCheckBox: NSButton!
    @IBOutlet weak var undefinedDifficultyCheckBox: NSButton!
    
    let statusDashboardHeight: CGFloat = 30
    
    let viewModel: HomeViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        wordCollectionView.collectionViewLayout?.invalidateLayout()
    }
    
    @IBAction func difficultyPopYpButtonItemChanged(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        viewModel.difficulty.accept(index)
    }
    
    @IBAction func inputTagTextFieldReturnKeyEntered(_ sender: NSTextField) {
        viewModel.inputTagReturnKeyEntered()
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
        view.wantsLayer = true
        statusDashboardView.wantsLayer = true
        statusDashboardView.layerContentsRedrawPolicy = .duringViewResize
        
        setupCollectionView()
        hideAppendWordSection()
        showAppendWordToolSection()
    }
    
    private func setupCollectionView() {
        filterTagCollectionView.backgroundColors = [.clear]
        filterTagCollectionView.register(
            TagItemCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("TagCell"))
        
        wordCollectionView.backgroundColors = [.clear]
        wordCollectionView.register(
            WordItemCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("WordCell"))
        
        inputTagCollectionView.register(
            TagItemCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("TagCell"))
    }
}

extension HomeViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        if collectionView == filterTagCollectionView {
            return calculateFilterTagCellSize(at: indexPath)
        } else if collectionView == wordCollectionView {
            return calculateWordCellSize(in: collectionView, at: indexPath)
        } else if collectionView == inputTagCollectionView {
            return calculateInputTagCellSize(at: indexPath)
        } else {
            return .zero
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard collectionView == wordCollectionView, let indexPath = indexPaths.first else {
            return
        }
        viewModel.selectWordToEdit(at: indexPath)
        wordCollectionView.deselectAll(nil)
    }
    
    private func calculateFilterTagCellSize(at indexPath: IndexPath) -> CGSize {
        let tagTitle = viewModel.allTags.value[indexPath.item].displayTagTitle.value
        let width = NSFont.helveticaNeueBold(size: 13)
            .size(text: tagTitle, constrainedToWidth: CGFloat.greatestFiniteMagnitude)
            .width + 30
        return CGSize(width: width, height: 20)
    }
    
    private func calculateInputTagCellSize(at indexPath: IndexPath) -> CGSize {
        let tagTitle = viewModel.wordTags.value[indexPath.item].displayTagTitle.value
        let width = NSFont.helveticaNeueBold(size: 13)
            .size(text: tagTitle, constrainedToWidth: CGFloat.greatestFiniteMagnitude)
            .width + 45
        return CGSize(width: width, height: 20)
    }
    
    private func calculateWordCellSize(in collectionView: NSCollectionView, at indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 99)
    }
}

extension HomeViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filterTagCollectionView {
            return numberOfFilterTagItems(in: section)
        } else if collectionView == wordCollectionView {
            return numberOfWordItems(in: section)
        } else if collectionView == inputTagCollectionView {
            return numberOfWordTagItems(in: section)
        } else {
            return 0
        }
    }
    
    private func numberOfFilterTagItems(in section: Int) -> Int {
        return viewModel.allTags.value.count
    }
    
    private func numberOfWordItems(in section: Int) -> Int {
        return viewModel.wordItems.value.count
    }
    
    private func numberOfWordTagItems(in section: Int) -> Int {
        return viewModel.wordTags.value.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if collectionView == filterTagCollectionView {
            return configureFilterTagItem(collectionView, at: indexPath)
        } else if collectionView == wordCollectionView {
            return configureWordItem(collectionView, at: indexPath)
        } else if collectionView == inputTagCollectionView {
            return configureWordTagItem(collectionView, at: indexPath)
        } else {
            return NSCollectionViewItem()
        }
    }
    
    private func configureFilterTagItem(_ collectionView: NSCollectionView, at indexPath: IndexPath) -> NSCollectionViewItem {
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
    
    private func configureWordTagItem(_ collectionView: NSCollectionView, at indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TagCell"),
            for: indexPath) as? TagItemCell else {
                return NSCollectionViewItem()
        }
        let cellViewModel = viewModel.wordTags.value[indexPath.item]
        item.bind(to: cellViewModel)
        return item
    }
}

extension HomeViewController {
    func bindViewModel() {
        bindViewAction()
        bindDifficultyFilterOptions()
        bindSearchToWord()
        bindTagCollectionView()
        bindInputTagSectionView()
        bindCancelAppendWordButton()
        bindPresentAppendWordSectionButton()
        bindSaveWordButton()
        bindWordTextField()
        bindMeanTextField()
        bindInputTagTextField()
        bindAdditionalInfoTextView()
        bindWordAppendableStatus()
        bindLatestSyncTime()
        bindEditWordToolSection()
        bindBottomStatusDashboardSection()
    }
    
    private func bindViewAction() {
        viewModel.viewAction
            .observeOn(MainScheduler.instance)
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
                case .updateDiffculty(let difficulty):
                    self.difficultyPopUpButton.title = difficulty.title
                case .clearInputTagText:
                    self.inputTagTextField.stringValue = ""
                case .scrollToWord(let indexPath):
                    self.wordCollectionView.scrollToItems(at: [indexPath], scrollPosition: .bottom)
                case .reloadWordItems:
                    self.wordCollectionView.reloadData()
                }
            }).disposed(by: disposeBag)
    }
    
    private func hideAppendWordSection() {
        wordCollectionScrollView.contentInsets.bottom = 0
        appendWordSectionView.findConstraint(for: .bottom)?.constant = -appendWordSectionView.bounds.height
        presentAppendWordSectionView.findConstraint(for: .bottom)?.constant = 0
        difficultyPopUpButton.selectItem(at: 0)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    private func showAppendWordSection() {
        wordCollectionScrollView.contentInsets.bottom = 370
        appendWordSectionView.findConstraint(for: .bottom)?.constant = 0
        presentAppendWordSectionView.findConstraint(for: .bottom)?.constant = -presentAppendWordSectionView.bounds.height
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    private func showAppendWordToolSection() {
        editWordToolSection.isHidden = true
        appendWordToolSection.isHidden = false
    }
    
    private func showEditWordToolSection() {
        editWordToolSection.isHidden = false
        appendWordToolSection.isHidden = true
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
                self.filterTagCollectionView.reloadData()
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
    
    private func bindDifficultyFilterOptions() {
        easyDifficultyCheckBox.rx.state
            .map { $0.rawValue == 1 ? true : false  }
            .bind(to: viewModel.easyDifficultyChecked)
            .disposed(by: disposeBag)
        
        mediumDifficultyCheckBox.rx.state
            .map { $0.rawValue == 1 ? true : false  }
            .bind(to: viewModel.mediumDifficultyChecked)
            .disposed(by: disposeBag)
        
        hardDifficultyCheckBox.rx.state
            .map { $0.rawValue == 1 ? true : false  }
            .bind(to: viewModel.hardDifficultyChecked)
            .disposed(by: disposeBag)
        
        undefinedDifficultyCheckBox.rx.state
            .map { $0.rawValue == 1 ? true : false  }
            .bind(to: viewModel.undefinedDifficultyChecked)
            .disposed(by: disposeBag)
        
        viewModel.easyDifficultyChecked
            .map { $0 ? NSControl.StateValue.on : NSControl.StateValue.off }
            .bind(to: easyDifficultyCheckBox.rx.state)
            .disposed(by: disposeBag)
        
        viewModel.mediumDifficultyChecked
            .map { $0 ? NSControl.StateValue.on : NSControl.StateValue.off }
            .bind(to: mediumDifficultyCheckBox.rx.state)
            .disposed(by: disposeBag)
        
        viewModel.hardDifficultyChecked
            .map { $0 ? NSControl.StateValue.on : NSControl.StateValue.off }
            .bind(to: hardDifficultyCheckBox.rx.state)
            .disposed(by: disposeBag)
        
        viewModel.undefinedDifficultyChecked
            .map { $0 ? NSControl.StateValue.on : NSControl.StateValue.off }
            .bind(to: undefinedDifficultyCheckBox.rx.state)
            .disposed(by: disposeBag)
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
    
    private func bindInputTagTextField() {
        // Two-Way 바인딩
        inputTagTextField.rx.text
            .filterOptional()
            .bind(to: viewModel.tagText)
            .disposed(by: disposeBag)
        
        viewModel.wordTags
            .map { $0.count }
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.inputTagCollectionView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func bindInputTagSectionView() {
        viewModel.wordTags
            .map { $0.count > 0 }
            .map { $0 == true ? 70 : 0  }
            .subscribe(onNext: {
                self.inputTagSectionView.findConstraint(for: .height)?.constant = $0
            }).disposed(by: disposeBag)
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
            .observeOn(MainScheduler.instance)
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
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    private func showStatusDashboard() {
        statusDashboardView.findConstraint(for: .height)?.constant = statusDashboardHeight
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            self.view.layoutSubtreeIfNeeded()
        }
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
