//
//  File.swift
//  
//
//  Created by Little Developers on 15/09/2022.
//

import UIKit

extension String {
    
    public var localized: String {
        return Bundle.module.localizedString(forKey: self, value: self, table: "Localizable")
    }
}
