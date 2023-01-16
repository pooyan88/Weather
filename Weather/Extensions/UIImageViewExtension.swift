//
//  UIImageViewExtension.swift
//  Weather
//
//  Created by Pooyan on 04/01/2023.
//

import UIKit

extension UIImageView {
    
    func download(from string: String, contentMode mode: ContentMode = .scaleAspectFit) {
        let stringUrl = string.replacingOccurrences(of: "//", with: "", options: NSString.CompareOptions.literal, range:nil)
        guard let url = URL(string: "https://" + stringUrl) else {
            print(" Failed  to load image2: \(stringUrl)")
            return
        }
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200, let data1 = data, error == nil, let image = UIImage(data: data1) else {
                print(" Failed  to load image1: \(url)")
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.image = image
            }
        }.resume()
    }
}
