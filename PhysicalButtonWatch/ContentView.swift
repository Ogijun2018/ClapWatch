//
//  ContentView.swift
//  PhysicalButtonWatch
//
//  Created by 荻野隼 on 2020/12/15.
//

import SwiftUI
import AVFoundation
import MediaPlayer
import UIKit

struct ContentView: View {
    @ObservedObject var stopWatchManager = StopWatchManager()
    
    var body: some View {
        VStack{
            // ボリュームスライダー
            VolumeSlider()
               .frame(height: 40)
               .padding(.horizontal)
            // タイムの表示
            Text(String(format: "%.2f", stopWatchManager.secondsElapsed))
                .font(.custom("Avenir", size: 40))
                .padding(.bottom, 50)
            if stopWatchManager.mode == .stopped {
                Button(action: {
                        self.stopWatchManager.start()
                    self.stopWatchManager.plusAction()
                }) {
                    TimerButton(label: "Start", buttonColor: .blue)
                }
            }
            if stopWatchManager.mode == .running {
                VStack{
                    Button(action: {self.stopWatchManager.stop()}) {
                        TimerButton(label: "Stop", buttonColor: .red)
                    }
                    Button(action: {self.stopWatchManager.pause()}) {
                        TimerButton(label: "Pause", buttonColor: .blue)
                    }
                }
            }
            if stopWatchManager.mode == .paused {
                VStack{
                    Button(action: {self.stopWatchManager.start()}) {
                        TimerButton(label: "Start", buttonColor: .blue)
                    }
                    Button(action: {self.stopWatchManager.stop()}) {
                        TimerButton(label: "Stop", buttonColor: .red)
                    }
                }
            }
        }.onAppear{print("表示された")}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct VolumeSlider: UIViewRepresentable {
   func makeUIView(context: Context) -> MPVolumeView {
      MPVolumeView(frame: .zero)
   }

   func updateUIView(_ view: MPVolumeView, context: Context) {}
}

struct TimerButton: View {
    let label: String
    let buttonColor: Color
    
    var body: some View {
        Text(label)
            .foregroundColor(.white)
            .padding(.horizontal, 90)
            .padding(.vertical, 20)
            .background(buttonColor)
            .cornerRadius(15)
    }
}

