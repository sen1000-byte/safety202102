//
//  TabBarViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/04.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var userID: String!
    var settingButtonItem: UIBarButtonItem!
    
    let userdefaults = UserDefaults.standard
    var easyModeBool: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
//        navigationController?.setNavigationBarHidden(false, animated: false)
//        navigationController?.setToolbarHidden(true, animated: false)
        
        easyModeBool = userdefaults.bool(forKey: "easyMode")
        let mytabBarController: UITabBarController = self
        mytabBarController.tabBar.isHidden = true
        print("bool", mytabBarController.tabBar.isHidden)
        if easyModeBool {
            selectedIndex = 1
        }else {
            selectedIndex = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        easyModeBool = userdefaults.bool(forKey: "easyMode")
        self.tabBarController?.tabBar.isHidden = true
        print("bool",easyModeBool)
        if easyModeBool {
            selectedIndex = 1
        }else {
            selectedIndex = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingBarButtonTapped))
        self.parent?.navigationItem.rightBarButtonItem = settingButtonItem
    }
    
    @objc func settingBarButtonTapped() {
        performSegue(withIdentifier: "toSetting", sender: userID)
    }
    
    // Do any additional setup after loading the view.
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

