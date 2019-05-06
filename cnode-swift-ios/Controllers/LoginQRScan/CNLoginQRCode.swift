//
//  CNLoginQRCode.swift
//  cnode-swift-ios
//
//  Created by guodong on 2019/5/5.
//  Copyright © 2019 kwoktung. All rights reserved.
//

import UIKit

class CNLoginQRScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var pickerController: UIImagePickerController!;
    override func viewDidLoad() {
        super.viewDidLoad();
        pickerController = UIImagePickerController();
        pickerController.sourceType = .camera;
        pickerController.cameraDevice = .rear;
        pickerController.cameraCaptureMode = .photo;
        pickerController.videoQuality = .type640x480;
        
        pickerController.delegate = self;
    }
    
}
