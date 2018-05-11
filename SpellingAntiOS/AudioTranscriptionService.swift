//
//  AudioTranscriptionService.swift
//  Speech-Recognition-Demo
//
//  Created by Seong Eun Kim on 11/05/18.
//  Copyright © 2018 Jennifer A Sipila. All rights reserved.
//

import Foundation
import Speech

class AudioTranscriptionService: NSObject, SFSpeechRecognizerDelegate {
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    //MARK: - Recognize Speech
    
    private func bufferizeAudio() {
        let node = audioEngine.inputNode
        if node == nil {
            return
        }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
    }
    
    
    fileprivate func startAudioEngine() {
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            //self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
    }
    
    fileprivate func checkRecognizer() {
        guard let myRecognizer = SFSpeechRecognizer() else {
            //self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            //self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
    }
    
    fileprivate func transcribeAudio(completion: @escaping(String) -> ()) {
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            
            if result != nil {
                if let result = result {
                    
                    let bestString = result.bestTranscription.formattedString
                    completion(bestString)
                    
                    var lastString: String = ""
                    for segment in result.bestTranscription.segments {
                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                        lastString = bestString.substring(from: indexTo)
                    }
                } else if let error = error {
                    self.sendAlert(message: "There has been a speech recognition error.")
                    print(error)
                }
            }
        })
        
        
    }
    
    func recordAndRecognizeSpeech(completion: @escaping(String) -> ()) {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        self.bufferizeAudio()
        
        self.startAudioEngine()
        
        self.checkRecognizer()
        
        self.transcribeAudio(completion: { finalString in
            print(finalString)
            completion(finalString)
        })
    }
    
    //MARK: - Check Authorization Status
    
    func requestSpeechAuthorization(completion: @escaping(SFSpeechRecognizerAuthorizationStatus) -> ()) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            completion(authStatus)
        }
    }
    
    func cancelRecording() {
        request.endAudio()
        audioEngine.stop()
        recognitionTask?.cancel()
        let node = audioEngine.inputNode
        if node != nil {
            node.removeTap(onBus: 0)
        }
    }
    
    func sendAlert(message: String) {
        //let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        //self.present(alert, animated: true, completion: nil)
    }
    
}
