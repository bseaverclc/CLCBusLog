//
//  ViewController.swift
//  CLCBusLog
//
//  Not Created by CARL SHOW on 10/31/23. >:)
//
import UIKit
import FirebaseCore
import FirebaseFirestore
import CoreData
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var busView: UITableView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var bumpView: UIView!
    static var mid = 0
    static var busBuilder = [(busTendancy, String, busTendancy, String)]()
    // I really dislike that this needs to be static
    static var isDev = false
    var triedDev = false
    var canUpdate = true
    let password = "Testflight"
    let signifier = UIDevice.current.identifierForVendor?.uuidString
    var timerForShowScrollIndicator: Timer?
let div = Firestore.firestore().collection("busLog").document("info")
    
    override func viewDidLoad()
    {
        print(signifier!)
        busView.layer.cornerRadius = 20
        updateButton.layer.cornerRadius = 20
        editButton.layer.cornerRadius = 20
        fetch()
        busView.dataSource = self
        busView.delegate = self
        super.viewDidLoad()
        if ViewController.isDev
        {
            triedDev = true
        }
        busView.flashScrollIndicators()
        busView.indicatorStyle = UIScrollView.IndicatorStyle.white
        
       
        div.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
              print("Error fetching document: \(error!)")
              return
            }
            guard let data = document.data() else {
              print("Document data was empty.")
              return
            }
            
            ViewController.busBuilder = [(busTendancy, String, busTendancy, String)]()
            let leftBusNumbers = document.get("num1") as! [String]
            let rightBusNumbers = document.get("num2") as! [String]
            
            let leftPresentsText = document.get("inf1") as! [String]
            let rightPresentsText = document.get("inf2") as! [String]
            
            ViewController.mid = document.get("median") as! Int
            
            var leftBusTendency = [busTendancy]()
            var rightBusTendency = [busTendancy]()
            
            for value in leftPresentsText{
                switch value{
                case "p":
                    leftBusTendency.append(busTendancy.Present)
                case "o":
                    leftBusTendency.append(busTendancy.Occupied)
                case "":
                    leftBusTendency.append(busTendancy.Null)
                default:
                    print("error")
                }
            }
            for value in rightPresentsText{
                switch value{
                case "p":
                    rightBusTendency.append(busTendancy.Present)
                case "o":
                    rightBusTendency.append(busTendancy.Occupied)
                case "":
                    rightBusTendency.append(busTendancy.Null)
                default:
                    print("error")
                }
            }
            
            for spot in 0..<leftBusNumbers.count{
                ViewController.busBuilder.append((leftBusTendency[spot], leftBusNumbers[spot], rightBusTendency[spot], rightBusNumbers[spot]))
            }
            self.busView.reloadData()
            
          }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ViewController.busBuilder.count + 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.row
        {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Frontmost")!
            cell.layer.cornerRadius = 20
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3019238946)
            return cell
        case ViewController.mid + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Middlemost")!
            cell.layer.cornerRadius = 20
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3019238946)
            return cell
        case ViewController.busBuilder.count + 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Endmost")!
            cell.layer.cornerRadius = 20
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3019238946)
            return cell
        case _:
            let cell = tableView.dequeueReusableCell(withIdentifier: "busLane") as! customCell
            var cur = (busTendancy.Null, "", busTendancy.Null, "")
            cell.busSlotA.layer.cornerRadius = 20
            cell.busSlotB.layer.cornerRadius = 20
            if indexPath.row < ViewController.mid + 1
            {
                cur = ViewController.busBuilder[indexPath.row - 1]
            }
            else
            {
                cur = ViewController.busBuilder[indexPath.row - 2]
            }
            switch(cur.0)
            {
            case busTendancy.Null:
                cell.busSlotA.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2992400085)
                break
            case busTendancy.Occupied:
                cell.busSlotA.backgroundColor = #colorLiteral(red: 0.9132722616, green: 0.2695424259, blue: 0.4834814668, alpha: 0.6500318878)
                break
            case busTendancy.Present:
                cell.busSlotA.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
                break
            case _:
                print("Catastrophic error! DIV0 OF DUPLE FAILED IN CELL INSTANCIATION")
            }
            cell.busNameA.text = cur.1
            switch(cur.2)
            {
            case busTendancy.Null:
                cell.busSlotB.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2992400085)
                break
            case busTendancy.Occupied:
                cell.busSlotB.backgroundColor = #colorLiteral(red: 0.9132722616, green: 0.2695424259, blue: 0.4834814668, alpha: 0.6500318878)
                break
            case busTendancy.Present:
                cell.busSlotB.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
                break
            case _:
                print("Catastrophic error! DIV1 OF DUPLE FAILED IN CELL INSTANCIATION")
            }
            cell.busNameB.text = cur.3
            cell.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3019238946)
            cell.layer.cornerRadius = 20
            return cell
        }
    }
    @IBAction func update(_ sender: Any)
    {
        if canUpdate == true
        {
            canUpdate = false
            updateButton.backgroundColor = #colorLiteral(red: 0.1420087814, green: 0.02641401254, blue: 0.02643535472, alpha: 0.2024890988)
            UIView.animate(withDuration: 10.0)
            { [self] in
                updateButton.backgroundColor = #colorLiteral(red: 0.02908428758, green: 0.1822896004, blue: 0.382317543, alpha: 0.3520772771)
            } completion:
            { [self] _ in
                UIView.animate(withDuration: 0.2)
                { [self] in
                    updateButton.backgroundColor = UIColor.systemBlue
                } completion: { [self] _ in
                    canUpdate = true
                }
            }
            fetch()
            
        }
    }
    func devStep()
    {
        var exactID = false
        let div = Firestore.firestore().collection("authedDevices").document("developers")
        div.getDocument
        { (doc, err) in
            guard err == nil
            else { print("failed to substantiate Firestore: \(String(describing: err))"); return }
            if let val = doc?.data(), ((doc?.exists) != nil)
            {
                var idV = [String]()
                for d in val
                {
                    idV.append(d.value as! String)
                }
                for id in idV
                {
                    if self.signifier == id
                    {
                        ViewController.isDev = true
                        exactID = true
                        break
                    }
                }
            }
            self.triedDev = true
            if exactID
            {
                self.performSegue(withIdentifier: "developer", sender: Any?.self)
            }
            else
            {
                self.developer((Any).self)
            }
        }
    }
    @IBAction func developer(_ sender: Any)
    {
        if !triedDev
        {
            devStep()
        }
        else if ViewController.isDev
        {
            self.performSegue(withIdentifier: "developer", sender: Any?.self)
        }
        else
        {
            let alert = UIAlertController(title: "Edit Bus Lines", message: "In order to edit busses, enter a password here", preferredStyle: UIAlertController.Style.alert)
            let passFail = UIAlertController(title: "Invalid Password", message: "Please try again", preferredStyle: UIAlertController.Style.alert)
            let passWin = UIAlertController(title: "Successfully Authendicated", message: "You now have access to Developer Mode", preferredStyle: UIAlertController.Style.alert)
            passFail.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default))
            passWin.addAction(UIAlertAction(title: "Begin", style: UIAlertAction.Style.default, handler: { UIAlertAction in
                self.performSegue(withIdentifier: "developer", sender: Any?.self)
            }))
            alert.addTextField()
            alert.addAction(UIAlertAction(title: "Submit", style: UIAlertAction.Style.default, handler: { UIAlertAction in
                if alert.textFields![0].text == self.password
                {
                    ViewController.isDev = true
                    self.present(passWin, animated: true)
                    let div = Firestore.firestore().collection("authedDevices").document("developers")
                    div.setData(["\(UIDevice.current.debugDescription)" : self.signifier!], merge: true)
                }
                else
                {
                    self.present(passFail, animated: true)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
            self.present(alert, animated: true)
        }
    }
    func fetch()
    {
        let prot = ViewController.busBuilder
        ViewController.busBuilder.removeAll()
        ViewController.mid = 0
        div.getDocument { (doc, err) in
            guard err == nil
            else { print("failed to substantiate Firestore: \(String(describing: err))"); return }
            if let val = doc, ((doc?.exists) != nil)
            {
                var numA = [String]()
                var numB = [String]()
                var tenA = [busTendancy]()
                var tenB = [busTendancy]()
                let data = val.data()
                var r = 0
                for d in data!
                {
                    switch d.key
                    {
                    case "num1":
                        for v in d.value as! [String]
                        {
                            numA.append(v)
                        }
                    case "num2":
                        for v in d.value as! [String]
                        {
                            numB.append(v)
                        }
                    case "inf1":
                        for v in d.value as! [String]
                        {
                            switch v
                            {
                            case "p":
                                tenA.append(busTendancy.Present)
                            case "o":
                                tenA.append(busTendancy.Occupied)
                            case _:
                                tenA.append(busTendancy.Null)
                            }
                        }
                    case "inf2":
                        for v in d.value as! [String]
                        {
                            switch v
                            {
                            case "p":
                                tenB.append(busTendancy.Present)
                            case "o":
                                tenB.append(busTendancy.Occupied)
                            case _:
                                tenB.append(busTendancy.Null)
                            }
                        }
                    case "median":
                        ViewController.mid = d.value as! Int
                    case _:
                        print("ALERT: Firestore is reading garbage data")
                    }
                    r += 1
                }
                for x in 0..<numA.count
                {
                    if tenA[x] == busTendancy.Null && numA[x] != ""
                    {
                        numA[x] = ""
                    }
                    if tenB[x] == busTendancy.Null && numB[x] != ""
                    {
                        numB[x] = ""
                    }
                }
                if numA.count == numB.count && tenA.count == tenB.count && tenA.count == numA.count
                {
                    for x in 0..<numA.count
                    {
                        ViewController.busBuilder.append((tenA[x], numA[x], tenB[x], numB[x]))
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "Unfinished update in progress", message: "Sorry, but a new update is in progress\n\nPlease wait before trying again.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default))
                    ViewController.busBuilder = prot
                    self.present(alert, animated: true)
                }
            }
            self.busView.reloadData()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

    super.viewDidAppear(animated)

    startTimerForShowScrollIndicator()

    }
    
    override func viewDidDisappear(_ animated: Bool) {

    super.viewDidDisappear(animated)

    stopTimerForShowScrollIndicator()

    }
    
    func startTimerForShowScrollIndicator() {

            self.timerForShowScrollIndicator = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.showScrollIndicators), userInfo: nil, repeats: true)

        }
    
    
    @objc func showScrollIndicators() {

    UIView.animate(withDuration: 0.0001) {

    self.busView.flashScrollIndicators()

    }

    }
    func stopTimerForShowScrollIndicator() {

    self.timerForShowScrollIndicator?.invalidate()

    self.timerForShowScrollIndicator = nil

    }
    
    
    
    
    
    
}
