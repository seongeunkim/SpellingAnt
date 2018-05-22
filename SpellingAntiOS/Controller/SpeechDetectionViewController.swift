//
//  SpeechDetectionViewController.swift
//  Speech-Recognition-Demo
//
//  Created by Seong Eun Kim on 11/05/17.
//  Copyright © 2018 Seong Eun Kim. All rights reserved.
//

import UIKit
import AudioToolbox

class SpeechDetectionViewController: UIViewController {

    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var listeningFeedback: UILabel!
    @IBOutlet weak var beeImage: UIImageView!
    
    var isRecording = false
    
    let audioTranscriptionService = AudioTranscriptionService()
    
    let multipeerService = MultipeerService()
    
    var progress = KDCircularProgress()
    
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.speechButton.tag = 0
        self.speechButton.contentMode = .scaleAspectFit
        self.speechButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        
    }
    
    @objc func addPulse(){
        let pulse = Pulsing(numberOfPulses: 1, radius: 150, position: beeImage.center)
        pulse.animationDuration = 0.8
        pulse.backgroundColor = UIColor.white.cgColor
        
        self.view.layer.insertSublayer(pulse, below: beeImage.layer)
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
    
    @IBAction func startButtonTapped(_ sender: Any) {
        if self.speechButton.tag == 1 {
            startRecording()
        } else {
            self.requestSpeechAuthorization()
        }
        
    }
    
    func startRecording() {
        self.multipeerService.send(message: "START_OF_SPEECH")
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SpeechDetectionViewController.addPulse), userInfo: nil, repeats: true)
        speechButton.setImage(#imageLiteral(resourceName: "Ditation white selected"), for: .normal)
        isRecording = true
        listeningFeedback.text = "LISTENING"
        audioTranscriptionService.recordAndRecognizeSpeech(completion: { finalString in
            self.multipeerService.send(message: finalString)
        })
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        timer.invalidate()
        speechButton.setImage(#imageLiteral(resourceName: "Ditation white"), for: .normal)
        isRecording = false
        audioTranscriptionService.cancelRecording()
        listeningFeedback.text = "Tap button to start voice recognition!"
        
        self.multipeerService.send(message: "END_OF_SPEECH")
    }
    
    @IBAction func hintButton(_ sender: Any) {
        self.multipeerService.send(message: "HINT_BUTTON")
    }
    
    @IBAction func repeatButton(_ sender: Any) {
        self.multipeerService.send(message: "REPEAT_BUTTON")
    }

    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            print("You've pressed ok");
        }

        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
//MARK: - Check Authorization Status

    func requestSpeechAuthorization() {
        audioTranscriptionService.requestSpeechAuthorization(){ authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.speechButton.tag = 1
                case .denied:
                    self.speechButton.tag = 0
                    self.showAlert(title: "Permission denied", message: "User denied access to speech recognition.")
                case .restricted:
                    self.speechButton.tag = 0
                    self.showAlert(title: "Speech recognition unavailable", message: "Speech recognition restricted on this device.")
                case .notDetermined:
                    self.speechButton.tag = 0
                    self.showAlert(title: "Speech recognition unauthorized", message: "Speech recognition not yet authorized.")
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
