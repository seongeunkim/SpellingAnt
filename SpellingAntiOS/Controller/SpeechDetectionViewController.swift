//
//  SpeechDetectionViewController.swift
//  Speech-Recognition-Demo
//
//  Created by Seong Eun Kim on 11/05/17.
//  Copyright © 2018 Seong Eun Kim. All rights reserved.
//

import UIKit

class SpeechDetectionViewController: UIViewController {

    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var listeningFeedback: UILabel!
    
    var isRecording = false
    
    let audioTranscriptionService = AudioTranscriptionService()
    
    let multipeerService = MultipeerService()
    
    var progress = KDCircularProgress()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
        
        //self.initProgressCircle()
        //progress.animate(toAngle: 360, duration: 10, completion: nil)
    }
    
    func initProgressCircle(){
        progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        progress.startAngle = -90
        progress.progressThickness = 0.2
        progress.trackThickness = 0.6
        progress.clockwise = true
        progress.gradientRotateSpeed = 2
        progress.roundedCorners = false
        progress.glowMode = .forward
        progress.glowAmount = 0.9
        progress.set(colors: UIColor.cyan ,UIColor.white, UIColor.magenta, UIColor.white, UIColor.orange)
        progress.center = CGPoint(x: view.center.x, y: view.center.y + 25)
        progress.trackColor = .lightGray
        view.addSubview(progress)
    }
    
//MARK: IBActions and Cancel
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isRecording == true {
            speechButton.setImage(#imageLiteral(resourceName: "Ditation"), for: .normal)
            isRecording = false
            audioTranscriptionService.cancelRecording()
            listeningFeedback.text = "Tap button to start voice recognition!"
        } else {
            speechButton.setImage(#imageLiteral(resourceName: "Ditation-selected"), for: .normal)
            isRecording = true
            listeningFeedback.text = "LISTENING"
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
                    self.speechButton.isEnabled = true
                case .denied:
                    self.speechButton.isEnabled = false
                    self.detectedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.speechButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.speechButton.isEnabled = false
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
