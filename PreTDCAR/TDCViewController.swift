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
    
    //MARK: Objects
    
    func addCube(parent: SCNNode) -> SCNNode{
        // As medidas são em metros, então construímos um cubo de 0.2m == 20cm
        let cubeGeometry: SCNBox = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        // Aplicamos uma cor ao material difuso padrão
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
        //Adicionamos o cubo ao centro do parent
        let cube = addCube(parent: arSceneView.scene.rootNode)
        //Adicionamos a scene ao nosso root
        //        addScene(parent: arSceneView.scene.rootNode, name: "BasicScene.scn")
        //Adicionamos a tree ao nosso root quatro metros atrás do cubo
        addTree(parent: arSceneView.scene.rootNode, position: SCNVector3(x: 0, y: 0 , z: -4))
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

