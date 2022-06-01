//
//  ViewController.swift
//  BluetoothIOS
//
//  Created by Nguyen Minh Duc on 24/05/2022.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate, CBPeripheralManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // tham khảo: https://www.freecodecamp.org/news/ultimate-how-to-bluetooth-swift-with-hardware-in-20-minutes/
    
    /**
         * ################################################################################################
         * FUNCTION   : Setup status for view
         * DESCRIPTION:
         * (1) Checking if the device supports the bluetooth
         * (2) Checking if the bluetooth is opened
         * (3) Setup status for showing on UI
         * ------------------------------------------------------------------------------------------------
         * CHỨC NĂNG: Cài đặt trạng thái ban đầu
         * MÔ TẢ    :
         * (1) Kiểm tra thiết bị có hỗ trợ bluetooth hay không
         * (2) Kiếm tra thiết bị đang bật hay tắt bluetooth
         * (3) Cài đặt trạng thái để hiển thị ra giao diện ngoài màn hình.
         * ################################################################################################
         */


    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    var peripheralManager: CBPeripheralManager!
    
    /**
           STATE
     */
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
//        print("ok: " , peripheral.autoContentAccessingProxy)
        print("state: ",peripheral.state )
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
            tableView.isHidden = true
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
            tableView.isHidden = false
            b_send.isHidden = true
            b_hint.isHidden = true
            myTextField.isHidden = true
            advertising.isHidden = false
            name.isHidden = false
            message.isHidden = false
            b_find.isHidden = false
            l_advertising.isHidden = false
        } else if (state == 2){
            tableView.isHidden = false
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
    
    /**
     RESULT SCAN
     */
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if isAutoConnect && peripheral.name != nil && nameAutoConnect  != "" {
            if peripheral.name!.contains(nameAutoConnect) {
                connectToPeripheral(device: peripheral)
                isAutoConnect = false
                nameAutoConnect = ""
            }
        } else {
                var isHad = false
                deviecs.forEach{ device in
                    if device == peripheral {
                        isHad = true
                    }
                }
                if(!isHad) {
                    deviecs.append(peripheral)
                    tableView.reloadData()
                    print("add")
                }
        }
    }
    
    /**
     RESULT CONNECTION
     */
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            notify.text = "Connected to: "
            peripheral.discoverServices([ParticlePeripheral.serviceUUID])
        }
    }
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didRetrievePeripherals peripheral: CBPeripheral) {}

    
    /**
     HANDLE BLUETOOTH
     */
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
//                    setupPeripheral()
                    return
                }
            }
        }
    }
    
    // Characteristics
    private var messageChar: CBCharacteristic?
    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ParticlePeripheral.messageUUID {
                    print("messageUUID")
                    messageChar = characteristic
                    peripheral.readValue(for: characteristic)
//                    setupPeripheral()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        setupPeripheral()
    }
    
    /*
     *  This is called when peripheral is ready to accept more data when using write without response
     */
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
    }
    
    /*
     *  If the connection fails for whatever reason, we need to deal with it.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    }
    
    func peripheral(_ peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
    }
   
    
    /*
     * SERVER
     */
    // Tạo Server để kết nối với android : https://developer.apple.com/documentation/corebluetooth/transferring_data_between_bluetooth_low_energy_devices
    private func setupPeripheral() {
        print("setupPeripheral")
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


    
    /*
     * DISCONNECT
     * This callback comes in when the PeripheralManager received write to characteristics
     */
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
    
    
    
    /*
     * READ DATA
     * This callback comes in when the PeripheralManager received write to characteristics
     */
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for aRequest in requests {
            guard let requestValue = aRequest.value,
                let stringFromData = String(data: requestValue, encoding: .utf8) else {
                    continue
            }
            print("Received write request - bytes: ", requestValue.count, stringFromData)
            autoConnect(stringFromData: stringFromData)
        }
    }
    
    /*
     * AUTU CONNECT
     */
    // Cắt chuỗi string: https://stackoverflow.com/a/25678505/10621168
    // Xử lý chuỗi string: https://stackoverflow.com/a/24161872/10621168
    var isAutoConnect = false
    var nameAutoConnect : String = ""
    func autoConnect(stringFromData : String) {
        if stringFromData.contains("#") {
            showSpinner()
            message.text = ""
            notify.text = "Connecting to " + stringFromData
            isAutoConnect = true
            nameAutoConnect = stringFromData.components(separatedBy: "#").last ?? ""
            print("nameAutoConnect", nameAutoConnect)
            find()
        } else {
            message.text = stringFromData
        }
    }
    func connectToPeripheral(device : CBPeripheral){
        // We've found it so stop scan
            self.centralManager.stopScan()
           // Copy the peripheral instance
            self.peripheral = device
            self.peripheral.delegate = self
          // Connect!
            self.centralManager.connect(self.peripheral, options: nil)
            name.text = self.peripheral.name ?? "No device is connected!"
            setState(state: 2)
        hideSpinner()
    }
    
    
    /**
     SEND - WRITE DATA
     */
    @IBOutlet weak var b_send: UIButton!
    @IBAction func send(_ sender: Any) {
        // ios truyen duoc 180 phan tu với kiểu truyền no respond
        let str = myTextField.text
        if ((str?.isEmpty) != nil) {
            let slider:  [UInt8]  =  [UInt8] (str?.utf8 ?? "".utf8)
            writeValueToChar( withCharacteristic: messageChar!, withValue: Data(slider))
        }
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

    /**
     PROGESSBAR
     */
    // The following progess: https://www.raywenderlich.com/25358187-spinner-and-progress-bar-in-swift-getting-started
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private func showSpinner() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private func hideSpinner() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    /**
     LIST VIEW
     */
    @IBOutlet weak var tableView: UITableView!
    var deviecs: [CBPeripheral] = []
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviecs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = deviecs[indexPath.row].name
        cell.detailTextLabel?.text =  "detail"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected cell: \( deviecs[indexPath.row])")
        connectToPeripheral(device: deviecs[indexPath.row])
    }

  
    /**
     TEXT FIELD & HINT KEYBOARD
     */
    // Ẩn bàn phím trên iphone: https://stackoverflow.com/a/26582115/10621168
    @IBOutlet weak var b_hint: UIButton!
    @IBOutlet var myTextField : UITextField!
    @IBAction func hintKeyboard(_ sender: Any) {
        textFieldShouldReturn(myTextField)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /**
     ADVERTISING
     */
    @IBOutlet weak var l_advertising: UILabel!
    @IBOutlet weak var advertising: UISwitch!
    @IBAction func advertisingAction(_ sender: UISwitch) {
        if sender.isOn {
            advertisingFunc()
        } else {
            peripheralManager.stopAdvertising()
        }
    }
    func advertisingFunc(){
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [ParticlePeripheral.serviceUUID]])
        setupPeripheral()
    }
    
    
    /**
     OPEN BLUETOOTH SETTING
     */
    @IBAction func open_blue(_ sender: Any) {openBlue()}
    @IBOutlet weak var b_open_blue: UIButton!
    func openBlue() {
        let url = URL(string: "App-Prefs:root=General&path=Bluetooth")
        let app = UIApplication.shared
        app.openURL(url!)
    }
    
    
    /**
     FIND
     */
    @IBAction func find(_ sender: Any) {find()}
    @IBOutlet weak var b_find: UIButton!
    func find(){
        showSpinner()
        print("Central scanning for", ParticlePeripheral.serviceUUID);
        notify.text = "Central scanning for \(ParticlePeripheral.serviceUUID)"
        deviecs = []
        tableView.reloadData()
        centralManager.scanForPeripherals(withServices: [ParticlePeripheral.serviceUUID],
                                                      options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    override func viewDidLoad() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //delegate & datasouce
        tableView.delegate = self
        tableView.dataSource = self
        centralManager = CBCentralManager(delegate: self, queue: nil)
        advertising.isOn = false
        activityIndicator.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        // Don't keep advertising going while we're not showing.
        peripheralManager.stopAdvertising()
        super.viewWillDisappear(animated)
    }
    @IBOutlet weak var notify: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    
}

