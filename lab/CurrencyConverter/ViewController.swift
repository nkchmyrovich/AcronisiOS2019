//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Nikita Khmurovich on 13/04/2019.
//  Copyright © 2019 Nikita Khmurovich. All rights reserved.
//

import UIKit

class Searcher
{
    var currencies = [String(), String()]
    var m_url:URL
    var m_urlSession:URLSession
    
    init(_ base: String, current: String) {
        currencies[0] = base
        currencies[1] = current
        m_url = URL(string: "https://api.exchangeratesapi.io/latest?base=CHF")!
        m_urlSession = URLSession.shared
        
        //now create the URLRequest object using the url object
    }
    func HttpsRequest(_ view: ViewController) -> Void
    {
        weak var weakView = view
        let Request = URLRequest(url: m_url)
        let task = m_urlSession.dataTask(with: Request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if let array = json["rates"] as? [String:Double]
                    {
                        DispatchQueue.main.sync{[weak that = weakView] in
                            that!.Output.text = String(array[that!.m_searcher.currencies[1]]! / array[that!.m_searcher.currencies[0]]!)
                            that!.StatusIndicator.stopAnimating()
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.CurrencyList.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        m_searcher.currencies[CurrencyPicker.index(of: pickerView)!] = CurrencyList[row]
        
        StatusIndicator.startAnimating()
        Output.text = ""
        m_searcher.HttpsRequest(self)
        
        return CurrencyList[row]
    }

    
    @IBOutlet weak var Output: UILabel!

    @IBOutlet weak var StatusIndicator: UIActivityIndicatorView!
    @IBOutlet var CurrencyPicker: [UIPickerView]!
    let CurrencyList = ["RUB", "EUR", "USD"]
    var m_searcher: Searcher = Searcher("RUB", current: "RUB")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        for element in self.CurrencyPicker
        {
            element.dataSource = self
            element.delegate = self
        }
    }
}
