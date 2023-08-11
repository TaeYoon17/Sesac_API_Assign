//
//  BeerItemCell.swift
//  Sesac_API_Assign
//
//  Created by 김태윤 on 2023/08/08.
//

import UIKit

class BeerItemCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var prevBtn: UIButton!
    static let identifier = "BeerItemCell"
    var prevAction:UIAction?{
        didSet{
            if let oldValue{prevBtn.removeAction(oldValue, for: .touchUpInside)}
            if let prevAction{prevBtn.addAction(prevAction, for: .touchUpInside)}
        }
    }
    var nextAction:UIAction?{
        didSet{
            if let oldValue{ nextBtn.removeAction(oldValue, for: .touchUpInside) }
            if let nextAction{ nextBtn.addAction(nextAction, for: .touchUpInside) }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
