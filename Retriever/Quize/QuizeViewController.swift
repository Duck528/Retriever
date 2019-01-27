//
//  QuizeViewController.swift
//  Retriever
//
//  Created by thekan on 13/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import AppKit
import RxSwift

class QuizeViewController: NSViewController, BindableType {
    typealias ViewModelType = QuizeViewModel
    
    // 필터 뷰
    @IBOutlet weak var filterContainerView: NSView!
    
    // 전체 단어 수
    @IBOutlet weak var totalWordCountLabel: NSTextField!
    @IBOutlet weak var totalFilteredWordCountLabel: NSTextField!
    // 복습할 단어 수
    @IBOutlet weak var adjustedWordCountLabel: NSTextField!
    
    // 단어 필터 Show, Hide 버튼
    @IBOutlet weak var toggleWordFilterButton: NSButton!
    
    // 난이도 필터
    @IBOutlet weak var easyLevelFilterButton: NSButton!
    @IBOutlet weak var mediumLevelFilterButton: NSButton!
    @IBOutlet weak var difficultLevelFilterButton: NSButton!
    @IBOutlet weak var undefinedLevelFilterButton: NSButton!
    
    // 태그 필터
    @IBOutlet weak var tagCollectionView: NSCollectionView!
    
    private let disposeBag = DisposeBag()
    
    var viewModel: QuizeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    func bindViewModel() {
        bindTagCollectionView()
        bindToggleFilterButton()
        bindWordsCount()
        bindWordDifficultyLevel()
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

extension QuizeViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tags.value.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let identifier = NSUserInterfaceItemIdentifier("TagCell")
        guard let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath) as? TagItemCell else {
            return NSCollectionViewItem()
        }
        let cellViewModel = viewModel.tags.value[indexPath.item]
        item.bind(to: cellViewModel)
        return item
    }
}

extension QuizeViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        return calculateFilterTagCellSize(at: indexPath)
    }
    
    private func calculateFilterTagCellSize(at indexPath: IndexPath) -> CGSize {
        let tagTitle = viewModel.tags.value[indexPath.item].displayTagTitle.value
        let width = NSFont.helveticaNeueBold(size: 13)
            .size(text: tagTitle, constrainedToWidth: CGFloat.greatestFiniteMagnitude)
            .width + 30
        return CGSize(width: width, height: 20)
    }
}

extension QuizeViewController {
    private func setupViews() {
        view.wantsLayer = true
        filterContainerView.wantsLayer = true
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let identifier = NSUserInterfaceItemIdentifier("TagCell")
        tagCollectionView.register(TagItemCell.self, forItemWithIdentifier: identifier)
    }
}

extension QuizeViewController {
    private func bindWordsCount() {
        viewModel.totalNumberOfWord
            .map { String($0) }
            .bind(to: totalWordCountLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func bindToggleFilterButton() {
        toggleWordFilterButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                let isOn = self.toggleWordFilterButton.state.rawValue == 1 ? true : false
                if isOn {
                    self.showFilterSection()
                } else {
                    self.hideFilterSection()
                }
            }).disposed(by: disposeBag)
    }
    
    private func showFilterSection() {
        filterContainerView.findConstraint(for: .height)?.constant = 400
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    private func hideFilterSection() {
        filterContainerView.findConstraint(for: .height)?.constant = 180
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    private func bindWordDifficultyLevel() {
        easyLevelFilterButton.rx.state
            .map { $0.rawValue == 1 ? true : false }
            .bind(to: viewModel.easyLevelFilterOn)
            .disposed(by: disposeBag)
        
        mediumLevelFilterButton.rx.state
            .map { $0.rawValue == 1 ? true : false }
            .bind(to: viewModel.mediumLevelFilterOn)
            .disposed(by: disposeBag)
        
        difficultLevelFilterButton.rx.state
            .map { $0.rawValue == 1 ? true : false }
            .bind(to: viewModel.hardLevelFilterOn)
            .disposed(by: disposeBag)
        
        undefinedLevelFilterButton.rx.state
            .map { $0.rawValue == 1 ? true : false }
            .bind(to: viewModel.undefinedLevelFilterOn)
            .disposed(by: disposeBag)
    }
    
    private func bindTagCollectionView() {
        viewModel.tags
            .map { _ in }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.tagCollectionView.reloadData()
            }).disposed(by: disposeBag)
    }
}
