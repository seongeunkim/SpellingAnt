//
//  SpeechDetectionViewController.swift
//  Speech-Recognition-Demo
//
//  Created by Jennifer A Sipila on 3/3/17.
//  Copyright © 2017 Jennifer A Sipila. All rights reserved.
//

import UIKit

class SpeechDetectionViewController: UIViewController {

    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var isRecording = false
    
    let audioTranscriptionService = AudioTranscriptionService()
    
    let multipeerService = MultipeerService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
    }
    
//MARK: IBActions and Cancel
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isRecording == true {
            isRecording = false
            audioTranscriptionService.cancelRecording()
            startButton.backgroundColor = UIColor.gray
        } else {
            isRecording = true
            startButton.backgroundColor = UIColor.red
            audioTranscriptionService.recordAndRecognizeSpeech(completion: { finalString in
                self.detectedTextLabel.text = finalString
                self.multipeerService.send(colorName: finalString)
            })
        }
    }

    
    
//MARK: - Check Authorization Status

    func requestSpeechAuthorization() {
        audioTranscriptionService.requestSpeechAuthorization(){ authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition not yet authorized"
                }
            }
        }
    }
    
//MARK: - Alert
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
