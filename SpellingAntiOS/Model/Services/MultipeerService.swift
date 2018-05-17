//
//  MultipeerService.swift
//  SpellingBee
//
//  Created by Bianca Itiroko on 10/05/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerDelegate {
    func receivedText(text:String)
}

class MultipeerService:NSObject {
    //Constant for the service type that will identify the service uniquely
    private let mpType = "get-text"
    
    //DisplayName that will be visible to other devices
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: mpType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: mpType)
        
        super.init()
        self.serviceAdvertiser.delegate = self as MCNearbyServiceAdvertiserDelegate
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self as MCNearbyServiceBrowserDelegate
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        session.delegate = self as MCSessionDelegate
        return session
    }()
    
    var delegate : MultipeerDelegate?
    
    func send(message : String) {
        NSLog("%@", "sendText: text test to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
}

extension MultipeerService : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
//    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
//        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
//    }
    
    //MyTODO: this code accepts all incoming connections automatically, should it be like that?
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

extension MultipeerService : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
//    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        NSLog("%@", "foundPeer: \(peerID)")
//    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
}

extension MultipeerService : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    //Se quisermos dar display de quem está conectado
    
//    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
//        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
//        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
//            session.connectedPeers.map{$0.displayName})
//    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.receivedText(text: str)
    }
    
}
