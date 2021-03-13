//
//  AlternateViewController.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/02/27.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import EAIntroView
import NVActivityIndicatorView
import PKHUD

class AlternateViewController: UIViewController {
    
    //受け渡し用
    var userID: String!
    var me: AppUser!
    var friendsDictionary = [Int: Activity]()
    
    
    @IBOutlet var smileButton: UIButton!
    @IBOutlet var myLatestActivityTimeLabel: UILabel!
    
    //天気系
    @IBOutlet var weatherMainLabel: UILabel!
    @IBOutlet var weatherDescriptionLabel: UILabel!
    @IBOutlet var weatherIconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var locationTextField: UITextField!
    var locationPickerView = UIPickerView()
    //市の名前、IDのあるデータを持ってくる
    var locationList = LocationList()
    var weatherIcon = WeatherIcon()

    //選択したlocationを記憶させておくために使用
    var userDefaults = UserDefaults.standard
    //選択した位置を入れるための[String]
    var selectedLocation = [String]()    //[0]にid, [1]に名前を入れる
    
    var dateFormatter = DateFormatter()
    var settingButtonItem: UIBarButtonItem!
    var walkthroughButtonItem: UIBarButtonItem!
    
//    //ボタンの連打による天気の取得を防ぐための変数
//    var smilePushedDate = Date() - 1000
    
    
    //読み込み中を表示させるための変数
    //読み込み中アニメーションのインスタンスを作る
    var activityIndicatorView: NVActivityIndicatorView!
    //読み込み中は触れなくするためのview
    var backgroundView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userID = Auth.auth().currentUser!.uid
        
        //読み込み中画面を作るための設定
        setUpActivityIndicatorVIew()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
        
        
        settingButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(settingBarButtonTapped))
        walkthroughButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(showWalkthrough))
        
        walkthroughButtonItem.tintColor = UIColor.darkGray
        settingButtonItem.tintColor = UIColor.darkGray
        self.parent?.navigationItem.rightBarButtonItems = [settingButtonItem, walkthroughButtonItem]
        
        
