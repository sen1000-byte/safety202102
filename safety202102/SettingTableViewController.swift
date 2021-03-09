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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userNameLabel.text = me.userName
        emailLabel.text = me.email
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
                performSegue(withIdentifier: "toSearch", sender: userID)
                return
            default:
                return
            }
        default:
            return
        }

//        if indexPath.section == 0 && indexPath.row == 3 {
//            let alert = UIAlertController(title: "ログアウトしますか？", message: "はいを押すとログアウトします", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { action in
//                try? Auth.auth().signOut()
//                self.navigationController?.popToRootViewController(animated: true)
//            }))
//            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
//            present(alert, animated: true, completion: nil)
//        }
//
//        if indexPath.section == 1 && indexPath.row == 1 {
//            performSegue(withIdentifier: "toSearch", sender: userID)
//        }
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
        
        if segue.identifier == "toSearch" {
            let nVC = segue.destination as! SearchViewController
            nVC.userID = sender as! String
        }
        
        if segue.identifier == "toFriendsList" {
            let nVC = segue.destination as! FriendsListTableViewController
            nVC.me = me
            nVC.friendsDictionary = friendsDictionary
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
