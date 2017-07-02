//
//  UIViewController+Fetching.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit
import BoltsSwift

protocol Loadable: class {
    var isLoading: Bool { get set }
}

extension UIViewController {
    
    func presentErrorAlert(error: Error) {
        let title = NSLocalizedString("error_alert.title",
                                      value: "Sorry, something went wrong",
                                      comment: "The title of an error alert.")
        
        presentOkAlert(title: title, message: (error as? LocalizedError)?.errorDescription)
    }
    
    func presentOkAlert(title: String, message: String? = nil) {
        let okTitle = NSLocalizedString("alert.action_ok", value: "OK", comment: "The 'OK' action for an alert.")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okTitle, style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @discardableResult
    func fetch<T>(_ task: Task<T>) -> Task<T> {
        (self as? Loadable)?.isLoading = true
        return task.continueWithTask(.mainThread) { task in
            (self as? Loadable)?.isLoading = false
            task.error.map(self.presentErrorAlert)
            return task
        }
    }
}

