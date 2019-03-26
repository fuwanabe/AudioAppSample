//
//  ViewController.swift
//  AudioAppSample
//
//  Created by 渡邉 風基 on 2019/03/25.
//  Copyright © 2019 Fuki Watanabe. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
 
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    let audioEngine = AVAudioEngine()
    let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask : SFSpeechRecognitionTask?   //初期値を設定しないのでOptional型

    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.button.isEnabled = true
                case .denied:
                    self.button.isEnabled = false
                    self.button.setTitle("User denied access to speech recognition", for: .disabled)
                case .restricted:
                    self.button.isEnabled = false
                    self.button.setTitle("Speech recognition restricted on this device", for: .disabled)
                case .notDetermined:
                    self.button.isEnabled = false
                    self.button.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    
    @IBAction func recButton(_ sender: UIButton) {

        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest.endAudio()
            recognitionTask?.cancel()
            recognitionTask = nil
            button.setTitle("録音完了", for: .normal)
            button.isEnabled = false
        } else {
            let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest.append(buffer)
            })
            try! audioEngine.start()
//            クロージャを使って実装するパターン
//            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] result, error in
//                // 解析結果を反映
//                if let result = result {
//                    self?.label.text = result.bestTranscription.formattedString
//                }
//
//            })
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, delegate: self)
            
            button.setTitle("録音終了", for: .normal)
        }
        
    }


}

extension ViewController:SFSpeechRecognizerDelegate {
    // 音声認識の可否が変更したときに呼ばれるdelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            button.isEnabled = true
        } else {
            button.isEnabled = false
        }
    }

}

//デリゲートを使って実装するパターン
extension ViewController:SFSpeechRecognitionTaskDelegate {
    //音声認識処理が走るたびに呼ばれる
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        let text = transcription.formattedString
        print(text)
        self.label.text = text
    }
    //音声認識が完了した際に呼ばれる
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        guard successfully else {
            print("Error Task!")
            return
        }
        print("Finish Task!")
    }
    
}
