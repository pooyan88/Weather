//
//  UIViewControllerExtensions.swift
//  Weather
//
//  Created by Pooyan on 18/04/2023.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showNetworkError(error: NetworkRequests.MyError) {
        switch error {
        case .decodeError:
            AlertManager.shared.showAlert(alertTitle: "Error", alertDescription: "Decode Error", alertConfirmationButtonTitle: "OK", view: self)
        case .serverError:
            AlertManager.shared.showAlert(alertTitle: "Error", alertDescription: "Server Error", alertConfirmationButtonTitle: "OK", view: self)
        case .urlError:
            AlertManager.shared.showAlert(alertTitle: "Error", alertDescription: "Try Again", alertConfirmationButtonTitle: "OK", view: self)
        }
    }
}
