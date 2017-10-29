//
//  ViewController.swift
//  ARDemo4
//
//  Created by xuwenhao on 2017/10/25.
//  Copyright © 2017年 Hiniu. All rights reserved.
//  一个保龄球游戏  主要为了巩固碰撞的知识

import UIKit
import SceneKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(scenV)
        setUI()
    }
    
    let forcpros = UIView.init()
    let posiSlid = UISlider.init()
    let shotVslid = UISlider.init()
    let shotBtn = UIButton.init(type: UIButtonType.custom)
    let refshBtn = UIButton.init(type: UIButtonType.custom)
    
    let sc_w = UIScreen.main.bounds.width
    let sc_h = UIScreen.main.bounds.height
 
    var rolNodeArry = [SCNNode]()
    //地板分类 2  球 4 木块8
    func setUI()  {
       let boxNode = scenV.scene?.rootNode.childNode(withName: "box", recursively: true)
       let boxGem = boxNode?.geometry as! SCNBox
        /*
         上面有力度条 下面有角度条 位置条  再加一个投射按钮   基本动作
         */
        forcpros.frame = CGRect.init(x: 0, y: 0, width: sc_w - 100, height: 10)

        forcpros.backgroundColor = UIColor.red
        forcpros.clipsToBounds = true
        forcpros.layer.cornerRadius = 5
        forcpros.layer.anchorPoint = CGPoint.init(x: 0, y: 0.5)
        forcpros.layer.position = CGPoint.init(x: 50, y: 100)
        self.view.addSubview(forcpros)
        
        
        posiSlid.frame = CGRect.init(x: 50, y: sc_h - 200, width: sc_w - 100, height: 30)
        posiSlid.value = 0
        posiSlid.isContinuous = true
        posiSlid.addTarget(self, action: #selector(posiValueChange(slide:)), for: .valueChanged)
        self.view.addSubview(posiSlid)
        
        shotVslid.frame = CGRect.init(x: 50, y: sc_h - 150, width: sc_w - 100, height: 30)
        shotVslid.isContinuous = true
        shotVslid.addTarget(self, action: #selector(shotDValueChange(slide:)), for: .valueChanged)
        shotVslid.value = 0
        self.view.addSubview(shotVslid)
        
        shotBtn.setTitle("发射", for: .normal)
        shotBtn.setTitleColor(UIColor.orange, for: .normal)
        shotBtn.backgroundColor = UIColor.green
        shotBtn.clipsToBounds = true
        shotBtn.layer.cornerRadius = 10
        shotBtn.frame = CGRect.init(x: 0 , y: 0, width: 100, height: 50)
        shotBtn.center = CGPoint.init(x: sc_w/2+100, y: sc_h - 70)
        shotBtn.addTarget(self, action: #selector(shotClick(btn:)), for: .touchUpInside)
        self.view.addSubview(shotBtn)
        
        refshBtn.setTitle("重置", for: .normal)
        refshBtn.setTitleColor(UIColor.orange, for: .normal)
        refshBtn.backgroundColor = UIColor.green
        refshBtn.clipsToBounds = true
        refshBtn.layer.cornerRadius = 10
        refshBtn.frame = CGRect.init(x: 0 , y: 0, width: 100, height: 50)
        refshBtn.center = CGPoint.init(x: sc_w/2-100, y: sc_h - 70)
        refshBtn.addTarget(self, action: #selector(refshClick), for: .touchUpInside)
        self.view.addSubview(refshBtn)

        
        //所有的瓶子（柱子）
        let rollW = boxGem.width/5
        let rolH :CGFloat = 1
        let boxH = boxGem.height
        let boxL = boxGem.length
        for index in 0..<5 {
            let rolGem = SCNCylinder.init(radius: rollW/2, height: rolH)
            rolGem.firstMaterial?.diffuse.contents = UIColor.white
            let rolNode = SCNNode.init(geometry: rolGem)
            let offx = Float(index)*Float(rollW) + Float(rollW)/2 - Float(boxGem.width/2)
            let offy = Float(rolH/2 + boxH/2)
            let offZ = Float(rollW/2 - boxL/2)
            rolNode.position = SCNVector3Make(offx, offy , offZ)
            rolNode.physicsBody = getRolPhySte()
            boxNode?.addChildNode(rolNode)
            rolNodeArry.append(rolNode)
        }
        self.reSetUI()
    }

    //物理特性
    func getRolPhySte() ->SCNPhysicsBody {
        let body = SCNPhysicsBody.dynamic()
        body.velocity = SCNVector3Zero
        body.friction = 0.1
        body.mass = 1
        body.rollingFriction = 0
        body.damping = 0
        body.angularDamping = 0.1
        body.restitution = 1
        body.categoryBitMask = 8
        body.collisionBitMask = 14
        body.isAffectedByGravity = true
        return body
    }
    
    func getBallPhySte() ->SCNPhysicsBody {
        let body = SCNPhysicsBody.dynamic()
        body.velocity = SCNVector3Zero
        body.friction = 0.1
        body.mass = 1
        body.rollingFriction = 0
        body.damping = 0
        body.angularDamping = 0.1
        body.restitution = 1
        body.categoryBitMask = 4
        body.collisionBitMask = 10
        body.isAffectedByGravity = true
        return body
    }
    
    

    //初始化 位置  调节器的值
    var isShot = false //是否射出
    func reSetUI()  {
        isShot = false
        shotBtn.isUserInteractionEnabled = true
        //  力度开始动画
        addForcAnima()
    
        posiSlid.value = 0.5
        shotVslid.value = 0.5 //偏转系数
   
        let boxNode = scenV.scene?.rootNode.childNode(withName: "box", recursively: true)
        let boxGem = boxNode?.geometry as! SCNBox
        let rollW = boxGem.width/5
        let rolH :CGFloat = 1
        let boxH = boxGem.height
        let boxL = boxGem.length
        for (index,value) in rolNodeArry.enumerated() {
            let offx = Float(index)*Float(rollW) + Float(rollW)/2 - Float(boxGem.width/2)
            let offy = Float(rolH/2 + boxH/2)
            let offZ = Float(rollW/2 - boxL/2)
            value.physicsBody = getRolPhySte()
            value.position = SCNVector3Make(offx, offy , offZ)
        }
        let ballNode = scenV.scene?.rootNode.childNode(withName: "ball", recursively: true)
        let ballGem = ballNode?.geometry as! SCNSphere
        ballNode?.physicsBody = getBallPhySte()
        ballNode?.position = SCNVector3Make(0, Float(boxH/2 + ballGem.radius), Float(boxL/2 - 0.5))
        refshLineNode()
    }
    
    func addForcAnima()  {
        
        forcpros.bounds = CGRect.init(x: 0, y: 0, width: 0, height: 10)
        forcpros.layer.removeAllAnimations()
        let movAnima = CABasicAnimation.init(keyPath: "bounds.size.width")
        movAnima.fromValue = 0
        movAnima.toValue = sc_w - 100
        movAnima.duration = 3
        movAnima.autoreverses = true
        movAnima.repeatCount = .greatestFiniteMagnitude
        forcpros.layer.add(movAnima, forKey: "move")
    }
    
    
    //添加角度虚线基本来讲  就是球中心点 与底线某点的连线
    
    func refshLineNode()  {
        let boxNode = scenV.scene?.rootNode.childNode(withName: "box", recursively: true)
        let boxGem = boxNode?.geometry as! SCNBox
        let rollW = boxGem.width/5
        let rolH :CGFloat = 1
        let boxH = boxGem.height
        let boxL = boxGem.length
        
        let ballNode = scenV.scene?.rootNode.childNode(withName: "ball", recursively: true)
        let starPosition = ballNode?.position
        let endOffx = (shotVslid.value - 0.5) * Float(boxGem.width)
        let endPosition = SCNVector3Make(endOffx, Float(rolH/2 + boxH/2), Float(rollW/2 - boxL/2))
       addLineNode(starPo: starPosition!, endPo: endPosition)
    }
    var shotVer = SCNVector3Make(0, 0, -1)//发射方向
    var linNode :SCNNode?
    func addLineNode(starPo:SCNVector3,endPo:SCNVector3)  {
        //还是用点吧
        let off = SCNVector3Make(endPo.x - starPo.x, endPo.y - starPo.y, endPo.z - starPo.z)
        let norm = simd_normalize(float3.init(off.x, off.y, off.z))
        shotVer = SCNVector3Make(norm.x, norm.y, norm.z)
        //100个点
        var valus = [SCNVector3]()
        var indes = [UInt32]()

        for i in 0..<100 {
            let i = Float(i)
            valus.append(SCNVector3Make(starPo.x + off.x*i/100, starPo.y + off.y*i/100, starPo.z + off.z*i/100))
            indes.append(UInt32(i))
        }
 
        let gemsour = SCNGeometrySource.init(vertices: valus)
        let gemele = SCNGeometryElement.init(indices: indes, primitiveType: .point)
        let gem = SCNGeometry.init(sources: [gemsour], elements: [gemele])
        
        gem.firstMaterial?.diffuse.contents = UIColor.red
        if linNode == nil {
            let boxNode = scenV.scene?.rootNode.childNode(withName: "box", recursively: true)

            linNode = SCNNode.init()
            boxNode?.addChildNode(linNode!)
        }
        linNode?.geometry = gem
    }
    
 

    @objc func posiValueChange(slide:UISlider)  {
        if isShot {
            return
        }
        let boxNode = scenV.scene?.rootNode.childNode(withName: "box", recursively: true)
        let boxGem = boxNode?.geometry as! SCNBox
        let boxW = boxGem.width
        
        let value = slide.value
        let offx = (value - 0.5)*Float(boxW)
        
        let ballNode = scenV.scene?.rootNode.childNode(withName: "ball", recursively: true)
        let oldPo = ballNode?.position
        ballNode?.position = SCNVector3Make(offx, (oldPo?.y)!, (oldPo?.z)!)
        refshLineNode()
    }

    @objc func shotDValueChange(slide:UISlider)  {
        if isShot {
            return
        }
        refshLineNode()
    }
    
    @objc func shotClick(btn:UIButton) {
        if isShot {
            return
        }
        isShot = true
        let forcW = forcpros.layer.presentation()
        forcW?.removeAllAnimations()
        forcpros.bounds = (forcW?.bounds)!
        let verNum = Float(forcpros.bounds.width/(sc_w - 100) * 10 + 1)

        let ballNode = scenV.scene?.rootNode.childNode(withName: "ball", recursively: true)
        //发射方向已知   旋转方向xz平面垂直  方向
        ballNode?.physicsBody?.velocity = SCNVector3Make(verNum*shotVer.x, verNum*shotVer.y, verNum*shotVer.z)
//        ballNode?.physicsBody?.angularVelocity = SCNVector4Make(1, 0, 0, Float.pi/5)
        linNode?.removeFromParentNode()
        linNode = nil
    }
    
    
    @objc func refshClick(){
        if !isShot {
            return
        }
        isShot = false
        self.reSetUI()
    }
    
    

    
    lazy var scenV  : SCNView = {
        let v = SCNView.init(frame: UIScreen.main.bounds)
        v.scene = SCNScene.init(named: "bollScene.scn")
        v.allowsCameraControl = false
        v.isPlaying = true
        
        v.backgroundColor = UIColor.black
        return v
    }()
    


}

