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
    var enableTouch = true
    
    //MARK: Light Properties
    
    var mainLight: SCNLight?
    var enableMainLight = true
    var autoenablesDefaultLighting = false
    var isLightEstimationEnabled = true
    var lightNodes: [SCNNode] = []
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if (enableMainLight) {
            let mainLightNode = addLight(type: .omni, at: nil, parent: nil)
            lightNodes.append(mainLightNode)
            mainLight = mainLightNode.light
        }
        
        if(enableTouch) {
            configureTouch()
        }
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
        
        configuration.isLightEstimationEnabled = isLightEstimationEnabled
        arSceneView.autoenablesDefaultLighting = autoenablesDefaultLighting
        
        arSceneView.delegate = self
        arSceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    //MARK: Objects
    
    func addCube(parent: SCNNode) -> SCNNode{
        let cubeGeometry: SCNBox = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        cubeGeometry.firstMaterial?.diffuse.contents = UIColor.white
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
    
    //MARK: Light
    func addLight(type: SCNLight.LightType, at position: SCNVector3?, parent: SCNNode?) -> SCNNode {
        let light = SCNLight()
        light.type = type
        
        let node = SCNNode()
        node.light = light
        
        if let lpos = position {
            node.position = lpos
        }
        else {
            node.position = SCNVector3(0, 1.0, 0)
        }
        
        if let parent = parent {
            parent.addChildNode(node)
        }
        else {
            arSceneView.scene.rootNode.addChildNode(node)
        }
        return node
    }
    
    //MARK: Main Light
    
    @IBAction func intensityChanged(_ sender: UISlider) {
        mainLight?.intensity = CGFloat(sender.value)
    }
    
    @IBAction func temperatureChanged(_ sender: UISlider) {
        mainLight?.temperature = CGFloat(sender.value)
    }
    
    @IBAction func colorChanged(_ sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex) {
        case 0:
            mainLight?.color = UIColor.red
            break
        case 1:
            mainLight?.color = UIColor.green
            break
        case 2:
            mainLight?.color = UIColor.blue
            break
        case 3:
            mainLight?.color = UIColor.white
            break
        default:
            mainLight?.color = UIColor.white
            break
        }
    }
    
    //MARK: Light Estimation
    func updateLightNodesLightEstimation() {
        guard let lightEstimate = self.arSceneView.session.currentFrame?.lightEstimate, isLightEstimationEnabled
            else { return }
        
        let ambientIntensity = lightEstimate.ambientIntensity
        let ambientColorTemperature = lightEstimate.ambientColorTemperature
        
        for lightNode in self.lightNodes {
            guard let light = lightNode.light else { continue }
            light.intensity = ambientIntensity
            light.temperature = ambientColorTemperature
        }
    }
    
    //MARK: Gesture
    var tap: UITapGestureRecognizer!
    
    func configureTouch() {
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        arSceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer){
        
        if recognizer.state == .ended {
            let location: CGPoint = recognizer.location(in: arSceneView)
            let hits = arSceneView.hitTest(location, options: nil)
            if !hits.isEmpty{
                let tappedNode = hits.first?.node
                let red = Double(arc4random_uniform(256))/255.0
                let green = Double(arc4random_uniform(256))/255.0
                let blue = Double(arc4random_uniform(256))/255.0
                tappedNode?.geometry?.firstMaterial?.diffuse.contents = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
                print(tappedNode ?? "")
            }
        }
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
        if(!isLightEstimationEnabled) {
            return
        }
        
        updateLightNodesLightEstimation()
    }
    
}

