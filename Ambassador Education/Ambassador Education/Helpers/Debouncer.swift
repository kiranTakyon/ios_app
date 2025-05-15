//
//  Debouncer.swift
//  Ambassador Education
//
//  Created by IE14 on 15/05/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import Foundation

class Debouncer {
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    private let delay: TimeInterval

    init(delay: TimeInterval, queue: DispatchQueue = .main) {
        self.delay = delay
        self.queue = queue
    }

    func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        if let workItem = workItem {
            queue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
    
    func cancel() {
        workItem?.cancel()
    }
}

protocol DebouncedSearchHandling: AnyObject {
    func performSearchIfNeeded(query: String)
}


import UIKit

class DebouncedTextFieldDelegate: NSObject , UITextFieldDelegate {
    private let debouncer: Debouncer
    private weak var handler: DebouncedSearchHandling?

    init(debounceInterval: TimeInterval = 0.3, handler: DebouncedSearchHandling) {
        self.debouncer = Debouncer(delay: debounceInterval)
        self.handler = handler
        super.init()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        let query = updatedText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("Delegate called")
        debouncer.debounce { [weak handler] in
            handler?.performSearchIfNeeded(query: query)
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        debouncer.cancel()
        handler?.performSearchIfNeeded(query: textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        return true
    }
}

