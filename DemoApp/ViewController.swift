//
//  ViewController.swift
//  DemoApp
//
//  Created by mahesh shukla on 22/06/17.
//  Copyright © 2017 mahesh shukla. All rights reserved.
//

import UIKit

class UserData: NSObject {
    let name:String
    let imgUrl:String
    let items : [String]
    init(name:String,img:String,items:[String]) {
        self.name = name
        self.imgUrl = img
        self.items = items
        
        super.init()
    }
}

class ViewController: UIViewController {
   // @IBOutlet weak var  tblView : UITableView!
    @IBOutlet weak var  indicator : UIActivityIndicatorView!
    var hasMore = false
    var arrUserData = [UserData]()
    @IBOutlet weak var collection : UICollectionView!
    var offSet = 0
    let limit = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "HomeCollectionViewCell", bundle: nil)
        self.collection.register(nib, forCellWithReuseIdentifier: "cellIdentifier")
        
        callApiWithUrl()
        collection.isHidden = true
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.headerReferenceSize = CGSize(width: self.collection.frame.size.width, height: 60)
        collection.collectionViewLayout = layout
        let headerNib = UINib(nibName: "HeaderCollectionReusableView", bundle: nil)
        collection.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderCollection")
        
    }
    
    func callApiWithUrl(){
        let str = "http://sd2-hiring.herokuapp.com/api/users?offset=\(offSet)&limit=\(limit)"
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: str)!
        indicator.startAnimating()
        indicator.isHidden = false
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.isHidden = true
            }
            
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                
                do {
                    
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    {
                        if let status = json["status"] as? Bool{
                            if status{
                                if let dataDict = json["data"] as? NSDictionary{
                                    self.hasMore = dataDict["has_more"] as! Bool
                                    if let arrItems = dataDict["users"] as? NSArray{
                                        for item in arrItems{
                                            let myItem = item as! NSDictionary
                                            let name = myItem["name"] as? String ?? ""
                                            let image = myItem["image"] as? String ?? ""
                                            let items = myItem["items"] as? [String] ?? [String]()
                                            let user = UserData(name: name, img: image, items: items)
                                            self.arrUserData.append(user)
                                        }
                                        DispatchQueue.main.async {
                                            self.collection.delegate = self
                                            self.collection.dataSource = self
                                            self.collection.isHidden = false
                                            self.collection.reloadData()
                                            
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
                        print(json)
                        
                    }
                    
                } catch {
                    
                    print("error in JSONSerialization")
                    
                }
                
                
            }
            
        })
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.arrUserData.count
        
      //  return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrUserData[section].items.count
        
       // return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as! HomeCollectionViewCell
        
        let cellData = self.arrUserData[indexPath.section].items[indexPath.row]
        cell.imgItems.imageURL = NSURL(string: cellData) as URL!
        
        if indexPath.section == self.arrUserData.count-1 && indexPath.row == self.arrUserData[indexPath.section].items.count-1 && self.hasMore{
            offSet = offSet + limit
            callApiWithUrl()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionItems = self.arrUserData[indexPath.section].items
        if sectionItems.count % 2 == 0{
            return CGSize(width: (UIScreen.main.bounds.size.width/2)-15, height: (UIScreen.main.bounds.size.width/2)-15)
        }else{
           return indexPath.row == 0 ?  CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width) : CGSize(width: (UIScreen.main.bounds.size.width/2)-15, height: (UIScreen.main.bounds.size.width/2)-15)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollection", for: indexPath) as! HeaderCollectionReusableView
            
            headerView.backgroundColor = UIColor.white;
            let sectionData = self.arrUserData[indexPath.section]
            headerView.imgUser.placeholderImage = UIImage(named: "user")
            headerView.imgUser.imageURL = NSURL(string: sectionData.imgUrl) as URL!
            headerView.lblName.text = sectionData.name
            
            return headerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
    
}

