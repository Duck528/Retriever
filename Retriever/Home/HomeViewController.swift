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
    
    // Append Word Section
    @IBOutlet weak var appendWordSectionView: NSView!
    @IBOutlet weak var cancelAppendWordButton: NSButton!
    @IBOutlet weak var appendWordButton: NSButton!
    @IBOutlet weak var appendWordContinouslyButton: NSButton!
    @IBOutlet weak var presentAppendWordSectionView: NSView!
    @IBOutlet weak var presentAppendWordSectionButton: NSButton!
    
    @IBOutlet weak var wordTextField: NSTextField!
    @IBOutlet weak var meanTextField: NSTextField!
    @IBOutlet weak var additionalInfoTextView: NSTextView!
    @IBOutlet weak var difficultyPopUpButton: NSPopUpButton!
    
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
    }
    
    private func bindViewAction() {
        viewModel.viewAction
            .subscribe(onNext: {
                switch $0 {
                case .hideAppendWordSection:
                    self.hideAppendWordSection()
                case .showAppendWordSection:
                    self.showAppendWordSection()
                }
            }).disposed(by: disposeBag)
    }
    
    private func hideAppendWordSection() {
        appendWordSectionView.findConstraint(for: .bottom)?.constant =
            -appendWordSectionView.bounds.height
        presentAppendWordSectionView.findConstraint(for: .bottom)?.constant = 0
    }
    
    private func showAppendWordSection() {
        appendWordSectionView.findConstraint(for: .bottom)?.constant = 0
        presentAppendWordSectionView.findConstraint(for: .bottom)?.constant =
            -presentAppendWordSectionView.bounds.height
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
            .subscribe(onNext: { fetchedTags in
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
        wordTextField.rx.text
            .filterOptional()
            .bind(to: viewModel.wordText)
            .disposed(by: disposeBag)
    }
    
    private func bindMeanTextField() {
        meanTextField.rx.text
            .filterOptional()
            .bind(to: viewModel.meanText)
            .disposed(by: disposeBag)
    }
    
    private func bindAdditionalInfoTextView() {
        additionalInfoTextView.rx.string
            .bind(to: viewModel.additionalInfoText)
            .disposed(by: disposeBag)
    }
    
    private func bindWordAppendableStatus() {
        viewModel.wordAppendable
            .subscribe(onNext: { appendable in
                self.appendWordButton.isEnabled = appendable
                self.appendWordContinouslyButton.isEnabled = appendable
            }).disposed(by: disposeBag)
    }
}
