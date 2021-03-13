//
//  SettingTableViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/27.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingTableViewController: UITableViewController {
    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var easyModeSwitch: UISwitch!
    
    //受け取り用
    var userID: String!
    var me: AppUser!
    var friendsDictionary = [Int: Activity]()
    
    var userDefaults = UserDefaults.standard
    var easyModeBool: Bool!
    var switchPushed: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //見た目
        self.tableView.backgroundColor = UIColor.backGroundGreenColor()
        
        easyModeBool = userDefaults.bool(forKey: "easyMode")
        easyModeSwitch.isOn = easyModeBool

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userNameLabel.text = me.userName
        emailLabel.text = me.email
        
        print("setting, friendsDic: ", friendsDictionary)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //もしボタンが変更せれていたなら
        if switchPushed % 2 != 0 {
            print("発動")
            easyModeBool = easyModeSwitch.isOn
            userDefaults.setValue(easyModeBool, forKey: "easyMode")
            let index = navigationController!.viewControllers.count - 1
            navigationController?.popToViewController(navigationController!.viewControllers[index], animated: false)
        }
    }

    // MARK: - Table view data source

    
    @IBAction func easyMode(sender: UISwitch) {
        switchPushed += 1
        print(switchPushed)
        if sender.isOn {
            
        }else{
            
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 4
        case 1:
            return 2
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0 :
            switch indexPath.row {
            case 0:
                return
            case 1:
                return
            case 2:
                return
            case 3:
                //logoutをsection0のrow3に実装
                logout()
                return
            default:
                return
            }
        case 1:
            switch  indexPath.row {
            case 0:
                performSegue(withIdentifier: "toFriendsList", sender: nil)
                return
            case 1:
                performSegue(withIdentifier: "toSearchFriend", sender: nil)
                return
            default:
                return
            }
        default:
            return
        }
    }
    
    func logout() {
        let alert = UIAlertController(title: "ログアウトしますか？", message: "はいを押すとログアウトします", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { action in
            try? Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSettingUserName" {
            let nVC = segue.destination as! SettingUserNameTableViewController
            nVC.me = me
        }
        
        if segue.identifier == "toSettingEmail" {
            let nVC = segue.destination as! SettingEmailTableViewController
            nVC.me = me
        }
        
        if segue.identifier == "toSearchFriend" {
            let nVC = segue.destination as! SearchFriendViewController
            nVC.me = me
            nVC.friendsDictionary = friendsDictionary
            nVC.flagForPreVCInt = 1
        }
        
        if segue.identifier == "toFriendsList" {
            let nVC = segue.destination as! FriendsListTableViewController
            nVC.me = me
            nVC.friendsDictionary = friendsDictionary
        }
    }

}
