//
//  MainViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/26.
//

import UIKit

class MainViewController: UIViewController {
    
    var userID: String!
    var me: AppUser!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = true
        
        //collectionview
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.backgroundColor = UIColor.lightGray
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 30, left: 20, bottom: 8, right: 20)
        collectionViewFlowLayout.minimumLineSpacing = 15
        collectionViewFlowLayout.minimumInteritemSpacing = 10
        collectionViewFlowLayout.estimatedItemSize = CGSize(width: collectionView.frame.width / 2 - 30, height: collectionView.frame.width / 2 - 20)
        
//        //アカウント登録画面を表示させる
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let signUpStoryboard = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
//        signUpStoryboard.modalPresentationStyle = .fullScreen
//        self.present(signUpStoryboard, animated: true, completion: nil)

        // Do any additional setup after loading the view.
    }
    

    @IBAction func toSetting() {
        performSegue(withIdentifier: "toSetting", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MainCollectionViewCell
        cell.backgroundColor = UIColor.yellow
        cell.layer.cornerRadius = 20
        return cell
    }
    
    
}
