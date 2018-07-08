//
//  ViewController.swift
//  PreTDCAR
//
//  Created by Vitor Navarro on 2018-07-04.
//  Copyright © 2018 Wattion. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var arSceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = loadScene(name: "BasicScene.scn") {
            arSceneView.scene = scene
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

    func configureARKit() {
        let worldConfiguration = ARWorldTrackingConfiguration()
        if #available(iOS 11.3, *) {
            worldConfiguration.planeDetection = [.horizontal, .vertical]
        } else {
            worldConfiguration.planeDetection = [.horizontal]
        }
        arSceneView.session.run(worldConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func addCube(parent: SCNNode) {
        // As medidas são em metros, então construímos um cubo de 0.2m == 20cm
        let cubeGeometry: SCNBox = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        // Aplicamos uma cor ao material difuso padrão
        cubeGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.position = SCNVector3(x: 0.0, y: 0.0, z: 0.0)
        parent.addChildNode(cubeNode)
    }
    
    func loadScene(name: String) -> SCNScene? {
        if let scene = SCNScene(named: name) {
            scene.rootNode.eulerAngles.x = -.pi / 2
            return scene
        }
        return nil
    }
    
    func addScene(parent:SCNNode, name: String) {
        if let scene = SCNScene(named: name) {
            parent.addChildNode(scene.rootNode)
        }
    }
    
    @IBAction func onAddObjectTouched() {
        //Adicionamos o cubo ao centro do parent
//        addCube(parent: arSceneView.scene.rootNode)
        //Adicionamos a scene ao nosso root
        addScene(parent: arSceneView.scene.rootNode, name: "BasicScene.scn")
    }
    
}

