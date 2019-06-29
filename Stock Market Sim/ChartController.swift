//
//  ChartController.swift
//  Stock Market Sim
//
//  Created by Anish Roy on 3/30/19.
//  Copyright © 2019 Anish's Team. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Charts
import SwiftyJSON


var prices = [Double]()
var dates = [Date]()
class ChartController: UIViewController {
    
    @IBOutlet weak var lineChartView: LineChartView!
    var referenceTimeInterval: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPrices(symbol: symbol){
                (result: String) in
        }
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.lineChartView.addGestureRecognizer(gesture)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func checkAction(_ sender:UITapGestureRecognizer){
       print("tapped")
       print(sender.location(in: lineChartView))
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
                            if (stock == "1. open") {
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
                self.orderPrices()
                self.setChartValues(dates: dates)
        }
        completion("we finished!")
        
    }
    
    func orderPrices(){
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let sortedArrayOfDicts = pairs.map{(df.date(from: $0.key)!, [$0.key:$0.value])}  .sorted{$0.0 < $1.0}.map{$1}
        for item in sortedArrayOfDicts {
            print(item)
            stockPrices.append(StockPrice(p : item.values.randomElement()!, d : df.date(from: item.keys.randomElement()!)!))
            prices.append(Double(item.values.randomElement()!)!)
            dates.append(df.date(from: item.keys.randomElement()!)!)
        }
    }
    
    
    
    func setChartValues(dates : [Date]){
        // 1 - creating an array of data entries
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for  i in 0...(dates.count - 1){
            yVals1.append(ChartDataEntry(x: Double(i), y: prices[i]))
        }
            
        let set1 = LineChartDataSet(values: yVals1, label : "DataSet")
        set1.drawCirclesEnabled = false
        set1.drawFilledEnabled = true
        let gradientColors = [UIColor.cyan.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        set1.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)// Set the Gradient
        
        let data = LineChartData(dataSet: set1)
        self.lineChartView.data = data
        self.lineChartView.legend.enabled = false
        self.lineChartView.xAxis.enabled = false
        self.lineChartView.rightAxis.enabled = false
        self.lineChartView.doubleTapToZoomEnabled = false
        
    //    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    //    lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        lineChartView.xAxis.granularity = 1
        lineChartView.setVisibleXRange(minXRange: 10.0, maxXRange: 100.0)
    }
    

}

class StockPrice {
    var price : Double
    var priceString : String
    var date : Date
    var dateString : String
    
    init(){
        price = 0.0
        priceString = ""
        date = Date()
        dateString = ""
    }
    
    func setStuff(p : String, d : String) {
        priceString = p
        dateString = d
        price = Double(priceString)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-DD"
        date = dateFormatter.date(from: dateString)!
    }
    
    init(p : String, d : Date) {
        priceString = p
        date = d
        price = Double(priceString)!
        dateString = ""
    }
    
    func setStuff(p : String) {
        priceString = p
        price = Double(priceString)!
    }
}

class MarkerView: UIView {
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var metricLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
}
