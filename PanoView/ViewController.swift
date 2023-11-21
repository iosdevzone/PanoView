//
//  ViewController.swift
//  PanoView
//
//  Created by idz on 5/1/16.
//  Copyright © 2016 iOS Developer Zone.
//  License: MIT https://raw.githubusercontent.com/iosdevzone/PanoView/master/LICENSE
//

import UIKit
import SceneKit
import CoreMotion
import OSLog

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    let cameraNode = SCNNode()
    
    
    @IBOutlet weak var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load assets
        guard let imagePath = Bundle.main.path(forResource: "Hellbrunn25", ofType: "jpg") else {
            fatalError("Failed to find path for panaromic file.")
        }
        guard let image = UIImage(contentsOfFile:imagePath) else {
            fatalError("Failed to load panoramic image")
        }
        
        // Set the scene
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = true
        
        //Create node, containing a sphere, using the panoramic image as a texture
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = image
        
        let sphere = SCNSphere(radius: 20.0)
        sphere.materials = [material]
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(0,0,0)
        scene.rootNode.addChildNode(sphereNode)
        
        // Camera, ...
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // This used be a fatalError, but just logging it
        // allows us to run on the simulator.
        guard motionManager.isDeviceMotionAvailable else {
            os_log("Device motion is not available", type: .info)
            return
        }
        
        // Action
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {
            data , error in
            
            guard let data = data else { return }
            
            let attitude: CMAttitude = data.attitude
            self.cameraNode.eulerAngles = SCNVector3Make(Float(attitude.roll - .pi/2.0), Float(attitude.yaw), Float(attitude.pitch))
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

