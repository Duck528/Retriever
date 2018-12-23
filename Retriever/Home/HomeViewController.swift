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
    @IBOutlet weak var tagCollectionView: NSScrollView!
    
    let viewModel: HomeViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func bindViewModel() {
        bindSearchToWord()
    }
    
    private func bindSearchToWord() {
        searchWordTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.wordToSearch)
            .disposed(by: disposeBag)
    }
}
