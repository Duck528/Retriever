//
//  WordItemCell.swift
//  Retriever
//
//  Created by thekan on 26/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class WordItemCell: NSCollectionViewItem, BindableType {
    typealias ViewModelType = WordItemCellViewModel
    
    @IBOutlet weak var wordTextField: NSTextField!
    @IBOutlet weak var meanTextField: NSTextField!
    @IBOutlet weak var syncWordButton: NSButton!
    @IBOutlet weak var diffcultyLabel: NSTextField!
    @IBOutlet weak var tagCollectionView: NSCollectionView!
    
    var viewModel: WordItemCellViewModel!
    var disposeBag = DisposeBag()
    
    func bindViewModel() {
        viewModel.wordItem
            .subscribe(onNext: { wordItem in
                self.wordTextField.stringValue = wordItem.word
                self.meanTextField.stringValue = wordItem.mean
                self.syncWordButton.isHidden = wordItem.status == .stable
                self.diffcultyLabel.stringValue = wordItem.difficulty.title
                self.tagCollectionView.isHidden = wordItem.tags.count == 0
                self.tagCollectionView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        viewModel = nil
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
}

extension WordItemCell: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tags.value.count
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("TagCell"),
            for: indexPath) as? TagItemCell else {
                return NSCollectionViewItem()
        }
        guard indexPath.item >= 0, indexPath.item < viewModel.tags.value.count else {
            return NSCollectionViewItem()
        }
        cell.bind(to: viewModel.tags.value[indexPath.item])
        return cell
    }
}

extension WordItemCell: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return calculateTagCellSize(at: indexPath)
    }
    
    private func calculateTagCellSize(at indexPath: IndexPath) -> CGSize {
        let tagTitle = viewModel.tags.value[indexPath.item].displayTagTitle.value
        let width = NSFont.helveticaNeueBold(size: 13)
            .size(text: tagTitle, constrainedToWidth: CGFloat.greatestFiniteMagnitude)
            .width + 30
        return CGSize(width: width, height: 20)
    }
}

extension WordItemCell {
    private func setupViews() {
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.register(
            TagItemCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("TagCell"))
    }
}

class WordItemCellViewModel {
    let wordItem: BehaviorRelay<WordItem>
    let tags: BehaviorRelay<[TagItemCellViewModel]>
    
    init(wordItem: WordItem) {
        self.wordItem = BehaviorRelay<WordItem>(value: wordItem)
        let tagItems = wordItem.tags
            .map { TagItemCellViewModel(tagItem: $0, selectable: false) }
        self.tags = BehaviorRelay<[TagItemCellViewModel]>(value: tagItems)
    }
}