//        settingButtonItem = UIBarButtonItem(title: "設定", style: .done, target: self, action: #selector(settingBarButtonTapped))
//        self.parent?.navigationItem.rightBarButtonItem = settingButtonItem
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMMHHmm", options: 0, locale: Locale(identifier: "ja_JP"))
        
        //smilebuttonの見た目
        smileButton.layer.shadowColor = UIColor.lightGray.cgColor
        smileButton.layer.shadowOffset = CGSize(width: 8, height: 8)
        smileButton.layer.shadowRadius = 3
        smileButton.layer.shadowOpacity = 1
        
        //天気系
        setUpFirstWeather()
        setUpTextField()
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        hidesBottomBarWhenPushed = true
        
        
        view.addSubview(backgroundView)
        //アニメーションの開始
        activityIndicatorView.startAnimating()
        
        
        setUpMeFromFirestore()
    }
    
    func setUpMeFromFirestore() {
        //firebase firestoreから情報の引き出し meに代入
        Firestore.firestore().collection("users").document(userID!).getDocument { (snap, error) in
            if let error = error {
                print("firestoreからのmeへのデータの取得に失敗\(error)")
                HUD.dimsBackground = false
                HUD.flash(.labeledError(title: "エラー", subtitle: "データの取得ができませんでした。再度更新してください。"), delay: 1.5)
                return
            }
            guard let data = snap?.data() else {return}
            let meTemp = AppUser(data: data)
            self.me = meTemp
            self.setUpViews()
            self.setUpfriendsDictionaly()
        }
    }
    
    func setUpfriendsDictionaly() {
        for i in 0..<me.friends.count {
            Firestore.firestore().collection("activities").document("\(me.friends[i])").getDocument { (snap, error) in
                if let error = error {
                    print("firestoreからactivityのデータ取得に失敗しました\(error)")
                    HUD.dimsBackground = false
                    HUD.flash(.labeledError(title: "エラー", subtitle: "友達情報の取得ができませんでした。再度更新してください。"), delay: 1.5)
                }
                guard let data = snap?.data() else {return}
                let friend = Activity(data: data)
                self.friendsDictionary[i] = friend
                
                //読み込み中画面を終わる
                self.backgroundView.removeFromSuperview()
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    
    func setUpViews() {
        //タイトル
        self.parent?.navigationItem.title = me.userName
        Firestore.firestore().collection("activities").document(userID).getDocument { (snap, error) in
            if let error = error {
                print("firestoreからactivityのデータ取得に失敗しました\(error)")
                HUD.dimsBackground = false
                HUD.flash(.labeledError(title: "エラー", subtitle: "安否情報の取得ができませんでした。再度更新してください。"), delay: 1.5)
            }
            //更新時間・ボタン
            guard let data = snap?.data() else {return}
            let myActivity = Activity(data: data)
            let timeStamp = myActivity.latestActiveTime ?? Timestamp(seconds: 0, nanoseconds: 0)
            if  timeStamp != Timestamp(seconds: 0, nanoseconds: 0) {
                let latestetActiveTime: Date = timeStamp.dateValue()
                self.smileButton.setImage(self.compareDate(fromDate: latestetActiveTime), for: .normal)
                self.myLatestActivityTimeLabel.text = "更新時刻：　" + self.dateFormatter.string(from: latestetActiveTime)
            }else{
                self.myLatestActivityTimeLabel.text = "更新時刻：　"
                self.smileButton.setImage(UIImage(named: "smileloading"), for: .normal)
            }
        }
    }
    
    //textFieldの最初の設定をする
    func setUpTextField() {
        locationTextField.delegate = self
        locationPickerView.delegate = self
        locationPickerView.dataSource = self
        
        //キーボードにdoneボタンをつける
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 43))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spaceItem,doneItem], animated: true)
        
        
        //pickerviewとtagtextfieldを連携
        locationTextField.inputView = locationPickerView
        locationTextField.inputAccessoryView = toolbar
    }
    
    //weatherのラベルの最初の表示を設定する
    func setUpFirstWeather() {
        
        selectedLocation = userDefaults.array(forKey: "weather") as? [String] ?? []
        
        //もしデータの個数が２個でなければ初期化する
        if selectedLocation.count != 2 {
            //selecetdLocationを初期化
            selectedLocation = []
            locationTextField.text = ""
            
        }else {
            locationTextField.text = selectedLocation[1]
        }
        
        weatherMainLabel.text = ""
        weatherDescriptionLabel.text = ""
        tempLabel.text = "スマイルボタンを\n押して天気を取得"
        weatherIconImageView.image = UIImage(named: "")
        
    }

    
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
    
    func setUpActivityIndicatorVIew() {
        // 設定
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 70, height: 70), type: NVActivityIndicatorType.cubeTransition, color: UIColor.darkGray, padding: 0)
         backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        backgroundView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6)
        activityIndicatorView.center = self.view.center // 位置を中心に設定
        //subviewに追加
        view.addSubview(activityIndicatorView)
    }
    
    
    
    @IBAction func smile() {
        
        
        //読み込み画面の開始
        view.addSubview(backgroundView)
        //アニメーションの開始
        activityIndicatorView.startAnimating()
        
        let latestActiveTime = Timestamp()
        Firestore.firestore().collection("activities").document(userID).setData(["latestActiveTime": latestActiveTime], merge: true)
        smileButton.setImage(UIImage(named: "smile"), for: .normal)
        myLatestActivityTimeLabel.text = "更新時刻：　" + dateFormatter.string(from: latestActiveTime.dateValue())
        //情報の更新
        setUpMeFromFirestore()
        
        //天気の取得
        //もしもselectedLocationが設定できていない時にエラーを出す
        if selectedLocation.count != 2 {
            print("selectedLocationが設定できていません。", selectedLocation)
        }else {
            getWeather(id: selectedLocation[0])
        }
    }
    
    @objc func settingBarButtonTapped() {
        performSegue(withIdentifier: "toSetting", sender: userID)
    }
    
    @IBAction func toSetting() {
        performSegue(withIdentifier: "toSetting", sender: userID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSetting" {
            let nVC = segue.destination as! SettingTableViewController
            nVC.userID = sender as? String ?? ""
            nVC.me = me
            nVC.friendsDictionary = friendsDictionary
        }
    }
    
    
    
    //天気系
    func getWeather(id: String) {
        let baseURL = "https://api.openweathermap.org/data/2.5/forecast?"
        let LocationID = id
        let myAPIKey = "180f7e1927b7948af30cc82b95fc6dad"
        let weatherURL = baseURL + "id=\(LocationID)&units=metric&lang=ja&cnt=1&appid=\(myAPIKey)"

        //weatherURLをString型からURL型に変更する
        if let url = URL(string: weatherURL) {
            //データを取得するためのurlsessionを作成する
            let urlSession = URLSession(configuration: .default)
            
            //データを取ってくる
            let getWeatherData = urlSession.dataTask(with: url){ (data, response, error) in
                if error != nil {
                    print("urlからのデータの取得に失敗しました", error!)
                    return
                }
                if let loadedData = data {
                    
                    self.getJSONdata(weatherData: loadedData)
                }
            }
            //実行する
            getWeatherData.resume()
            
        } else {
            print("urlの取得に失敗しました")
            return
        }
    }
    
    //読み込んだJSONデータを解読する
    func getJSONdata(weatherData: Data) {
        //解読するdecoderを作る
        let decoder = JSONDecoder()
        //エラーが起きることがる想定される時の書き方
        do {
            let decodedData = try decoder.decode(weatherDecoaded.self, from: weatherData)
            //バックグラウンドじゃないところで行う
            DispatchQueue.main.sync {
                //エラーがない時実行される（解読できてweatherDecoadedの形に当てはまるよっていう時）
                weatherMainLabel.text = decodedData.list[0].weather[0].main
                weatherDescriptionLabel.text = "(" + decodedData.list[0].weather[0].weatherDescription + ")"
                weatherIconImageView.image = weatherIcon.selectIcon(icon: decodedData.list[0].weather[0].icon, main: decodedData.list[0].weather[0].main)
                weatherIconImageView.tintColor = weatherIcon.selectIconColor(icon: decodedData.list[0].weather[0].icon)
                tempLabel.text = String(decodedData.list[0].main.temp) + "℃"
            }
        } catch  let error{
            //エラーがあるとcatchの中を行う
            print("decodeに失敗しました \(error)")
            
        }
        
    }
    

}


