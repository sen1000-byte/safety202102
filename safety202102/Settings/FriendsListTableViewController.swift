//
//  FriendsListTableViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/02.
//

import UIKit
import FirebaseFirestore

class FriendsListTableViewController: UITableViewController {
    
    //受け取り用
    var me: AppUser!
    var friendsDictionary = [Int: Activity]()
    //今後使うデータ用
    var myFriend: AppUser!

    
    @IBOutlet var editBarButton: UIBarButtonItem!
    
    var editBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editBarButton.tintColor = UIColor.darkGray
//        editBarButtonItem = UIBarButtonItem(title: "編集", style: .plain, target: self, action: #selector(editBarButtonTapped))
//        self.parent?.navigationItem.rightBarButtonItem = editBarButtonItem

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let nav = self.navigationController!
        
        print("friends",friendsDictionary)
        
        //呼び出し元のView Controllerを遷移履歴から取得しパラメータを渡す
        let bVC = nav.viewControllers[nav.viewControllers.count-1] as! SettingTableViewController
        bVC.friendsDictionary = friendsDictionary
    }
    @IBAction func edit() {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "編集"
            editBarButton.style = .plain
            editBarButton.tintColor = UIColor.darkGray
            tableView.reloadData()
        }else{
            tableView.setEditing(true, animated: true)
            editBarButton.title = "完了"
            editBarButton.style = .done
            editBarButton.tintColor = UIColor.orange
        }
        
    }
    
//    @objc func editBarButtonTapped() {
//        if tableView.isEditing {
//            tableView.setEditing(false, animated: true)
//            editBarButton.title = "編集"
//            editBarButton.style = .plain
//            editBarButton.tintColor = UIColor.darkGray
//            tableView.reloadData()
//        }else{
//            tableView.setEditing(true, animated: true)
//            editBarButton.title = "完了"
//            editBarButton.style = .done
//            editBarButton.tintColor = UIColor.orange
//        }
//        
//    }
    
    func compareDate(fromDate: Date) -> UIImage{
        let toDate = Timestamp().dateValue()
        let elapsedDays = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day!
        switch elapsedDays {
        case 0:
            return UIImage(named: "smile")!
        case 1:
            return UIImage(named: "smileone")!
        case 2:
            return UIImage(named: "smiletwo")!
        case 3:
            return UIImage(named: "smilethree")!
        case 4:
            return UIImage(named: "smilefour")!
        default:
            return UIImage(named: "smilefive")!
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendsDictionary.count - 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendsListTableViewCell
        cell.friendNameLabel.text = friendsDictionary[indexPath.row + 1]?.userName
        let friendLatestActiveTimeStamp = friendsDictionary[indexPath.row + 1]?.latestActiveTime ?? Timestamp(seconds: 0, nanoseconds: 0)
        if  friendLatestActiveTimeStamp != Timestamp(seconds: 0, nanoseconds: 0)  {
            let friendLatestetActiveTime: Date = friendLatestActiveTimeStamp.dateValue()
            cell.smileImageView.image = compareDate(fromDate: friendLatestetActiveTime)
        }else{
            cell.smileImageView.image = UIImage(named: "smileloading")
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    //編集モードの時にdeleteを選択した時に呼ばれる　commitに削除を示すeditingStyle.deleteが渡される forRowAtは選択された行番号
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "本当に選択した相手の登録を解除しますか", message: "相手からもあなたが登録から解除されます。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { action in
                //friendsDictionalyから削除・friendsDictionalyのkeyを調整
                for i in indexPath.row..<(self.friendsDictionary.count - 1){
                    self.friendsDictionary[i + 1] = self.friendsDictionary[i + 2]
                }

                //meの友達から、相手を削除
                var myfriendsArray = self.me.friends
                var myfriend: AppUser!
                let myfriendID = myfriendsArray[indexPath.row + 1]
                myfriendsArray.remove(at: indexPath.row + 1)
                //firestoreに上書き保存
                Firestore.firestore().collection("users").document(self.me.userID).setData(["friends": myfriendsArray], merge: true)
                
                //firestoreから削除する相手のデータを取得
                Firestore.firestore().collection("users").document(myfriendID).getDocument { (snap, error) in
                    if let error = error {
                        print("firestoreからのデータの取得に失敗\(error)")
                        return
                    }
                    guard let data = snap?.data() else {return}
                    myfriend = AppUser.init(data: data)
                    var myfriendFriends : [String] = myfriend.friends

                    //相手から自分を友達から外す
                    if let i = myfriendFriends.firstIndex(of: self.me.userID) {
                        myfriendFriends.remove(at: i)
                    }
                    //firestoreに保存
                    Firestore.firestore().collection("users").document(myfriend.userID).setData(["friends": myfriendFriends], merge: true)
                }
                //friend側のfriendsからmeを消す
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            alert.addAction(UIAlertAction(title: "いいえ", style: .destructive, handler: nil))
            present(alert, animated: true, completion: nil)
            

        }
    }
    
    
    func removeFromArray() {
        
    }

    
    // Override to support rearranging the table view.
    //編集モードで、入れ替えが行われた時に発動 moveRowAtが動く前 toが動いた後の行番号
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let temp = friendsDictionary[fromIndexPath.row + 1]
        friendsDictionary[fromIndexPath.row + 1] = friendsDictionary[to.row + 1]
        friendsDictionary[to.row + 1] = temp
        
        //meの友達から、相手を削除
        var myfriendsArray = me.friends
        let mytemp = myfriendsArray[fromIndexPath.row + 1]
        myfriendsArray[fromIndexPath.row + 1] = myfriendsArray[to.row + 1]
        myfriendsArray[to.row + 1] = mytemp
        //firestoreに上書き保存
        Firestore.firestore().collection("users").document(self.me.userID).setData(["friends": myfriendsArray], merge: true)

    }
    

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
