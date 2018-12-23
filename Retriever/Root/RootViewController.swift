//
//  HomeController.swift
//  Retriever
//
//  Created by thekan on 22/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class RootViewController: NSViewController {
    
    enum ColorTable {
        case brightRed
        case clear
        
        var color: NSColor {
            switch self {
            case .brightRed:
                return NSColor(red: 241, green: 75, blue: 75)
            case .clear:
                return NSColor.clear
            }
        }
    }
    
    @IBOutlet weak var statusView: NSView!
    @IBOutlet weak var statusTextField: NSTextField!
    @IBOutlet weak var statusColor: NSBox!
    
    let viewModel: RootViewModel
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

extension RootViewController {
    private func bindViewModel() {
        bindSynchronized()
    }
    
    private func bindSynchronized() {
        viewModel.synchronizedToRemote
            .subscribe(onNext: {
                switch $0 {
                case .success:
                    self.updateStatus(message: "동기화 완료", color: ColorTable.clear.color)
                    self.hideStatus()
                case .fail:
                    self.updateStatus(message: "실패", color: ColorTable.brightRed.color)
                    self.showStatus()
                case .unregistered:
                    self.updateStatus(message: "등록되지 않음", color: ColorTable.brightRed.color)
                    self.showStatus()
                case .progress:
                    self.updateStatus(message: "진행 중", color: ColorTable.clear.color)
                }
            }).disposed(by: disposeBag)
    }
    
    private func updateStatus(message: String, color: NSColor) {
        statusTextField.stringValue = message
        statusColor.fillColor = color
    }
    
    private func showStatus() {
        NSAnimationContext.runAnimationGroup { context in
            statusView.heightAnchor
                .constraint(equalToConstant: 0.0)
                .isActive = true
            context.duration = 0.25
        }
    }
    
    private func hideStatus() {
        NSAnimationContext.runAnimationGroup { context in
            statusView.heightAnchor
                .constraint(equalToConstant: 0.0)
                .isActive = true
            context.duration = 0.25
        }
    }
}
