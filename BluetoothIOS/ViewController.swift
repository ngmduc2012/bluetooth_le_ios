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
     * T???NG QUAN:
     * (I) K???T N???I T???I THI???T B??? ?????I T??C:
     * B???t bluetooth (14) OPEN BLUETOOTH SETTING sau ???? ti???n h??nh t??m ki???m (15) FIND, iphone s??? t??m ki???m c??c thi???t b??? ?????i t??c v?? tr??? v??? (2) RESULT SCAN, c??c thi???t b??? s??? ???????c hi???n th??? ra ngo??i m??n h??nh (11) LIST VIEW. Ti???n h??nh l???a ch???n thi???t b??? mu???n k???t n???i. K???t qu??? k???t n???i s??? ???????c tr??? v??? t???i (3) RESULT CONNECTION. Khi k???t n???i th??nh c??ng s??? hi???n th??? tr???ng th??i ???? k???t n???i (state == 2), sau ???? nh???p th??ng ??i???p (12) TEXT FIELD & HINT KEYBOARD v?? g???i ??i (9) SEND - WRITE DATA.
     * (II) T??? ?????NG K???T N???I V???I THI???T B??? ?????I T??C:
     * Khi 1 thi???t b??? ?????i t??c k???t n???i t???i (ch???c ch???n ???? b???t qu???n b?? v?? thi???t l???p server (13) ADVERTISING ????? c??c thi???t b??? ?????i t??c t??m th???y iphone). V?? iphone kh??ng nh???n ???????c tr???ng th??i k???t n???i c???a thi???t b??? ?????i t??c, n??n thi???t b??? ?????i t??c s??? ti???n h??nh g???i t??n c???a m??nh cho iphone, sau khi nh???n ???????c t??n (7) READ DATA s??? ti???n h??nh ki???m tra th??ng ??i???p c?? ch???a k?? t??? "#" hay kh??ng. 19 k?? t??? ?????u c???a thi???t b??? s??? s??? ??? ph?? sau k?? t??? "#" iphone s??? t??m ki???m v?? k???t n???i v???i thi???t b??? ???? (8) AUTO CONNECT, k???t qu??? th???a m??n th?? thi???t b??? s??? ???????c k???t n???i ngay RESULT SCAN  (2).
     *
     * M?? T???    :
     * (1) STATE: ???ng d???ng c?? 3 tr???ng th??i l?? ch??a m??? bluetooth, ???? b???t bluetooth v?? ???? k???t n???i. Tr???ng th??i s??? lu??n ???????c c???p nh???p trong qu?? tr??nh s??? d???ng.
     * (2) RESULT SCAN: Nh???n k???t qu??? t??? thi???t b??? ?????i t??c. N???u l?? tr?????ng h???p t??? ?????ng k???t n???i [isAutoConnect] = true th?? ti???n h??nh k???t n???i v???i thi???t b???, n???u kh??ng s??? th??m v??o [deviecs] ????? hi???n th??? ra ngo??i m??n h??nh.
     * (3) RESULT CONNECTION: Nh???n k???t qu??? x??c nh???n ???? k???t n???i v???i thi???t b??? ?????i t??c.
     * (4) HANDLE BLUETOOTH: Ph??t hi???n UUID server v?? UUID ????? truy???n character c???a thi???t b??? ?????i t??c.
     * (5) SERVER: Thi???t l???p server ????? c??c thi???t b??? kh??c k???t n???i v?? giao ti???p.
     * (6) DISCONNECT: Ph??t hi???n tr???ng th??i ng???t k???t n???i v???i thi???t b??? ?????i t??c (Kh??ng ho???t ?????ng)
     * (7) READ DATA: ?????c d??? li???u nh???n t??? thi???t b??? ?????i t??c.
     * (8) AUTO CONNECT: X??? l?? d??? li???u. N???u trong d??? li???u c?? ch???a k?? t??? "#" th?? t??n c???a thi???t b??? c???n k???t n???i ??? ngay sau ????. N???u kh??ng th?? ???? l?? 1 th??ng ??i???p th??ng th?????ng v?? in ra m??n h??nh.
     * (9) SEND - WRITE DATA: G???i th??ng ??i???p ?????n thi???t b??? ?????i t??c.
     * (10) PROGESSBAR: Hi???n th??? loading.
     * (11) LIST VIEW: Hi???n th??? danh s??ch c??c thi???t b??? ra ngo??i m??n h??nh v?? cho ph??p thao t??c ch???n ????? k???t n???i.
     * (12) TEXT FIELD & HINT KEYBOARD: Nh???p th??ng ??i???p v?? ???n b??n ph??m c???a iphone
     * (13) ADVERTISING: T???t v?? m??? qu???n b?? gi??p c??c thi???t b??? ?????i t??c ph??t hi???n ra.
     * (14) OPEN BLUETOOTH SETTING: M??? bluetooth trong c??i ?????t c???a iphone.
     * (15) FIND: T??m ki???m c??c thi???t b??? ?????i t??c.
     *
     * (NOTE: Thi???t b??? ?????i t??c s??? d???ng android: https://github.com/ngmduc2012/bluetooth_android.git)
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
            // th??m ph???n v??o setting v?? b???t bluetooth
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
    // T???o Server ????? k???t n???i v???i android : https://developer.apple.com/documentation/corebluetooth/transferring_data_between_bluetooth_low_energy_devices
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
    // C???t chu???i string: https://stackoverflow.com/a/25678505/10621168
    // X??? l?? chu???i string: https://stackoverflow.com/a/24161872/10621168
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
        // ios truyen duoc 180 phan tu v???i ki???u truy???n no respond
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
    // ???n b??n ph??m tr??n iphone: https://stackoverflow.com/a/26582115/10621168
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

