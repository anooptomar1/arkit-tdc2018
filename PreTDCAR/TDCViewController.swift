//
//  TDCViewController.swift
//  PreTDCAR
//
//  Created by Vitor Navarro on 2018-07-14.
//  Copyright © 2018 Wattion. All rights reserved.
//


import UIKit
import ARKit

class TDCViewController: UIViewController {
    
    @IBOutlet weak var arSceneView: ARSCNView!
    
   
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARWorldTrackingConfiguration.isSupported {
            configureARKit()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSceneView.session.pause()
    }
    
    //MARK: Configuration
    
    func configureARKit() {
        let configuration = ARWorldTrackingConfiguration()
        if #available(iOS 11.3, *) {
            configuration.planeDetection = [.horizontal, .vertical]
        } else {
            configuration.planeDetection = [.horizontal]
        }
        
        arSceneView.delegate = self
        arSceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
}

extension TDCViewController: ARSCNViewDelegate {
   
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
}

