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
    
   var planeDetection = true
    
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
    
    //MARK: Objects
    
    func addCube(parent: SCNNode) -> SCNNode{
        let cubeGeometry: SCNBox = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        cubeGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.position = SCNVector3(x: 0.0, y: 0.0, z: -0.6)
        parent.addChildNode(cubeNode)
        return cubeNode
    }
    
    func addTree(parent: SCNNode, position: SCNVector3) {
        addObjectFrom(file: "lowpoly_tree_sample.dae", to: parent, at: position)
    }
    
    //MARK: Interface
    
    @IBAction func onAddObjectTouched() {
        let cube = addCube(parent: arSceneView.scene.rootNode)
        addTree(parent: arSceneView.scene.rootNode, position: SCNVector3(x: 0, y: 0 , z: -4))
    }
    
    
    //MARK: Plane Detection
    func addDetectedPlane(to node: SCNNode, from anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    func updateDetectedPlanes(in node: SCNNode, _ anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    
}

extension TDCViewController: ARSCNViewDelegate {
   
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (planeDetection) {
            addDetectedPlane(to: node, from: anchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if (planeDetection) {
            updateDetectedPlanes(in: node, anchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
}

