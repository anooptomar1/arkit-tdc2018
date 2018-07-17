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
    
    var planeDetection = false
    var enableNodeTouch = false
    
    //MARK: Light Properties
    
    var mainLight: SCNLight?
    var enableMainLight = false
    var autoenablesDefaultLighting = false
    var isLightEstimationEnabled = true
    var updateEnvironmentalLight = true
    var lightNodes: [SCNNode] = []
    
    //MARK: Image Detection Properties
    var imageDetection = true
    @IBOutlet weak var label: UILabel!
    
    //MARK: Gesture properties
    var tap: UITapGestureRecognizer!
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        //        if let scene = loadScene(name: "BasicScene.scn") {
        //            arSceneView.scene = scene
        //        }
        
        if (enableMainLight) {
            mainLight = insertLight(type: .omni, at: nil, parent: nil).light
        }
        
        if(enableNodeTouch) {
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
        if #available(iOS 11.3, *), imageDetection {
            guard let images = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
                fatalError("Algo deu errado ao carregar do AR Resources")
            }
            configuration.detectionImages = images
        }
        
        arSceneView.autoenablesDefaultLighting = autoenablesDefaultLighting //intensidade sempre em 1000, omni directional light é adicionada a cena, a luz smepre parece vir da sua direção
        configuration.isLightEstimationEnabled = isLightEstimationEnabled // adiciona estimativa de luz para cada ARFrame, que pode ser usada para renderizar a cena, ainda assim é necessário iluminar a cena adequadamente
        
        arSceneView.delegate = self
        arSceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    //MARK: Objects
    
    func addCube(parent: SCNNode) -> SCNNode{
        let cube = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position = SCNVector3(x: 0, y: 0, z: -0.6)
        parent.addChildNode(cubeNode)
        return cubeNode
    }
    
    func loadScene(name: String) -> SCNScene? {
        if let scene = SCNScene(named: name) {
            scene.rootNode.eulerAngles.x = -.pi / 2
            return scene
        }
        return nil
    }
    
    func addTree(parent: SCNNode, position: SCNVector3) {
        addObjectFrom(file: "lowpoly_tree_sample.dae", to: parent, at: position)
    }
    
    func addWolf(parent: SCNNode, position: SCNVector3) {
        addObjectFrom(file: "wolf.obj", to: parent, at: position)
    }
    
    //MARK: Lights
    func insertLight(type: SCNLight.LightType, at position: SCNVector3?, parent: SCNNode?) -> SCNNode {
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
    
    //MARK: Light Estimation
    func updateEnvironmentalLightWithEstimation() {
        guard let lightEstimate = self.arSceneView.session.currentFrame?.lightEstimate, isLightEstimationEnabled
            else { return }

        let intensity = lightEstimate.ambientIntensity / 1000.0
        self.arSceneView.scene.lightingEnvironment.intensity = intensity
    }
    
    func updateLightNodesLightEstimation() {
        guard let lightEstimate = self.arSceneView.session.currentFrame?.lightEstimate, isLightEstimationEnabled
            else { return }
        
        //        print("Estimativa da intensidade de luz: %f", lightEstimate.ambientIntensity)
        //        print("Estimativa da temperatura de cor: %f", lightEstimate.ambientColorTemperature)
        
        let ambientIntensity = lightEstimate.ambientIntensity
        let ambientColorTemperature = lightEstimate.ambientColorTemperature
        
        for lightNode in self.lightNodes {
            guard let light = lightNode.light else { continue }
            light.intensity = ambientIntensity
            light.temperature = ambientColorTemperature
        }
    }
    
    //MARK: Interface
    
    @IBAction func onAddObjectTouched() {
        let cube = addCube(parent: arSceneView.scene.rootNode)
        addTree(parent: arSceneView.scene.rootNode, position: SCNVector3(x: 0, y: 0 , z: -4))
    }
    
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
    
    //MARK: Gesture
    func configureTouch() {
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        arSceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer){
        
        if recognizer.state == .ended {
            let location: CGPoint = recognizer.location(in: arSceneView)
            let hits = arSceneView.hitTest(location, options: nil)
            if !hits.isEmpty {
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
    
    func addDetectedPlane(to node: SCNNode, from anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.eulerAngles.x = -.pi / 2
        
        planeNode.opacity = 0.25
        
//        addCube(parent: planeNode)
        addWolf(parent: planeNode, position: SCNVector3(x: 0, y: 0 , z: 0))
//        lightNodes.append(insertLight(type: .omni, at: nil, parent: planeNode))
        
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
    
    @available(iOS 11.3, *)
    func addDetectedObjectViaImage(node: SCNNode, anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        
        let plane = SCNPlane(width: referenceImage.physicalSize.width,
                             height: referenceImage.physicalSize.height)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.25
        planeNode.eulerAngles.x = -.pi / 2
        
        DispatchQueue.main.async {
            self.label.text = referenceImage.name ?? "Not named"
        }
        
        node.addChildNode(planeNode)
    }
    
    @available(iOS 11.3, *)
    func updateDetectedObjectViaImage(in node: SCNNode, anchor: ARAnchor) {
        if imageDetection, let imageAnchor = anchor as? ARImageAnchor {
            let referenceImage = imageAnchor.referenceImage

            DispatchQueue.main.async {
                self.label.text = referenceImage.name ?? "Not named"
            }

            return
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (planeDetection) {
            addDetectedPlane(to: node, from: anchor)
        }
        if #available(iOS 11.3, *) {
            if(imageDetection) {
                addDetectedObjectViaImage(node: node, anchor: anchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if (planeDetection) {
            updateDetectedPlanes(in: node, anchor)
        }
        if #available(iOS 11.3, *) {
            if(imageDetection) {
                updateDetectedObjectViaImage(in: node, anchor: anchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if(!isLightEstimationEnabled) {
            return

        }
        if(updateEnvironmentalLight) {
            updateEnvironmentalLightWithEstimation()
        }
        updateLightNodesLightEstimation()
    }
    
}

