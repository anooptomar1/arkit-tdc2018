//
//  Utils.swift
//  PreTDCAR
//
//  Created by Vitor Navarro on 2018-07-08.
//  Copyright © 2018 Wattion. All rights reserved.
//

import Foundation
import SceneKit

/*
 Carrega um arquivo suportado através de um SCNScene (obj ou dae)
 */
func collada2SCNNode(filepath:String) -> SCNNode {
    let node = SCNNode()
    //Carregamos o arquivo a partir do nome
    let scene = SCNScene(named: filepath)
    //Pegamos os filhos dele
    let nodeArray = scene!.rootNode.childNodes
    // e adicionamos como filhos do nosso SCNNode
    for childNode in nodeArray {
        
        node.addChildNode(childNode as SCNNode)
        
    }
    return node
}

func addObjectFrom(file: String, to parent: SCNNode, at position: SCNVector3) {
    let tree = collada2SCNNode(filepath: file)
    tree.position = position
    tree.scale = SCNVector3(0.1, 0.1, 0.1)
    parent.addChildNode(tree)
}
