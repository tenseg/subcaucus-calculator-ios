//
//  CatalystSparkleUserInterfaces.swift
//  SubCalc
//
//  Created by Alexander Celeste on 6/27/20.
//  Copyright © 2020 Tenseg. All rights reserved.
//

import SwiftUI
import SparkleBridgeClient

struct DownloadView: View {
    @ObservedObject var sparkleDriver: CatalystSparkleDriver
    
    var body: some View {
        HStack {
            Button(action: sparkleDriver.downloadUpdate) { Text("Update") }
            Button(action: sparkleDriver.skipUpdate) { Text("Skip") }
            Button(action: sparkleDriver.ignoreUpdate) { Text("Later") }
        }
    }
}

struct InstallView: View {
    @ObservedObject var sparkleDriver: CatalystSparkleDriver
    
    var body: some View {
        HStack {
            Button(action: sparkleDriver.installUpdate) { Text("Install And Restart") }
        }
    }
}
