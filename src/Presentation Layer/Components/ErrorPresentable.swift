//
//  ErrorPresentable.swift
//  ThirdPartyDependencies
//
//  Created by Nikolay Chaban on 2/15/19.
//  Copyright © 2019 Nikolay Chaban. All rights reserved.
//

import UIKit

protocol ErrorPresentable {
    func present(_ error: Error)
}

extension ErrorPresentable where Self: UIViewController {
    func present(_ error: Error) {
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
