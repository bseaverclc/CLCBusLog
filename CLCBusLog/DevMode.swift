//
//  DevMode.swift
//  CLCBusLog
//
//  Created by CARL SHOW on 11/16/23.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore

class DevMode: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var drag: UIPanGestureRecognizer!
    @IBOutlet var tempView: UIView!
    @IBOutlet weak var stepir: UIStepper!
    @IBOutlet weak var busView: UITableView!
    @IBOutlet weak var inserterView: UITableView!
    @IBOutlet weak var commitButton: UIButton!
    
    var focalCell = (UITableView(), -1, false)
    var busOptions = [String]()
    var permanentBuses = [String]()
    var target = -1
    var uncomittedChanges = false
    var userStandards = UserDefaults()
    let div = Firestore.firestore().collection("busLog").document("info")
    
    override func viewDidLoad()
    {
        
        busOptions = userStandards.stringArray(forKey: "busOptions") ?? ["400", "401", "402", "403", "404", "405", "406", "407", "408", "410", "411", "412", "413"]
        permanentBuses = userStandards.stringArray(forKey: "permanentOptions") ?? ["400", "401", "402", "403", "404", "405", "406", "407", "408", "410", "411", "412", "413"]
        
        busView.dataSource = self
        busView.delegate = self
        busView.layer.cornerRadius = 20
        inserterView.dataSource = self
        inserterView.delegate = self
        inserterView.layer.cornerRadius = 20
        commitButton.layer.cornerRadius = 20
        commitButton.isUserInteractionEnabled = false
        tempView.layer.cornerRadius = 20
        stepir.maximumValue = Double(ViewController.busBuilder.count)
        stepir.value = Double(ViewController.mid)
        
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
            
            for i in stride(from: self.busOptions.count - 1, to: 0, by: -1){
                
                for n in 0..<ViewController.busBuilder.count{
                    if(ViewController.busBuilder[n].1 == self.busOptions[i] || ViewController.busBuilder[n].3 == self.busOptions[i]){
                        self.busOptions.remove(at: i)
                        break
                    }
                }
                
                
            }

            self.inserterView.reloadData()
            
            
          }
    }
    
    
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == busView
        {
            return ViewController.busBuilder.count + 3
        }
        else
        {
            return busOptions.count + 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == busView
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
                cell.layer.cornerRadius = 20
                cell.busSlotA.layer.cornerRadius = 20
                cell.busSlotB.layer.cornerRadius = 20
                cell.pointer = indexPath.row
                var cur = (busTendancy.Null, "", busTendancy.Null, "")
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
                cell.snubView.frame.size = CGSize()
                cell.snubView.layer.cornerRadius = 20
                cell.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3019238946)
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                cell.layer.cornerRadius = 20
                return cell
            }
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bus") as! customBus
            cell.layer.cornerRadius = 20
            cell.pointer = indexPath.row
            switch indexPath.row
            {
            case 0:
                cell.impliedBus.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2992400085)
                cell.impliedName.text = ""
            case 1:
                cell.impliedBus.backgroundColor = #colorLiteral(red: 0.9132722616, green: 0.2695424259, blue: 0.4834814668, alpha: 0.6500318878)
                cell.impliedName.text = ""
            default:
                cell.impliedBus.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
                cell.impliedName.text = busOptions[indexPath.row - 2]
            }
            cell.impliedBus.layer.cornerRadius = 20
            cell.backgroundColor = #colorLiteral(red: 0, green: 0.9909093976, blue: 0, alpha: 0)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 2 && tableView == inserterView
        {
            target = indexPath.row - 2
        }
    }
    // This segment designates how dragged elements behave
    @IBAction func didDrag(_ sender: UIPanGestureRecognizer)
    {
        let translation = sender.location(in: view)
        if sender.state.rawValue == 1
        {
            if inserterView.frame.contains(translation)
            {
                // This if statement checks if the drag's start is within the 'inserterView'
                var tries = 0
                for x in inserterView.visibleCells
                {
                    let y = x as! customBus
                    let xCheck = translation.x - inserterView.frame.minX
                    let yCheck = translation.y - inserterView.frame.minY + inserterView.bounds.minY
                    if(x.frame.contains(CGPoint(x: xCheck, y: yCheck)))
                    {
                        tempView.isHidden = false
                        tempView.center = translation
                        UIView.animate(withDuration: 0.20, animations: { [self] in
                            tempView.frame.size.width = 75
                            tempView.frame.size.height = 75
                            tempView.center = translation
                        })
                        tempView.backgroundColor = y.impliedBus.backgroundColor
                        // designates the pointer within the 'inserterView'
                        if y.pointer == 0
                        {
                            focalCell = (inserterView, 0, true)
                        }
                        else if y.pointer == 1
                        {
                            focalCell = (inserterView, 1, true)
                        }
                        else
                        {
                            focalCell = (inserterView, y.pointer-2, false)
                        }
                        break
                    }
                    tries += 1
                }
            }
            else if busView.frame.contains(translation)
            {
                // This runs if the drag's start is within the 'busView'
                for x in busView.visibleCells
                {
                    if let y = x as? customCell
                    {
                        let xCheck = translation.x - busView.frame.minX
                        let yCheck = translation.y - busView.frame.minY + busView.bounds.minY
                        if(x.frame.contains(CGPoint(x: xCheck, y: yCheck)) && x.reuseIdentifier == "busLane")
                        {
                            var target = 0
                            tempView.isHidden = false
                            tempView.center = translation
                            UIView.animate(withDuration: 0.20, animations: { [self] in
                                tempView.frame.size.width = 75
                                tempView.frame.size.height = 75
                                tempView.center = translation
                            })
                            target = y.pointer
                            // Determines the cell's position in the array without the added cells within the tableview
                            if target <= ViewController.mid
                            {
                                target -= 1
                            }
                            else
                            {
                                target -= 2
                            }
                            // determines the exact cell within the array
                            if translation.x < busView.frame.midX
                            {
                                tempView.backgroundColor = y.busSlotA.backgroundColor
                                focalCell = (busView, target, false)
                            }
                            else
                            {
                                tempView.backgroundColor = y.busSlotB.backgroundColor
                                focalCell = (busView, target, true)
                            }
                        }
                    }
                }
            }
        }
        else if sender.state.rawValue == 2
        {
            // Simply, this elseif checks if the drag is still ongoing
            tempView.center = translation
        }
        else
        {
            var bus = ViewController.busBuilder
            // Once the drag ends, this chunk of code occurs
            if busView.frame.contains(translation)
            {
                for x in busView.visibleCells
                {
                    let xCheck = translation.x - busView.frame.minX
                    let yCheck = translation.y - busView.frame.minY + busView.bounds.minY
                    if(x.frame.contains(CGPoint(x: xCheck, y: yCheck)) && !tempView.isHidden)
                    {
                        tempView.center = translation
                        var target = (0, false)
                        if let y = x as? customCell
                        {
                            // Determines the targeted cell's location in the array
                            if(translation.x < busView.frame.midX)
                            {
                                target.0 = y.pointer
                                target.1 = false
                            }
                            else
                            {
                                target.0 = y.pointer
                                target.1 = true
                            }
                            if target.0 <= ViewController.mid
                            { target.0 -= 1 }
                            else
                            { target.0 -= 2 }
                            var z = customCell()
                            if focalCell.0 == inserterView
                            {
                                // Checks if the previous tableView was the 'inserterView'
                                var temp = (busTendancy.Null, "")
                                if focalCell.2
                                {
                                    if focalCell.1 == 0
                                    { temp.0 = busTendancy.Null }
                                    else
                                    { temp.0 = busTendancy.Occupied }
                                }
                                else
                                {
                                    temp.0 = busTendancy.Present
                                    temp.1 = busOptions[focalCell.1]
                                }
                                // Sets 'temp' to the 'busBuilder's location defined by 'target'
                                if !target.1
                                { 
                                    bus[target.0].0 = temp.0
                                    bus[target.0].1 = temp.1
                                }
                                else
                                {
                                    bus[target.0].2 = temp.0
                                    bus[target.0].3 = temp.1
                                }
                            }
                            else
                            {
                                // Preferably, this would be an 'else if'; however, it is impossible to *not* target a table view while doing this segment.
                                // Checks if the previous tableView was the 'busView'
                                var temp = (busTendancy.Null, "")
                                print("(\(focalCell.1), \(focalCell.2)), \(target)")
                                if !focalCell.2
                                {
                                    temp.0 = bus[focalCell.1].0
                                    temp.1 = bus[focalCell.1].1
                                }
                                else
                                {
                                    temp.0 = bus[focalCell.1].2
                                    temp.1 = bus[focalCell.1].3
                                }
                                print(temp)
                                if !target.1
                                {
                                    let target2 = (bus[target.0].0, bus[target.0].1)
                                    if !focalCell.2
                                    {
                                        bus[focalCell.1].0 = target2.0
                                        bus[focalCell.1].1 = target2.1
                                    }
                                    else
                                    {
                                        bus[focalCell.1].2 = target2.0
                                        bus[focalCell.1].3 = target2.1
                                    }
                                    bus[target.0].0 = temp.0
                                    bus[target.0].1 = temp.1
                                }
                                else
                                {
                                    let target2 = (bus[target.0].2, bus[target.0].3)
                                    if !focalCell.2
                                    {
                                        bus[focalCell.1].0 = target2.0
                                        bus[focalCell.1].1 = target2.1
                                    }
                                    else
                                    {
                                        bus[focalCell.1].2 = target2.0
                                        bus[focalCell.1].3 = target2.1
                                    }
                                    bus[target.0].2 = temp.0
                                    bus[target.0].3 = temp.1
                                }
                                if focalCell.1 < ViewController.mid
                                {
                                    z = busView.cellForRow(at: IndexPath(row: focalCell.1 + 1, section: 0))! as! customCell
                                }
                                else
                                {
                                    z = busView.cellForRow(at: IndexPath(row: focalCell.1 + 2, section: 0))! as! customCell
                                }
                            }
                            var ySmidge = 0.0
                            let yConst = busView.frame.minY - busView.bounds.minY + y.stacker.frame.minY
                            if y.pointer > ViewController.mid
                            { ySmidge = yConst + 16 }
                            else
                            { ySmidge = yConst + y.busSlotA.frame.height + 4 }
                            if focalCell.0 == busView
                            {
                                z.snubView.isHidden = false
                                if !target.1
                                { z.snubView.backgroundColor = y.busSlotA.backgroundColor?.withAlphaComponent(0.0) }
                                else
                                { z.snubView.backgroundColor = y.busSlotB.backgroundColor?.withAlphaComponent(0.0) }
                                if !focalCell.2
                                { z.snubView.center = CGPoint(x: z.busSlotA.frame.midX + z.stacker.frame.minX, y: z.busSlotA.frame.midY + z.stacker.frame.minY) }
                                else
                                { z.snubView.center = CGPoint(x: z.busSlotB.frame.midX + z.stacker.frame.minX, y: z.busSlotB.frame.midY + z.stacker.frame.minY) }
                            }
                            ViewController.busBuilder = bus
                            let yMod = ySmidge + CGFloat(y.pointer - 1) * y.frame.height
                            // From here on out is the animations for the components
                            UIView.animate(withDuration: 0.60, animations: { [self] in
                                tempView.frame = y.busSlotA.frame
                                tempView.backgroundColor = tempView.backgroundColor?.withAlphaComponent(1.0)
                                if translation.x < busView.frame.midX
                                { tempView.center = CGPoint(x: y.busSlotA.center.x + busView.frame.minX + y.stacker.frame.minX, y: yMod) }
                                else
                                { tempView.center = CGPoint(x: y.busSlotB.center.x + busView.frame.minX + y.stacker.frame.minX, y: yMod) }
                                if focalCell.0 == busView
                                {
                                    z.snubView.backgroundColor = z.snubView.backgroundColor?.withAlphaComponent(y.busSlotA.alpha)
                                    z.snubView.frame = z.busSlotA.frame
                                    if !focalCell.2
                                    { z.snubView.center = CGPoint(x: z.busSlotA.frame.midX + z.stacker.frame.minX, y: z.busSlotA.frame.midY + z.stacker.frame.minY) }
                                    else
                                    { z.snubView.center = CGPoint(x: z.busSlotB.frame.midX + z.stacker.frame.minX, y: z.busSlotB.frame.midY + z.stacker.frame.minY) }
                                }
                            }, completion: { [self]_ in
                                UIView.animate(withDuration: 0.4, animations: { [self] in
                                    tempView.backgroundColor = tempView.backgroundColor?.withAlphaComponent(0.0)
                                    busView.reloadData()
                                }, completion: { [self]_ in
                                    tempView.isHidden = true
                                    tempView.frame.origin = CGPoint(x: -75, y: -75)
                                    tempView.frame.size = CGSize()
                                })
                            })
                        }
                        else
                        {
                            UIView.animate(withDuration: 0.20, animations: { [self] in
                                tempView.frame.size = CGSize()
                                tempView.center = translation
                            }, completion: { [self]_ in
                                tempView.isHidden = true
                                tempView.frame.origin = CGPoint(x: -75, y: -75)
                            })
                        }
                    }
                }
                changedSomething()
            }
            else
            {
                UIView.animate(withDuration: 0.20, animations: { [self] in
                    tempView.frame.size.width = 0
                    tempView.frame.size.height = 0
                    tempView.center = translation
                }, completion: { [self]_ in
                    tempView.isHidden = true
                    tempView.frame.origin = CGPoint(x: -75, y: -75)
                })
            }
            focalCell = (UITableView(), -1, false)
        }
    }
    @IBAction func addBus(_ sender: Any)
    {
        let alert = UIAlertController(title: "Add a bus:", message: "", preferredStyle: .alert)
        
        alert.addTextField{
            (textField) in
            textField.placeholder = "Bus Number"
            textField.keyboardType = .asciiCapableNumberPad
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default, handler: { UIAlertAction in
            let text = alert.textFields![0].text!
            var valid = true
            var isText = true
            
            for char in text {
                if !char.isNumber {
                    isText = false
                    break
                }
            }
            
            if text.isEmpty || !isText {
                valid = false
                let alert2 = UIAlertController(title: "Please enter a bus number", message: "", preferredStyle: .alert)
                alert2.addAction(UIKit.UIAlertAction(title: "Ok", style: .default))
                self.present(alert2, animated: true)
            }
            
            if valid {
                self.busOptions.insert(alert.textFields![0].text!, at: 0)
                self.userStandards.set(self.busOptions, forKey: "busOptions")
                self.permanentBuses = self.busOptions
                self.userStandards.setValue(self.permanentBuses, forKey: "permanentOptions")
                self.inserterView.reloadData()
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
        self.present(alert, animated: true)
    
    }
    @IBAction func deleteBus(_ sender: Any) 
    {
        if target >= 0
        {
            let alert = UIAlertController(title: "Are you sure you want to delete bus \(busOptions[target])?", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Remove", style: UIAlertAction.Style.default, handler: { UIAlertAction in
                self.busOptions.remove(at: self.target)
                self.userStandards.set(self.busOptions, forKey: "busOptions")
                self.permanentBuses = self.busOptions
                self.userStandards.setValue(self.permanentBuses, forKey: "permanentOptions")
                self.target = -1
                self.inserterView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
            self.present(alert, animated: true)
        }
        else
        {
            let alert = UIAlertController(title: "No bus selected to delete", message: "Make sure to click on a bus.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default))
            self.present(alert, animated: true)
        }
    }
    @IBAction func addRow(_ sender: Any) 
    {
        ViewController.busBuilder.append((busTendancy.Null, "", busTendancy.Null, ""))
        busView.reloadData()
        stepir.maximumValue = Double(ViewController.busBuilder.count)
        changedSomething()
    }
    @IBAction func removeRow(_ sender: Any) 
    {
        if ViewController.busBuilder.count > 0
        {
            if ViewController.busBuilder.count == ViewController.mid
            {
                ViewController.mid -= 1
            }
            ViewController.busBuilder.removeLast()
            busView.reloadData()
        }
        else
        {
            let alert = UIAlertController(title: "Cannot remove row", message: "There are currently no rows to delete", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default))
            self.present(alert, animated: true)
        }
        changedSomething()
        stepir.maximumValue = Double(ViewController.busBuilder.count)
    }
    @IBAction func stepMid(_ sender: UIStepper)
    {
        ViewController.mid = Int(sender.value)
        busView.reloadData()
        changedSomething()
    }
    func changedSomething()
    {
        UIView.animate(withDuration: 0.5, animations: { [self] in
            commitButton.backgroundColor = UIColor.systemBlue
            busView.backgroundColor = #colorLiteral(red: 0.5013468862, green: 0.4937239885, blue: 0, alpha: 0.3008872335)
        })
        
        var shouldBreak = false
        
        for var i in 0..<self.busOptions.count {
            for a in 0..<ViewController.busBuilder.count {
                if ViewController.busBuilder[a].1 == self.busOptions[i] || ViewController.busBuilder[a].3 == self.busOptions[i] {
                    print(busOptions.count)
                    print(a)
                    self.busOptions.remove(at: i)
                    i -= 1
                    shouldBreak = true
                    break
                }
            }
            if(shouldBreak){break}
        }

        inserterView.reloadData()
        
        commitButton.isUserInteractionEnabled = true
    }
    @IBAction func commit(_ sender: Any)
    {
        var listOne = [String]()
        var listTwo = [String]()
        var nameOne = [String]()
        var nameTwo = [String]()
        for x in ViewController.busBuilder
        {
            nameOne.append(x.1)
            nameTwo.append(x.3)
            switch x.0
            {
            case busTendancy.Present:
                listOne.append("p")
            case busTendancy.Occupied:
                listOne.append("o")
            default:
                listOne.append("")
            }
            switch x.2
            {
            case busTendancy.Present:
                listTwo.append("p")
            case busTendancy.Occupied:
                listTwo.append("o")
            default:
                listTwo.append("")
            }
            UserDefaults.standard.setValue(busOptions, forKey: "busOptions")
        }
        div.setData(["inf1" : listOne, "inf2" : listTwo, "num1" : nameOne, "num2" : nameTwo, "median" : ViewController.mid, "signature" : UIDevice.current.identifierForVendor?.uuidString as Any])
        UIView.animate(withDuration: 0.5, animations: { [self] in
            commitButton.backgroundColor = #colorLiteral(red: 0.1420087814, green: 0.02641401254, blue: 0.02643535472, alpha: 0.2024890988)
            busView.backgroundColor = #colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2025403912)
        })
        commitButton.isUserInteractionEnabled = false
    }
    @IBAction func returnToSender(_ sender: Any) 
    {
        performSegue(withIdentifier: "coolio", sender: Any?.self)
    }
    
    @IBAction func clearAllAction(_ sender: UIButton) {
        
        for i in 0..<ViewController.busBuilder.count {
            ViewController.busBuilder[i].0 = .Null
            ViewController.busBuilder[i].1 = ""
            ViewController.busBuilder[i].2 = .Null
            ViewController.busBuilder[i].3 = ""
        }
        busOptions = permanentBuses
        inserterView.reloadData()
        busView.reloadData()
        changedSomething()
        
    }
    
    
}
