//
//  BlurExtensions.swift
//  Sesac_API_Assign
//
//  Created by 김태윤 on 2023/08/10.
//

import Foundation
import UIKit

extension UIView{
    func getBlur(style: UIBlurEffect.Style,corderRadius: CGFloat = 8){
        self.backgroundColor = .clear
        let effect = UIBlurEffect(style: .regular)
        let visualView = UIVisualEffectView(effect: effect)
        visualView.isUserInteractionEnabled = false
        visualView.frame = self.bounds
        self.clipsToBounds = true
        self.layer.cornerRadius = corderRadius
        self.insertSubview(visualView, at: 0)
    }
}
