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
    @IBOutlet weak var AppendWordSectionView: NSView!
    
    let viewModel: HomeViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindViewModel()
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
    }
    
    private func setupCollectionView() {
        tagCollectionView.backgroundColors = [.clear]
        tagCollectionView.register(
            TagItemCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("Cell"))
        
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
            return calculateWordCellSize(at: indexPath)
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
    
    private func calculateWordCellSize(at indexPath: IndexPath) -> CGSize {
        return .zero
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
        return 0
    }
    
    private func configureTagItem(_ collectionView: NSCollectionView, at indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"),
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
        return item
    }
}


extension HomeViewController {
    func bindViewModel() {
        bindSearchToWord()
        bindCollectionView()
    }
    
    private func bindSearchToWord() {
        searchWordTextField.rx.text
            .filterOptional()
            .bind(to: viewModel.wordToSearch)
            .disposed(by: disposeBag)
    }
    
    private func bindCollectionView() {
        viewModel.allTags
            .subscribe(onNext: { fetchedTags in
                self.tagCollectionView.reloadData()
            }).disposed(by: disposeBag)
    }
}
