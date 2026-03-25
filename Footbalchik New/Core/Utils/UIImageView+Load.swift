//
//  UIImageView+Load.swift
//  Footbalchik
//
//  Created by Nick on 21.03.2026.
//


import UIKit

private var imageUrlKey: UInt8 = 0

extension UIImageView {

    private var currentURL: String? {
        get { objc_getAssociatedObject(self, &imageUrlKey) as? String }
        set { objc_setAssociatedObject(self, &imageUrlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func setImage(from urlString: String?) {

        currentURL = urlString
        self.image = nil

        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in

            guard let self = self,
                  self.currentURL == urlString else { return }

            self.image = image
        }
    }
}
