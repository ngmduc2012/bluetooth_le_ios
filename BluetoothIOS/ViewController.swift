//
//  ViewController.swift
//  BluetoothIOS
//
//  Created by Nguyen Minh Duc on 24/05/2022.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate, CBPeripheralManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    /**
     * #####################################################################
     * OVERVIEW:
     * (I) CONNECTION TO PEER:
     * Turn on bluetooth (14) OPEN BLUETOOTH SETTING, discover peer (15) FIND and return results at (2) RESULT SCAN. The peer is showed on screen (11) LIST VIEW. Choose a peer that want to connect. The result of connection in (3) RESULT CONNECTION. Connection is success, set state is connected (state == 2), input message (12) TEXT FIELD & HINT KEYBOARD and sending (9) SEND - WRITE DATA.
     * (II) AUTO CONNECT TO PEER:
     * Once the peer connect to iphone (make sure advertising and setup server (13) ADVERTISING for peer's discovery). Iphone can not get status connected of peer, so peer has to send its name to Iphone. After get name (7) READ DATA, the name is 19 string characters after "#" character. Iphone will discover that peer (8) AUTO CONNEC, after get result. If it satisfied condition of auto connect, the peer is connected RESULT SCAN  (2). It take 1, 2 seconds.  
     *
     *
     * DESCRIPTION:
     * (1) STATE: Application has 3 status: Off bluetooth, On bluetooth, Connected. Status allway updates.
     * (2) RESULT SCAN: Get message from peer. If case is auto connect [isAutoConnect] = true, connect to peer. Else, add to [devices] for showing on sreen.
     * (3) RESULT CONNECTION: Get result of connection with peer.
     * (4) HANDLE BLUETOOTH: Scan UUID server and character of peer.
     * (5) SERVER: Setup server for the peer's connection and comunication.
     * (6) DISCONNECT: Get state disconnection of the peer. (No work)
     * (7) READ DATA: Read message from the peer.
     * (8) AUTO CONNECT: Handle message. If message contains "#", that means the peer's name after "#". Else, that is a normal message.
     * (9) SEND - WRITE DATA: Send message to the peer.
     * (10) PROGESSBAR: Showing loading.
     * (11) LIST VIEW: Show peers on the screen and manipulate for connection.
     * (12) TEXT FIELD & HINT KEYBOARD: Input message and hint keyboard of Iphone.
     * (13) ADVERTISING: On/Off advertising for peer's discovery.
     * (14) OPEN BLUETOOTH SETTING: Open bluetooth on setting of Iphone.
     * (15) FIND: Discover peer.
     *
     * (NOTE: The peer is builded on Android: https://github.com/ngmduc2012/bluetooth_android.git)
     * -------------------------------------------------------------------------------------------------------------
     * TỔNG QUAN:
     * (I) KẾT NỐI TỚI THIẾT BỊ ĐỐI TÁC:
     * Bật bluetooth (14) OPEN BLUETOOTH SETTING sau đó tiến hành tìm kiếm (15) FIND, iphone sẽ tìm kiếm các thiết bị đối tác và trả về (2) RESULT SCAN, các thiết bị sẽ được hiển thị ra ngoài màn hình (11) LIST VIEW. Tiến hành lựa chọn thiết bị muốn kết nối. Kết quả kết nối sẽ được trả về tại (3) RESULT CONNECTION. Khi kết nối thành công sẽ hiển thị trạng thái đã kết nối (state == 2), sau đó nhập thông điệp (12) TEXT FIELD & HINT KEYBOARD và gửi đi (9) SEND - WRITE DATA.
     * (II) TỰ ĐỘNG KẾT NỐI VỚI THIẾT BỊ ĐỐI TÁC:
     * Khi 1 thiết bị đối tác kết nối tới (chắc chắn đã bật quản bá và thiết lập server (13) ADVERTISING để các thiết bị đối tác tìm thấy iphone). Vì iphone không nhận được trạng thái kết nối của thiết bị đối tác, nên thiết bị đối tác sẽ tiến hành gửi tên của mình cho iphone, sau khi nhận được tên (7) READ DATA sẽ tiến hành kiếm tra thông điệp có chứa ký tự "#" hay không. 19 ký tự đầu của thiết bị sẽ sẽ ở phí sau ký tự "#" iphone sẽ tìm kiếm và kết nối với thiết bị đó (8) AUTO CONNECT, kết quả thỏa mãn thì thiết bị sẽ được kết nối ngay RESULT SCAN  (2).
     *
     * MÔ TẢ    :
     * (1) STATE: Ứng dụng có 3 trạng thái là chưa mở bluetooth, đã bật bluetooth và đã kết nối. Trạng thái sẽ luôn được cập nhập trong quá trình sử dụng.
     * (2) RESULT SCAN: Nhận kết quả từ thiết bị đối tác. Nếu là trường hợp tự động kết nối [isAutoConnect] = true thì tiến hành kết nối với thiết bị, nếu không sẽ thêm vào [deviecs] để hiển thị ra ngoài màn hình.
     * (3) RESULT CONNECTION: Nhận kết quả xác nhận đã kết nối với thiết bị đối tác.
     * (4) HANDLE BLUETOOTH: Phát hiện UUID server và UUID để truyền character của thiết bị đối tác.
     * (5) SERVER: Thiết lập server để các thiết bị khác kết nối và giao tiếp.
     * (6) DISCONNECT: Phát hiện trạng thái ngắt kết nối với thiết bị đối tác (Không hoạt động)
     * (7) READ DATA: Đọc dữ liệu nhận từ thiết bị đối tác.
     * (8) AUTO CONNECT: Xử lí dữ liệu. Nếu trong dữ liệu có chứa ký tự "#" thì tên của thiết bị cần kết nối ở ngay sau đó. Nếu không thì đó là 1 thông điệp thông thường và in ra màn hình.
     * (9) SEND - WRITE DATA: Gửi thông điệp đến thiết bị đối tác.
     * (10) PROGESSBAR: Hiển thị loading.
     * (11) LIST VIEW: Hiển thị danh sách các thiết bị ra ngoài màn hình và cho phép thao tác chọn để kết nối.
     * (12) TEXT FIELD & HINT KEYBOARD: Nhập thông điệp và ẩn bàn phím của iphone
     * (13) ADVERTISING: Tắt và mở quản bá giúp các thiết bị đối tác phát hiện ra.
     * (14) OPEN BLUETOOTH SETTING: Mở bluetooth trong cài đặt của iphone.
     * (15) FIND: Tìm kiếm các thiết bị đối tác.
     *
     * (NOTE: Thiết bị đối tác sử dụng android: https://github.com/ngmduc2012/bluetooth_android.git)
     * ######################################################################
     * THE FOLLOWING:
     * https://www.freecodecamp.org/news/ultimate-how-to-bluetooth-swift-with-hardware-in-20-minutes/
     */


    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    var peripheralManager: CBPeripheralManager!
    
    /**
           STATE (1)
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
     RESULT SCAN  (2)
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
     RESULT CONNECTION  (3)
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
     HANDLE BLUETOOTH  (4)
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
     * SERVER  (5)
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
     * DISCONNECT (6)
     * This callback comes in when the PeripheralManager received write to characteristics
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            setState(state: 1)
            notify.text = "Disconnected"
                    self.peripheral = nil
                    // Start scanning again
//                    print("Central scanning for", ParticlePeripheral.serviceUUID);
//                    centralManager.scanForPeripherals(withServices: [ParticlePeripheral.serviceUUID],
//                                                      options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
      }
    }
    
    
    
    /*
     * READ DATA (7)
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
     * AUTO CONNECT (8)
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
     SEND - WRITE DATA (9)
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
     PROGESSBAR (10)
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
     LIST VIEW (11)
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
     TEXT FIELD & HINT KEYBOARD (12)
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
     ADVERTISING (13)
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
     OPEN BLUETOOTH SETTING (14)
     */
    @IBAction func open_blue(_ sender: Any) {openBlue()}
    @IBOutlet weak var b_open_blue: UIButton!
    func openBlue() {
        let url = URL(string: "App-Prefs:root=General&path=Bluetooth")
        let app = UIApplication.shared
        app.openURL(url!)
    }
    
    
    /**
     FIND (15)
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
    
    /**
     OVERRIDE
     */
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

