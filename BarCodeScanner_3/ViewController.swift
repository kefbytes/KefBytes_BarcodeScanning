//
//  ViewController.swift
//  BarCodeScanner_3
//
//  Created by Franks, Kent on 1/2/18.
//  Copyright © 2018 KefBytes. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    // MARK: - Properties
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var scanResultsLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    
    var avCaptureSession: AVCaptureSession?
    var avCaptureVideoPreviewLayer: AVCaptureVideoPreviewLayer!
    var scanning: Bool = false

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.layer.cornerRadius = 5;
        startStopButton.layer.cornerRadius = 5;
        avCaptureSession = nil;
        scanResultsLabel.text = "Barcode discription...";
    }
    
    // MARK: - Action
    @IBAction func startStopScanningAction(_ sender: UIButton) {
        if !scanning {
            if (self.beginScanning()) {
                startStopButton.setTitle("End Scanning", for: .normal)
                scanResultsLabel.text = "Scanning for barcode ..."
            }
        }
        else {
            endScanning()
            startStopButton.setTitle("Start", for: .normal)
        }
        scanning = !scanning
    }

    // MARK: - Scanning
    func beginScanning() -> Bool {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            guard let device = captureDevice else {
                print("❌ captureDevice is nil")
                return false
            }
            let input = try AVCaptureDeviceInput(device: device)
            avCaptureSession = AVCaptureSession()
            avCaptureSession?.addInput(input)
            // Do the rest of your work...
        } catch let error as NSError {
            // Handle any errors
            print(error)
            return false
        }
        
        guard let session = avCaptureSession else {
            print("❌ avCaptureSession is nil")
            return false
        }
        avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = cameraView.layer.bounds
        cameraView.layer.addSublayer(avCaptureVideoPreviewLayer)
        
        /* Check for metadata */
        let captureMetadataOutput = AVCaptureMetadataOutput()
        avCaptureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
        print("🤖 \(captureMetadataOutput.availableMetadataObjectTypes)")
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        avCaptureSession?.startRunning()
        
        return true
    }
    
    @objc func endScanning() {
        avCaptureSession?.stopRunning()
        avCaptureSession = nil
        avCaptureVideoPreviewLayer.removeFromSuperlayer()
    }
    
    // MARK: - Delegate Method
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for data in metadataObjects {
            let metaData = data
            print(metaData.description)
            let transformed = avCaptureVideoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                print(unwraped.stringValue as Any)
                scanResultsLabel.text = unwraped.stringValue
                startStopButton.setTitle("Begin Scanning", for: .normal)
                self.performSelector(onMainThread: #selector(endScanning), with: nil, waitUntilDone: false)
                scanning = false;
            }
        }
    }
    
}

