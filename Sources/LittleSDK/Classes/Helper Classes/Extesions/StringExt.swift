//
//  File.swift
//  
//
//  Created by Little Developers on 15/09/2022.
//

import Foundation

extension String {
    func equalIgnoreCase(_ compare:String) -> Bool {
        return self.uppercased() == compare.uppercased()
    }
}
