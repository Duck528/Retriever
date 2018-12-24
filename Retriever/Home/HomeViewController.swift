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
        tagCollectionView.register(
            TagItemCell.self,
            forItemWithIdentifier: NSUserInterfaceItemIdentifier("Cell"))
    }
}

extension HomeViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let tagTitle = viewModel.allTags.value[indexPath.item].tagItem.value.title
        let width = NSFont.systemFont(ofSize: 13)
            .size(text: tagTitle, constrainedToWidth: CGFloat.greatestFiniteMagnitude)
            .width
        return CGSize(width: width, height: 30)
    }
}

extension HomeViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.allTags.value.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"),
            for: indexPath) as? TagItemCell else {
                return NSCollectionViewItem()
        }
        let cellViewModel = viewModel.allTags.value[indexPath.item]
        item.bind(to: cellViewModel)
        return item
    }
}


extension HomeViewController {
    func bindViewModel() {
        bindSearchToWord()
    }
    
    private func bindSearchToWord() {
        searchWordTextField.rx.text
            .map { $0 ?? "" }
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
