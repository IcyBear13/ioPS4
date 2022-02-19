//
//  MainView.swift
//  Created by Even for ioPS4 
//  19/02/2022
//  

import SwiftUI

struct MainView: View {
    @State var payload = ""
    @AppStorage("ip") var ip = ""
    @AppStorage("port") var port = ""
    @State var showDocPicker = false
    @State var running = false
    
    @State var showBanner = false
    @State var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "Notification Title", detail: "Notification text for the action you were trying to perform.", type: .Warning)
    
    @State var showInfo = false
    
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Image("ps4")
                .resizable()
                .frame(width: 160, height: 160, alignment: .center)
            
            
            Text("ioPS4")
                .font(.system(size: 28, weight: .bold))
            
            Text(payload.isEmpty ? "Select a payload to continue" : payload.split(separator: "/").last ?? "Error")
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            
            TextField("IP", text: $ip)
                .textFieldStyle(.roundedBorder)
                .frame(width: 180, alignment: .center)
                .padding(.top)
                .padding(.top)
                .disabled(running)
            
            TextField("Port", text: $port)
                .textFieldStyle(.roundedBorder)
                .frame(width: 180, alignment: .center)
                .disabled(running)
            
            Spacer()
            Button {
                showDocPicker = true
            } label: {
                Text("Change Payload")
                    .font(.system(size: 18, weight: .semibold))
                    .padding()
                    .frame(maxWidth: 400, alignment: .center)
                    .background(Color.accentColor.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .transition(.opacity)
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .opacity(payload.isEmpty ? 0 : 1)
            }
            .disabled(running)
            
            if (!payload.isEmpty) {
                Button {
                    if (!payload.isEmpty) {
                        if !ip.isEmpty {
                            if !port.isEmpty {
                                guard FileManager.default.isReadableFile(atPath: payload) else {
                                    print("ERROR: Can't read payload")
                                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                                    self.bannerData = .init(title: "Error", detail: "Couldn't read payload", type: .Error)
                                    self.showBanner = true
                                    return
                                }
                                
                                guard let portInt = Int32(port) else {
                                    print("ERROR: Invalid port")
                                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                                    self.bannerData = .init(title: "Error", detail: "Invalid port", type: .Error)
                                    self.showBanner = true
                                    return
                                }
                                
                                running = true
                                DispatchQueue.global(qos: .background).async { [self] in
                                    let ret = Payload.Payload(addr: ip, port: portInt, payload: try! Data(contentsOf: URL(fileURLWithPath: payload)))
                                    if let returnStr = ret.str {
                                        print(returnStr)
                                        if ret.sucess {
                                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                                            self.bannerData = .init(title: "Success", detail: returnStr, type: .Success)
                                        } else {
                                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                                            self.bannerData = .init(title: "Error", detail: returnStr, type: .Error)
                                        }
                                        self.showBanner = true
                                        running = false
                                    }
                                }
                            } else {
                                print("ERROR: Port not specified")
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                                self.bannerData = .init(title: "Error", detail: "Please enter the port", type: .Error)
                                self.showBanner = true
                            }
                        } else {
                            print("ERROR: IP not specified")
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            self.bannerData = .init(title: "Error", detail: "Please enter the IP to your PlayStation", type: .Error)
                            self.showBanner = true
                        }
                    } else {
                        print("ERROR: No payload selected")
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        self.bannerData = .init(title: "Error", detail: "No payload selected", type: .Error)
                        self.showBanner = true
                    }
                } label: {
                    if running {
                        ProgressView()
                            .frame(width: 21, height: 21, alignment: .center)
                            .padding()
                            .frame(maxWidth: 400, alignment: .center)
                            .background(Color.accentColor.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .transition(.opacity)
                            .padding()
                            .padding(.horizontal)
                    } else {
                        Text("Send Payload")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 400, alignment: .center)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .transition(.opacity)
                            .padding()
                            .padding(.horizontal)
                    }
                }
                .disabled(running)
            } else {
                Button {
                    showDocPicker = true
                } label: {
                    Text("Select Payload")
                        .font(.system(size: 18, weight: .semibold))
                        .padding()
                        .frame(maxWidth: 400, alignment: .center)
                        .background(Color.accentColor.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .transition(.opacity)
                        .padding()
                        .padding(.horizontal)
                }
            }
        }
        .background(DocumentPicker(showPicker: $showDocPicker, filetypes: [.init("public.data")!], completion: { path in
            payload = path
        }).frame(width: 0, height: 0))
        .overlay(VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Spacer()
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 24))
                        .padding()
                }
            }
            Spacer()
        })
        .overlay(
            Text("banner")
                .frame(width: 0, height: 0)
                .banner(data: $bannerData, show: $showBanner))
        .alert(isPresented: $showInfo) {
            Alert(title: Text("ioPS4"), message: Text("Made by Brandon Plank"), dismissButton: .default(Text("OK")))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
