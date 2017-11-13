//
//  ViewController.swift
//  Mega Pedometer App
//
//  Created by Trevor Beaton on 7/5/17.
//  Copyright © 2017 Vanguard Logic LLC. All rights reserved.
//

import UIKit
import CoreMotion
class ViewController: UIViewController {
    

    @IBOutlet weak var steps: UILabel!
    
    @IBOutlet weak var activityState: UILabel!
    
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    
    var pedometerData: Float!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.system
        cal.timeZone = timeZone
        
        let midnightOfToday = cal.date(from: comps)
            
                   
        if(CMMotionActivityManager.isActivityAvailable()){
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: { (data: CMMotionActivity!) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if(data.stationary == true){
                        self.activityState.text = "Stationary"
                    
                    } else if (data.walking == true){
                        self.activityState.text = "Walking"
                      
                    } else if (data.running == true){
                        self.activityState.text = "Running"
                        
                    } else if (data.automotive == true){
                        self.activityState.text = "Automobile or Transit Service"
                    }
                })
                
            })
        }
      
            if(CMPedometer.isStepCountingAvailable()){
            let fromDate = NSDate(timeIntervalSinceNow: -86400 * 7)
            
            self.pedometer.queryPedometerData(from: fromDate as Date, to: NSDate() as Date) { (data : CMPedometerData!, error) -> Void in
                print(data)
                DispatchQueue.main.async(execute: { () -> Void in
                    if(error == nil){
                        self.steps.text = "\(String(describing: data.distance))"
                        
                    }
                })
                
            }
            
            self.pedometer.startUpdates(from: midnightOfToday!) { (data: CMPedometerData!, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if(error == nil){
                        self.steps.text = "\(String(describing: data.numberOfSteps))"
                         self.pedometerData = data.numberOfSteps.floatValue

                        self.postPedometer()
                    }
                })
            }
        }
    }
   
    
    
    
    func postPedometer() {
        
        let parameters = ["value": "\(String(format: "%.0f", (pedometerData)!))"]
       
        guard let url = URL(string: "https://io.adafruit.com/api/feeds/text-feed/data.json?X-AIO-Key=c04d002a910e4eff85e6b83203d4e287") else { return }
       
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            
            }.resume()
    }
    

}
