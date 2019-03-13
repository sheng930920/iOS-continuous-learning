//
//  ViewController.swift
//  BLEDemo
//
//  Created by student on 2019/3/7.
//  Copyright © 2019 abc. All rights reserved.
//

import UIKit
import CoreBluetooth

/**
 中心管理模式
 1.引入CoreBluetooth,初始化中心管理者
 2.监听CBCentralManager的状态,当是On的时候,才可以进行搜索外设
 3.当状态为On的时候,开始搜索我们的外设
 4.发现外设后,过滤出我们要的外设,并且对其进行标记或者存储到外设数组中(每个中心管理者都可以连接1-7个外设,但是每个外设都只能连接一个CBCentralManager)
 */

class ViewController: UIViewController {
    
    var centralManager :CBCentralManager!
    var peripheral: CBPeripheral?
    
    @IBAction func startBLE() {

        // 1.初始化中心管理者
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: nil)
    }
    
    @IBAction func stopConnect() {

        self.yf_cMgr(central: self.centralManager, stopConnectWithPeripheral: self.peripheral!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
}

extension ViewController: CBCentralManagerDelegate
{
    // 2.监听CBCentralManager的状态(模拟器永远不会是On)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
   
        switch central.state {
        case .poweredOff:
            print("PoweredOff")
        case .poweredOn:
            print("PoweredOn")
            // 3.搜索外设.会触发 centralManager:didDiscoverPeripheral:advertisementData:RSSI:
            central.scanForPeripherals(withServices: nil, options: nil)
        case .resetting:
            print("Resetting")
        case .unsupported:
            // 使用模拟器会打印此处
            print("Unsupported")
        default:
            print("others")
        }
    }
    
    // 4.发现外设
    private func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("central: \(central), peripheral: \(peripheral), adv: \(advertisementData), RSSI: \(RSSI)")
        
        // 一般会根据advertisementData来过滤出我们想要连接的外设(当然,信号强度RSSI也可以作为过滤凭据)
        /**
         ["kCBAdvDataManufacturerData": <570100ae fcda4d72 8ea10132 3c4dafc4 22aec402 880f1060 8b1d>, "kCBAdvDataIsConnectable": 1, "kCBAdvDataServiceUUIDs": <__NSArrayM 0x1545560e0>(
         FEE0,
         FEE7
         )
         , "kCBAdvDataServiceData": {
         FEE0 = <54080000>;
         }, "kCBAdvDataLocalName": MI]
         */
        let advRecName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if (advRecName!.contains("MI"))
        {
            print("advRecName: \(String(describing: advRecName)) success")
            // 5.连接想要的外设
            // 5.1.停止扫描
            central.stopScan()
            //self.start = false
            // 5.2.存储外设
            self.peripheral = peripheral
            // 5.3.连接这个外设
            central.connect(self.peripheral!, options: nil)
            
        }else
        {
            print(advRecName)
        }
    }
    
    
    // 6.连接外设的结果
    // 6.1 连接成功
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        //
        print("didConnectPeripheral")
        peripheral.delegate = self
        // 7. 与外设信息进行分析交互
        peripheral.discoverServices(nil)
    }
    
    // 6.2 连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnectPeripheral")
    }
    
    // 6.3 丢失连接(手动取消调用/ 每信号了也调用)
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //
        print("didDisconnectPeripheral")
    }
    
    // 自定义的取消连接方法
    func yf_cMgr(central: CBCentralManager,stopConnectWithPeripheral peripheral: CBPeripheral) -> ()
    {
        central.stopScan()
        central.cancelPeripheralConnection(peripheral)
    }
}

extension ViewController: CBPeripheralDelegate
{
    // 7.1 外设发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else
        {
            print("didDiscoverServices : \(error)")
            return
        }
        
        for service in peripheral.services! {
            // 7.2 外设检索服务中的每一个特征 peripheral:didDiscoverCharacteristicsForService
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // 7.3 外设发现服务中的特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else
        {
            print("didDiscoverCharacteristicsForService : \(error)")
            return
        }
        
        print(service.characteristics!.count)
        for character in service.characteristics! {
            // 7.4 外设检索特征的描述  peripheral:didDiscoverDescriptorsForCharacteristic:error:
            peripheral.discoverDescriptors(for: character)
            
            // 判断如果特征的UUID是 2B4A,那就对其进行订阅
            if character.uuid.isEqual(CBUUID(string: "2B4A"))
            {
                self.yf_Per(peripheral: peripheral, setNotifyValueForCharacteristic: character)
                
            }
            
            // 7.5 外设读取特征的值
            guard character.properties.contains(.read) else
            {
                print("character.properties must contains read")
                // 如果是只读的特征,那就跳过本条进行下一个遍历
                continue
            }
            print("note guard")
            // peripheral:didUpdateValueForCharacteristic:error:
            peripheral.readValue(for: character)
        }
    }
    
    // 7.6 外设发现了特征中的描述
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        //
        guard error == nil else
        {
            print("didDiscoverDescriptorsForCharacteristic : \(error)")
            return
        }
        
        for des in characteristic.descriptors! {
            print("characteristic: \(characteristic) .des  :\(des)")
            // peripheral:didUpdateValueForDescriptor:error: method
            peripheral.readValue(for: des)
        }
    }
    
    // 7.7 更新特征value
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else
        {
            print("didUpdateValueForCharacteristic : \(error)")
            return
        }
        
        print("\(characteristic.description) didUpdateValueForCharacteristic")
    }
    
    func yfPer(peripheral: CBPeripheral, writeData data: NSData, forCharacteristic characteristic: CBCharacteristic) -> () {
        //外设写输入进特征
        guard characteristic.properties.contains(.write) else
        {
            print("characteristic.properties must contains Write")
            return
        }
        // 会触发peripheral:didWriteValueForCharacteristic:error:
        peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        
        
    }
    // 订阅与取消订阅
    func yf_Per(peripheral: CBPeripheral, setNotifyValueForCharacteristic characteristic: CBCharacteristic) -> () {
        guard characteristic.properties.contains(.notify) else
        {
            print("characteristic.properties must contains notify")
            return
        }
        // peripheral:didUpdateNotificationStateForCharacteristic:error:
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    func yf_Per(peripheral: CBPeripheral, canleNotifyValueForCharacteristic characteristic: CBCharacteristic) -> () {
        guard characteristic.properties.contains(.notify) else
        {
            print("characteristic.properties must contains notify")
            return
        }
        peripheral.setNotifyValue(false, for: characteristic)
    }
}

