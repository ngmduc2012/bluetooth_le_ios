//
//  ViewController.swift
//  BluetoothIOS
//
//  Created by Nguyen Minh Duc on 24/05/2022.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate, CBPeripheralManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return names.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = names[indexPath.row].name
            cell.detailTextLabel?.text =  "detail"
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("selected cell: \( names[indexPath.row])")
            
            // We've found it so stop scan
                self.centralManager.stopScan()
//
//                // Copy the peripheral instance
                self.peripheral = names[indexPath.row]
                self.peripheral.delegate = self
////
//                // Connect!
                self.centralManager.connect(self.peripheral, options: nil)
                name.text = self.peripheral.name ?? "No device is connected!"
                setState(state: 2)
        }
    

    @IBOutlet weak var tableView: UITableView!
    var names: [CBPeripheral] = []
   
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if  peripheral.state == .poweredOff {
            notify.text = "Central is not powered on!"
            setState(state: 0)
        } else if peripheral.state == .poweredOn {
            notify.text = "peripheral is on"
        } else if peripheral.state == .resetting {
            notify.text = "peripheral is resetting"
        } else if peripheral.state == .unauthorized {
            notify.text = "peripheral is unauthorized"
        } else if peripheral.state == .unknown {
            notify.text = "peripheral is unknown"
        } else if peripheral.state == .unsupported {
            notify.text = "peripheral is unsupported"
        }
    
    }
    
 
    // Gửi dữ liệu từ ios tham khảo: https://www.freecodecamp.org/news/ultimate-how-to-bluetooth-swift-with-hardware-in-20-minutes/
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            notify.text = "Central is not powered on!"
            // thêm phần vào setting và bật bluetooth
            setState(state: 0)
        } else {
            setState(state: 1)
//            print("Central scanning for", ParticlePeripheral.serviceUUID);
//            notify.text = "Central scanning for \(ParticlePeripheral.serviceUUID)"
            name.text = "No device is connected!"
//            centralManager.scanForPeripherals(withServices: [ParticlePeripheral.serviceUUID],
//                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func setState(state : Int){
        if(state == 0){
            b_open_blue.isHidden = false
            notify.isHidden = false
            b_send.isHidden = true
            b_hint.isHidden = true
            myTextField.isHidden = true
            advertising.isHidden = true
            name.isHidden = true
            message.isHidden = true
            b_find.isHidden = true
            l_advertising.isHidden = true
        } else if (state == 1) {
            b_open_blue.isHidden = true
            notify.isHidden = false
            b_send.isHidden = true
            b_hint.isHidden = true
            myTextField.isHidden = true
            advertising.isHidden = false
            name.isHidden = false
            message.isHidden = true
            b_find.isHidden = false
            l_advertising.isHidden = false
        } else if (state == 2){
            b_open_blue.isHidden = true
            notify.isHidden = false
            b_send.isHidden = false
            b_hint.isHidden = false
            myTextField.isHidden = false
            advertising.isHidden = false
            name.isHidden = false
            message.isHidden = false
            b_find.isHidden = false
            l_advertising.isHidden = false
        }
        
    }
    
    // Handles the result of the scan
            func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

                var isHad = false
                names.forEach{ name in
                    if name == peripheral {
                        isHad = true
                    }
                }
                if(!isHad) {
                    names.append(peripheral)
                    tableView.reloadData()
                    print("add")
                }
                // We've found it so stop scan
