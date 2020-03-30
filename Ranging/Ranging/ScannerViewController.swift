//
//  ScannerViewController.swift
//  Ranging
//
//  Created by ketan on 26/03/20.
//  Copyright © 2020 ELEK. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import UserNotifications
import AVFoundation

class ScannerViewController: UIViewController, CLLocationManagerDelegate, CBPeripheralManagerDelegate {

    var locationManager: CLLocationManager?
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var soundEffect: AVAudioPlayer?
    let notificationCenter = UNUserNotificationCenter.current()
    var beaconRegion: CLBeaconRegion?
    
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var switchEnableRanging: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Alert"
        content.body = "Someone is near you!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "red_alert.mp3"))
        content.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "Local Notification"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            startScanning()
            initLocalBeacon()
        } else {
            stopMonitoring()
        }
    }
    
    func stopMonitoring() {
        lblCount.text = "0"
        locationManager?.stopMonitoring(for: beaconRegion!)
        locationManager?.stopRangingBeacons(in: beaconRegion!)
        stopLocalBeacon()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "elek.Ranging")

        locationManager?.startMonitoring(for: beaconRegion!)
        locationManager?.startRangingBeacons(in: beaconRegion!)
    }
    
    func playSound() {
        let path = Bundle.main.path(forResource: "red_alert.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            soundEffect = try AVAudioPlayer(contentsOf: url)
            if !(self.soundEffect?.isPlaying ?? false) {
                soundEffect?.play()
                self.view.backgroundColor = .red
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.soundEffect?.stop()
                self.view.backgroundColor = UIColor(displayP3Red: 31/255, green: 33/255, blue: 36/255, alpha: 1)
            }
        } catch {
            // couldn't load file :(
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Count--\(beacons.count)")
        filterBeacons(beacons: beacons)
    }
    
    func filterBeacons(beacons: [CLBeacon]) {
        var arrNearDevices = [CLBeacon]()
        for beacon in beacons {
            if beacon.proximity == .near || beacon.proximity == .immediate {
                arrNearDevices.append(beacon)
                if arrNearDevices.count > Int(lblCount.text ?? "0") ?? 0 {
                    scheduleNotification()
                    playSound()
                }
            }
        }
        lblCount.text = "\(arrNearDevices.count)"
    }
    
    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }

        let localBeaconUUID = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
        let localBeaconMajor: CLBeaconMajorValue = 123
        let localBeaconMinor: CLBeaconMinorValue = 456

        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "Your private identifer here")

        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

