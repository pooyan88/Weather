//
//  AlertManager.swift
//  Weather
//
//  Created by Pooyan on 18/04/2023.
//

import UIKit

class AlertManager {
    
    static let shared = AlertManager()
    
    func showAlert(alertTitle: String, alertDescription: String, alertConfirmationButtonTitle: String, view: UIViewController) {
        let alert = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: alertConfirmationButtonTitle, style: .default)
        alert.addAction(action)
        view.present(alert, animated: true)
    }
}