// MARK: -extensions

//PickerViewとTextFieldのextension
extension AlternateViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @objc func done() {
        locationTextField.resignFirstResponder()
        //userDefaultsにLocationを保存する
        userDefaults.setValue(selectedLocation, forKey: "weather")
        weatherMainLabel.text = ""
        weatherDescriptionLabel.text = ""
        tempLabel.text = "スマイルボタンを\n押して天気を取得"
        weatherIconImageView.image = UIImage(named: "")
        
    }
    
    //pickerの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //pickerの行の列
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locationList.list.count
    }
    
    //pickerの列のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locationList.list[row].name
    }
    
    //pickerで選択した時
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        locationTextField.text = locationList.list[row].name
        
        //selectedLocationを初期化して代入
        selectedLocation = []
        selectedLocation.append(String(locationList.list[row].id))
        selectedLocation.append(locationList.list[row].name)
    }
}


//walkthroughを表示させるためのextension
extension AlternateViewController: EAIntroDelegate {
    
    //walkthroughを表示させるfunc
    @objc func showWalkthrough() {
        
        let page1 = EAIntroPage()
        page1.title = "インストールありがとうございます！！"
        page1.titleColor = UIColor.darkGray
        page1.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page1.desc = "天気を確認しつつ、家族や友人の安全を把握できるアプリです。"
        page1.descColor = UIColor.darkGray
        page1.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page1.bgColor = UIColor.init(red: 242 / 255, green: 255 / 255, blue: 220 / 255, alpha: 1)
        page1.bgImage = UIImage(named: "walkthrough1")
         
        let page2 = EAIntroPage()
        page2.title = "仲間を登録して安否をチェック！"
        page2.titleColor = UIColor.darkGray
        page2.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page2.desc = "ボタンを押すことで、登録しておいた相手の画面に自分の安否が反映されます。"
        page2.descColor = UIColor.darkGray
        page2.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page2.bgColor = UIColor.init(red: 207 / 255, green: 249 / 255, blue: 244 / 255, alpha: 1)
        page2.bgImage = UIImage(named: "walkthrough2")
         
        let page3 = EAIntroPage()
        page3.title = "一目で安否確認！"
        page3.titleColor = UIColor.darkGray
        page3.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page3.desc = "更新時刻に合わせて、画像が変化します"
        page3.descColor = UIColor.darkGray
        page3.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page3.bgColor = UIColor.init(red: 255 / 255, green: 222 / 255, blue: 231 / 255, alpha: 1)
        page3.bgImage = UIImage(named: "walkthrough3")
        
        let page4 = EAIntroPage()
        page4.title = "選べる２つのモード"
        page4.titleColor = UIColor.darkGray
        page4.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page4.desc = "通常モードでは、自分と登録した仲間の活動状況が確認できます。簡単モードでは自分の活動状況のみが表示されます。"
        page4.descColor = UIColor.darkGray
        page4.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page4.bgColor = UIColor.init(red: 252 / 255, green: 255 / 255, blue: 199 / 255, alpha: 1)
        page4.bgImage = UIImage(named: "walkthrough4")
        
        let page5 = EAIntroPage()
        page5.title = "通知機能でリマインド"
        page5.titleColor = UIColor.darkGray
        page5.titleFont = UIFont(name: "Helvetica-Bold", size: 20)
        page5.desc = "毎朝６時に自分の安否を更新するよう、通知します。"
        page5.descColor = UIColor.darkGray
        page5.descFont = UIFont(name: "HiraMaruProN-W4", size: 14)
        page5.bgColor = UIColor.init(red: 255 / 255, green: 253 / 255, blue: 235 / 255, alpha: 1)
        page5.bgImage = UIImage(named: "walkthrough5")
         
        //ここでページを追加
        let introView = EAIntroView(frame: self.view.bounds, andPages: [page1, page2, page3, page4, page5])
        //スキップボタン
        introView?.skipButton.tintColor = UIColor.darkGray
        introView?.skipButton.setTitle("スキップ", for: UIControl.State.normal)
        
        //ページコントロール
        introView?.pageControl.tintColor = UIColor.darkGray
         
        introView?.delegate = self
        introView?.show(in: self.view, animateDuration: 1.0)
        
    }
}