//                self.centralManager.stopScan()
//
//                // Copy the peripheral instance
//                self.peripheral = peripheral
//                self.peripheral.delegate = self
////
//                // Connect!
//                self.centralManager.connect(self.peripheral, options: nil)
//                name.text = self.peripheral.name ?? "No device is connected!"
//                setState(state: 2)


            }
    // The handler if we do connect succesfully
            func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
                if peripheral == self.peripheral {
                    notify.text = "Connected to: "
                    peripheral.discoverServices([ParticlePeripheral.serviceUUID])
                }
            }
    
    // Handles discovery event
            func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
                if let services = peripheral.services {
                    for service in services {
                        if service.uuid == ParticlePeripheral.serviceUUID {
                            //Now kick off discovery of characteristics
                            notify.text = "Android service found"
                            peripheral.discoverCharacteristics(
                                [ParticlePeripheral.messageUUID],
                                for: service)
                            return
                        }
                    }
                }
            }
    // Handling discovery of characteristics
            func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
                if let characteristics = service.characteristics {
                    for characteristic in characteristics {
                        if characteristic.uuid == ParticlePeripheral.messageUUID {
                            print("messageUUID")
                            messageChar = characteristic
                            peripheral.readValue(for: characteristic)
                            setupPeripheral()
                        }
                    }
                }
            }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        setupPeripheral()
    }
    // Tạo Server để kết nối với android : https://developer.apple.com/documentation/corebluetooth/transferring_data_between_bluetooth_low_energy_devices
    private func setupPeripheral() {
        // Build our service.
        
        // Start with the CBMutableCharacteristic.
        let transferCharacteristic = CBMutableCharacteristic(type: ParticlePeripheral.messageUUID,
                                                         properties: [.notify, .writeWithoutResponse],
                                                         value: nil,
                                                         permissions: [.readable, .writeable])
        // Create a service from the characteristic.
        let transferService = CBMutableService(type: ParticlePeripheral.serviceUUID, primary: true)
        
        // Add the characteristic to the service.
        transferService.characteristics = [transferCharacteristic]
        
        // And add it to the peripheral manager.
        peripheralManager.add(transferService)
    }

    // Characteristics
    private var messageChar: CBCharacteristic?
    @IBAction func send(_ sender: Any) {
        // ios truyen duoc 180 phan tu với kiểu truyền no respond
        let str = myTextField.text
        if ((str?.isEmpty) != nil) {
//            print("Send to Android: ", str ?? "");
            let slider:  [UInt8]  =  [UInt8] (str?.utf8 ?? "".utf8)
            writeValueToChar( withCharacteristic: messageChar!, withValue: Data(slider))
        }
    }
    
    @IBOutlet weak var b_send: UIButton!
    var peripheralManager: CBPeripheralManager!
    override func viewWillDisappear(_ animated: Bool) {
        // Don't keep advertising going while we're not showing.
        peripheralManager.stopAdvertising()
        super.viewWillDisappear(animated)
    }
    /*
     * This callback comes in when the PeripheralManager received write to characteristics
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for aRequest in requests {
            guard let requestValue = aRequest.value,
                let stringFromData = String(data: requestValue, encoding: .utf8) else {
                    continue
            }
            print("Received write request - bytes: ", requestValue.count, stringFromData)
            message.text = stringFromData
        }
    }

  
    //    Ẩn bàn phím trên iphone: https://stackoverflow.com/a/26582115/10621168
    @IBAction func hintKeyboard(_ sender: Any) {
        textFieldShouldReturn(myTextField)
    }
    @IBOutlet weak var b_hint: UIButton!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBOutlet var myTextField : UITextField!
    @IBOutlet weak var advertising: UISwitch!
    @IBAction func advertisingAction(_ sender: UISwitch) {
        if sender.isOn {
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [ParticlePeripheral.serviceUUID]])
        } else {
            peripheralManager.stopAdvertising()
        }
    }
    @IBAction func open_blue(_ sender: Any) {
        let url = URL(string: "App-Prefs:root=General&path=Bluetooth")
        let app = UIApplication.shared
        app.openURL(url!)
    }
    @IBOutlet weak var b_open_blue: UIButton!
    @IBOutlet weak var notify: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBAction func find(_ sender: Any) {
        print("Central scanning for", ParticlePeripheral.serviceUUID);
        notify.text = "Central scanning for \(ParticlePeripheral.serviceUUID)"
        names = []
        tableView.reloadData()
        centralManager.scanForPeripherals(withServices: [ParticlePeripheral.serviceUUID],
                                                      options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    @IBOutlet weak var b_find: UIButton!
    @IBOutlet weak var l_advertising: UILabel!
    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    override func viewDidLoad() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //delegate & datasouce
        tableView.delegate = self
        tableView.dataSource = self
        centralManager = CBCentralManager(delegate: self, queue: nil)
        advertising.isOn = false
        // Do any additional setup after loading the view.
    }
    
    private func writeValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
        // Check if it has the write property
        if characteristic.properties.contains(.writeWithoutResponse) && peripheral != nil {
          peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        }
        if  peripheral != nil {
            peripheral.writeValue(value, for: characteristic, type: .withResponse)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            setState(state: 1)
            notify.text = "Disconnected"
                    self.peripheral = nil
                    // Start scanning again
                    print("Central scanning for", ParticlePeripheral.serviceUUID);
                    centralManager.scanForPeripherals(withServices: [ParticlePeripheral.serviceUUID],
                                                      options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
      }
    }
}

