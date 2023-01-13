//
//  ViewController.swift
//  Notifications
//
//  Created by Juan Carlos Rodriguez Yarmas on 12/01/23.
//

import UIKit
import AVFoundation
import UserNotifications

class ViewController: UIViewController, UITextViewDelegate {

    
    
    @IBOutlet weak var notificationTitle: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var message: UITextView!
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        message.delegate = self
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {allowed, error in
            if(!allowed){
                DispatchQueue.main.async {
                    self.enableNotifications()
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        message.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    

    func enableNotifications(){
        let alertController = UIAlertController(title: "Enable notifications", message : "You have allow notifications",preferredStyle: .alert)
        
        let openConfiguration = UIAlertAction(title: "Go to configuration", style: .default){_ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else{ return }
            
            if(UIApplication.shared.canOpenURL(settingsUrl)){
                UIApplication.shared.open(settingsUrl){
                    _ in
                    
                }
            }
        }
        
        alertController.addAction(openConfiguration)
        self.present(alertController, animated: true)
    }

    @IBAction func scheduleButton(_ sender: UIButton) {
        notificationCenter.getNotificationSettings{ settings in
            DispatchQueue.main.async{
                let title = self.notificationTitle.text ?? ""
                let message = self.message.text ?? ""
                let date = self.datePicker.date
                
                if settings.authorizationStatus == .authorized {
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request){
                        error in
                        if(error != nil){
                            print("Error \(error!.localizedDescription)")
                            return
                        }
                    }
                    
                    let alertController = UIAlertController(title: "Notification scheduled", message: "To: \(self.formattedDate(date: date))", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                        self.notificationTitle.text = ""
                        self.message.text = ""
                        self.datePicker.date = Date()
                        
                    }))
                    
                    self.present(alertController, animated: true)
                }else{
                    self.enableNotifications()
                }
            }
            
        }
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
}

