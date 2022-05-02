//
//  UITableView+Extension.swift
//  Weather Test Task
//
//  Created by Alex173 on 29.04.2022.
//

import UIKit

extension UITableView {
    func deselectAllRows(animated: Bool) {
        guard let selectedRows = indexPathsForSelectedRows else { return }
        for indexPath in selectedRows { deselectRow(at: indexPath, animated: animated) }
    }
}
