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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = true
        
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
