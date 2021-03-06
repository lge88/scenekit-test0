//
//  GameViewController.swift
//  scenekit-test0
//
//  Created by Li Ge on 10/13/14.
//  Copyright (c) 2014 Li Ge. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation

class GameViewController: UIViewController {
    // interesting: tag = 0 won't work..
    let SCNVIEW_TAG = 1000
    let VIDEOVIEW_TAG = 2000
    
    var arContext:ARContext? = nil
    
    func initARCallback(ctx: ARContext!) {
        
        arContext = ctx
        
        let dataSetManager = ctx.getDataSetManager()
        var ok:Bool
        
        ok = dataSetManager.createDataSetByName("stones", dataFile: "StonesAndChips.xml")
        println("create data set ok: ", ok ? "true" : "false")
        
        ok = dataSetManager.activateDataSetByName("stones")
        println("activate data set ok: ", ok ? "true" : "false")
        
        println("is retina: ", ctx.isRetina() ? "true" : "false")
        
        ok = ctx.startAR()
        println("start ar ok: ", ok ? "true" : "false")
        
        let mat = ctx.getProjectionMatrix()
        println("projection matrix: ", mat.data)
        
        dispatch_async(dispatch_get_main_queue(), {()
            // Start a loop than pull the tracked targets every 0.4 seconds.
            NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        })
    }
    
    func update() {
        let state = arContext!.getARState()
        let targets = state.getTrackedTargets() as [ARTarget]
        println("num of targets: ", targets.count)
        for target in targets {
            println("target: ", target.getName())
            println("mvMatrix: ", target.getModelViewMatrix().data)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let screenBounds = UIScreen.mainScreen().bounds;
        println("screen bounds", screenBounds);
        
        var viewFrame = self.view.frame;
        println("view frame:")
        println(viewFrame);

        initViews()
        animateScene()
        initControls()
        ARServer(size:viewFrame.size, done: initARCallback)
    }
    
    func initViews() {
        let rootView = self.view
        
        let scnView = createSceneView()
        let scene = createScene()
        scnView.scene = scene
        
        let videoView = createVideoView()
        
        rootView.addSubview(videoView)
        rootView.addSubview(scnView)
    }
    
    func createSceneView() -> SCNView {
        let rootView = self.view
        let scnView = SCNView()
        scnView.frame = rootView.bounds
        scnView.tag = SCNVIEW_TAG
        scnView.backgroundColor = UIColor.clearColor()
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        return scnView
    }
    
    func createVideoView() -> UIView {
        let rootView = self.view
        let videoView = UIView()
        
        videoView.frame = rootView.bounds
        videoView.tag = VIDEOVIEW_TAG
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let captureInput = AVCaptureDeviceInput.deviceInputWithDevice(device, error: nil) as AVCaptureDeviceInput
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetMedium
        
        if captureSession.canAddInput(captureInput) {
            captureSession.addInput(captureInput)
        }
        
        let cameraVideoLayer = AVCaptureVideoPreviewLayer.layerWithSession(captureSession) as AVCaptureVideoPreviewLayer
        captureSession.startRunning()
        
        cameraVideoLayer.frame = videoView.bounds
        videoView.layer.addSublayer(cameraVideoLayer)
        return videoView
    }
    
    func createScene() -> SCNScene {
        // create a new scene
        let scene = SCNScene()
        let boxGeometry = SCNBox(width: 1.0, height: 2.0, length: 4.0, chamferRadius: 0.0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "box"
        scene.rootNode.addChildNode(boxNode)
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        return scene
    }
    
    func getSceneView() -> SCNView {
        return self.view.viewWithTag(SCNVIEW_TAG) as SCNView
    }
    
    func getVideoView() -> UIView {
        return self.view.viewWithTag(VIDEOVIEW_TAG)!
    }
    
    func getScene() -> SCNScene {
        return getSceneView().scene!
    }
    
    func getRootNode() -> SCNNode {
        return getScene().rootNode
    }
    
    func getChildNodeByName(name: String) -> SCNNode? {
        return getRootNode().childNodeWithName(name, recursively: true)
    }
    
    func animateScene() {
        let box = getChildNodeByName("box")
        box!.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
    }
    
    func initControls() {
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        if let existingGestureRecognizers = self.view.gestureRecognizers {
            gestureRecognizers.addObjectsFromArray(existingGestureRecognizers)
        }
        let scnView = getSceneView()
        scnView.gestureRecognizers = gestureRecognizers
    }
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        let scnView = getSceneView()
        let p = gestureRecognize.locationInView(scnView)
        
        if let hitResults = scnView.hitTest(p, options: nil) {
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result: AnyObject! = hitResults[0]
                
                // get its material
                let material = result.node!.geometry!.firstMaterial!
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                // on completion - unhighlight
                SCNTransaction.setCompletionBlock {
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(0.5)
                    
                    material.emission.contents = UIColor.blackColor()
                    
                    SCNTransaction.commit()
                }
                
                material.emission.contents = UIColor.redColor()
                
                SCNTransaction.commit()
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
