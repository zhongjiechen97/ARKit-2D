//
//  Scene.swift
//  AR
//
//  Created by 陈中杰 on 2019/2/9.
//  Copyright © 2019 陈中杰. All rights reserved.
//

import SpriteKit
import ARKit
class Scene: SKScene {
    
    // SKLabelNode()用于显示一个标签
    let facelabel = SKLabelNode(text: "ghost")
    let numberoflabel = SKLabelNode(text: "0")
    // 计时器
    var creationtime : TimeInterval = 0
    // 计数器
    var facecount = 0{
        // facecount 属性变化之后执行
        didSet{
            self.numberoflabel.text = "\(facecount)"
        }
    }
    // flag为true则游戏结束
    var flag : Bool = false
    
    // 将标签添加到场景中
    override func didMove(to view: SKView) {
        // Setup your scene here
        // 设置字号、字体、颜色、位置
        facelabel.fontSize = 20
        facelabel.fontName = "DevanagariSangamMN-Bold"
        facelabel.color = .white
        facelabel.position = CGPoint(x: 40, y: 50)
        addChild(facelabel)
        
        numberoflabel.fontSize = 30
        numberoflabel.fontName = "DevanagariSangamMN-Bold"
        numberoflabel.color = .white
        numberoflabel.position = CGPoint(x:40,y:10)
        addChild(numberoflabel)
    }
    // 随机产生min - max之间的Float型数字
    func randomFloat(min:Float,max:Float) -> Float{
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    // 创建一个鬼脸
    func creatFaceAnchor() {
        // 用于获取场景视图
        guard let sceneView = self.view as? ARSKView else{
            return
        }
        // 定义一个360°
        let _360degrees = 2.0 * Float.pi
        // 分别在x、y轴上创建一个随机旋转矩阵
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 1, 0, 0))
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 0, 1, 0))
        let rotation = simd_mul(rotateX, rotateY)
        
        // 在Z轴上创建一个平移矩阵，其随机值介于-1到-2米之间
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1 - randomFloat(min: 0.0, max: 1.0)
        // 结合旋转和平移矩阵
        let transform = simd_mul(rotation, translation)
        // 创建锚点并传递transfor参数
        let anchor = ARAnchor(transform: transform)
        // 添加到会话中
        sceneView.session.add(anchor: anchor)
        // 累加计数器
        facecount+=1
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        // 渲染每帧都会调用update函数
        // currentTime表示应用程序的当前时间，如果其大于creationtime则
        // 调用createFaceAnchor()创建一个鬼脸，然后creationtime随机增加3-6秒
        if currentTime > creationtime && flag == false{
            creatFaceAnchor()
            creationtime = currentTime + TimeInterval(randomFloat(min: 3.0, max: 6.0))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touches.first获取触摸的对象
        guard let touch = touches.first else {
            return
        }
        // touch.loaction获取触摸的位置
        let location = touch.location(in: self)
        // 获取该位置的结点
        let hit = nodes(at: location)
        // hit.first获取第一个结点
        if let node = hit.first {
            // 标签也是结点，只处理名为ghost的结点
            if node.name == "ghost" {
                // 结点淡出动作
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                // 移除结点
                let remove = SKAction.removeFromParent()
                // 触摸后鬼脸消失的音效
                let killSound = SKAction.playSoundFileNamed("ghost", waitForCompletion: false)
                // 将淡出动作和音效编组起来:SKAction.group()
                let groupKillingActions = SKAction.group([fadeOut, killSound])
                // 创建一个动作序列
                let sequenceAction = SKAction.sequence([groupKillingActions, remove])
                // 执行动作序列
                node.run(sequenceAction)
                // 更新计数器
                facecount -= 1
                if facecount == 0{
                    let winlabel = SKLabelNode(text: "胜利✌️")
                    winlabel.fontSize = 50
                    winlabel.fontName = "DevanagariSangamMN-Bold"
                    winlabel.color = .red
                    winlabel.position = CGPoint(x:250,y:500)
                    addChild(winlabel)
                    flag = true
                }
            }
        }
        
    }
}
