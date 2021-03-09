//
//  SettingUserNameTableViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/27.
//

import UIKit
import FirebaseFirestore

class SettingUserNameTableViewController: UITableViewController {
    
    //受け取り用
    var me: AppUser!
    
    @IBOutlet var previousUserNameLabel: UILabel!
    @IBOutlet var newUserNameTextField: UITextField!
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //見た目
        self.tableView.backgroundColor = UIColor.backGroundGreenColor()

        newUserNameTextField.delegate = self
        previousUserNameLabel.text = me.userName
        //ボタン設定
        doneBarButtonItem.isEnabled = false
        doneBarButtonItem.tintColor = UIColor.darkGray
        doneBarButtonItem.style = .plain
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nav = self.navigationController!
        //呼び出し元のView Controllerを遷移履歴から取得しパラメータを渡す
        let bVC = nav.viewControllers[nav.viewControllers.count-1] as! SettingTableViewController
        bVC.me = me
    }
    
    @IBAction func done() {
        me.userName = newUserNameTextField.text ?? ""
        print("done発動！")
        //firestoreに上書き保存
        Firestore.firestore().collection("users").document(self.me.userID).setData(["userName": self.me.userName], merge: true)
        Firestore.firestore().collection("activities").document(self.me.userID).setData(["userName": self.me.userName], merge: true)
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
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

extension SettingUserNameTableViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //入力があるたびに呼ばれる・入力判定
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let newUserNameIsEmpty = newUserNameTextField.text?.isEmpty ?? true
        if newUserNameIsEmpty {
            doneBarButtonItem.isEnabled = false
            doneBarButtonItem.tintColor = UIColor.darkGray
            doneBarButtonItem.style = .plain
        }else {
            doneBarButtonItem.isEnabled = true
            doneBarButtonItem.tintColor = UIColor.orange
            doneBarButtonItem.style = .done
        }
    }
    
}
