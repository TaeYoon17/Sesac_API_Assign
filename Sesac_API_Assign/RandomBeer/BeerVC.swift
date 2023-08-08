//
//  BeerVC.swift
//  Sesac_API_Assign
//
//  Created by 김태윤 on 2023/08/08.
//

import UIKit
import SwiftyJSON
import Kingfisher
class BeerVC:UIViewController{
    static let identifier = "BeerVC"
    var beers:[Beer] = []{
        didSet{
            self.collectionView.reloadData()
        }
    }
    var colors:[UIColor] = [.blue,.red,.darkGray,.lightGray]
    var json:JSON?{
        didSet{
            guard let json,
                  let beer = json.getBeer,
                  !beers.contains(beer) else { return }
            beers.append(beer)
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewConfigure()
        self.requestBeer()
    }
    func requestBeer(){
        BeerNetwork.Random
            .getDataRequest.responseJSON { response in
                switch response.result{
                case .success(let data):
                    print("성공!!")
                    self.json = JSON(data)
                case .failure(let err): print(err)
                }
            }
    }
}

extension BeerVC:UICollectionViewDelegate,UICollectionViewDataSource{
    private func collectionLayout(){
        let layout = UICollectionViewFlowLayout()
        print(self.collectionView.bounds)
        layout.itemSize = .init(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        //        layout.collectionView?.isPagingEnabled = true
        self.collectionView.isPagingEnabled = true
        self.collectionView.collectionViewLayout = layout
    }
    func collectionViewConfigure(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(.init(nibName: BeerItemCell.identifier, bundle: nil), forCellWithReuseIdentifier: BeerItemCell.identifier)
        self.collectionLayout()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        beers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BeerItemCell.identifier, for: indexPath) as? BeerItemCell else {return .init()}
        print(cell.bounds)
        //        cell.backgroundColor = colors[indexPath.row % colors.count]
        if let imgStr = beers[indexPath.row].imageURL{
            cell.imageView.kf.setImage(with: URL(string: imgStr))
        }
        cell.prevBtn.isEnabled = indexPath.row != 0
        cell.prevAction = .init(handler: {[weak self] _ in
            if indexPath.row == 0{
                let alert = UIAlertController(title: "첫번째 아이템이에요", message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "돌아가기", style: .cancel))
                self?.present(alert, animated: true)
            }else{
                self?.collectionView.scrollToPreviousItem()
            }
        })
        cell.nextAction = .init(UIAction(handler: { [weak self] _ in
            guard let self else {return}
            if indexPath.row == self.beers.count - 1{ self.requestBeer() }
            if indexPath.row != self.beers.count - 1 { self.collectionView.scrollToNextItem() }
        }))
        cell.titleLabel.text = beers[indexPath.row].name
        cell.descriptionLabel.text = beers[indexPath.row].description
        return cell
    }
}

extension JSON{
    var getBeer:Beer?{
        guard let val = arrayValue.first else{ return nil }
        let imageStr = val["image_url"].stringValue == "" ? nil : val["image_url"].stringValue
        return Beer(name: val["name"].stringValue,
                    description: val["description"].stringValue,
                    imageURL: imageStr)
    }
}
struct Beer:Hashable{
    let name:String
    let description:String
    let imageURL:String?
}
extension UICollectionView {
    
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x +
                                          self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
    
}
