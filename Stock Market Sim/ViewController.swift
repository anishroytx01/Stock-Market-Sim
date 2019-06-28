//
//  ViewController.swift
//  StockMarketSimulator
//
//  Created by ANISH ROY on 8/31/18.
//  Copyright © 2018 ANISH ROY. All rights reserved.

import UIKit

import Alamofire
import Charts
import SwiftyJSON

var matches = [String : String]()
var symbols = [String]()
var names = [String]()
var stockPrices = [StockPrice]()
var pairs = [String : String]()
var symbol : String = ""

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var stockSearchTable: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var optionsLabel: UILabel!
    var arrRes = [[String:AnyObject]]()

    @IBAction func searchTicker(_ sender: Any) {
        getSymbolName(search: searchText.text!)
        optionsLabel.text = searchText.text
        self.stockSearchTable.reloadData()
        //  optionsLabel.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stockSearchTable.dataSource = self
        stockSearchTable.delegate = self
        optionsLabel.isHidden = true
        self.stockSearchTable.backgroundColor = UIColor.green
        
    }
    
    func getPrices(symbol: String, completion: (_ result: String) -> Void){
        Alamofire.request("https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&interval=60min&apikey=VZA92LIIUOR0HG08").responseJSON
            { response in
                var values = [String : String]()
                if let result =  response.result.value {
                    let json = JSON(result)
                    //print(result)
                    let times = json["Time Series (Daily)"]
                    for (key, value) in times {
                        // print("key \(key) value \(value)")
                        for (stock, price) in value {
                            //  print("\(stock) + \(price)")
                            if (stock == "4. close") {
                                values[key] = "\(price)"
                                
                                let stock = StockPrice()
                                stock.setStuff(p: "\(price)", d: key)
                                stockPrices.append(stock)
                            }
                        }
                    }
                }
                print(values)
                pairs = values
        }
        completion("we finished!")
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        print(searchText.text!)
        symbol = (stockSearchTable.cellForRow(at: (stockSearchTable?.indexPathForSelectedRow)!)?.textLabel?.text!)!
       // getPrices(symbol: (stockSearchTable.cellForRow(at: (stockSearchTable?.indexPathForSelectedRow)!)?.textLabel?.text!)!){
       //     (result: String) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let chartController = storyBoard.instantiateViewController(withIdentifier: "ChartController")
            self.present(chartController, animated: true, completion: nil)
       // }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
        //matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = stockSearchTable.dequeueReusableCell(withIdentifier: "StockCell", for: indexPath)
        let cellIdentifier = "StockCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        cell?.textLabel?.textAlignment = .center
        cell?.backgroundColor = UIColor.clear
        if cell == nil {
            cell?.textLabel?.textAlignment = .center
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value2, reuseIdentifier: cellIdentifier)
        }
        
        if matches.count > 0 {
            cell?.textLabel?.text = "\(Array(matches)[indexPath.row].value)"
            cell?.detailTextLabel?.text = "\(Array(matches)[indexPath.row].key)"
        }
        
        return cell!
    }
    
    func getSymbolName(search: String) {
        matches.removeAll()
        symbols.removeAll()
        names.removeAll()
        var datum = [JSON]()
        if(search != ""){
            Alamofire.request("https://lookup.now.sh/\(search)").responseJSON
                { response in
                    if let result =  response.result.value {
                        let json = JSON(result)
                        let searches = json["ResultSet"]
                        for (_, value) in searches {
                            for(_, data) in value{
                                for(_,b) in data {
                                    if (b == "NAS" || b == "NYQ" || b == "NYS" || b == "NMS") {
                                        datum.append(data)
                                    }
                                }
                            }
                        }
                        for json in datum {
                            for (a,b) in json {
                                if (a == "name") {
                                    names.append("\(b)")
                                }
                                if (a == "symbol") {
                                    symbols.append("\(b)")
                                }
                            }
                        }
                        if (symbols.count > 0){
                            for i in 0...(symbols.count - 1){
                                matches[names[i]] = symbols[i]
                            }
                            //print(matches)
                            self.optionsLabel.text = "\(matches)"
                            self.stockSearchTable.reloadData()
                        }
                    }
            }
        }
    }
    
    func jsonToString(json: JSON) -> String {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString ?? "Default Value")
            return (convertedString ?? "Default Value")
        } catch let myJSONError {
            print(myJSONError)
        }
        return "Default Value"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(red: 230, green: 240, blue: 94, alpha: 0.5)
        currentCell?.selectedBackgroundView = bgColorView
        print("HI")
        print(currentCell?.textLabel?.text! ?? "LUL")
        
        //
        //currentCell!.selectedBackgroundView = bgColorView
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?
    fileprivate var referenceTimeInterval: TimeInterval?
    
    convenience init(referenceTimeInterval: TimeInterval, dateFormatter: DateFormatter) {
        self.init()
        self.referenceTimeInterval = referenceTimeInterval
        self.dateFormatter = dateFormatter
    }
}


extension ChartXAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter,
            let referenceTimeInterval = referenceTimeInterval
            else {
                return ""
        }
        
        let date = Date(timeIntervalSince1970: value * 3600 * 24 + referenceTimeInterval)
        return dateFormatter.string(from: date)
    }
}

