//
//  GameScene.swift
//  block
//
//  Created by Kei Kamikawa on 2021/01/01.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    enum PaddleDirection {
        case left, right
    }
    
    private let ballCategory: UInt32 = 0x1 << 1
    
    private let maxLife = 4
    private let maxStage = 3
    private var life: Int
    private var stage: Int = 1
    
    private let blockMargin: CGFloat = 16.0
    private let paddleSpeed = 2.0
    private var paddleNode: SKSpriteNode?
    private var ballNode: SKShapeNode?
    private var lifeLabel: LifeLabel?
    
    init(size: CGSize, life: Int, stage: Int) {
        self.life = life
        self.stage = stage
        super.init(size: size)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        self.addBlocks()
        self.addPaddle()
        self.addBall()
        
        self.addLifeLabel()
        self.addStageLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addBlocks() {
        // initial config
        let rows = 4
        let cols = 8
        let margin = self.blockMargin
        let width: CGFloat = (self.frame.width - (CGFloat(cols) + 1.0) * margin) / CGFloat(cols)
        let height: CGFloat = 16.0
        
        var y: CGFloat = self.frame.height - margin - height / 2
        for _ in 0 ..< rows {
            var x: CGFloat = margin + width / 2;
            for _ in 0 ..< cols {
                let block = BlockNode(w: Double(width), h: Double(height))
                block.position = CGPoint(x: x, y: y)
                self.addChild(block)
                x += width + margin
            }
            y -= height + margin
        }
    }
    
    private func addPaddle() {
        let width = 70.0
        let height = 14.0
        let y: CGFloat = 40.0
        
        let paddle = SKSpriteNode(texture: nil, color: SKColor.brown, size: CGSize(width: width, height: height))
        paddle.name = "paddle"
        paddle.position = CGPoint(x: self.frame.midX, y: y)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody!.isDynamic = false
        self.addChild(paddle)
        self.paddleNode = paddle
    }
    
    private func addBall() {
        let radius: CGFloat = 6.0
        let velocityX: CGFloat = 50.0
        let velocityY: CGFloat = 120.0
        
        let ball = SKShapeNode(circleOfRadius: radius)
        ball.fillColor = SKColor.yellow
        ball.strokeColor = SKColor.clear
        ball.position = CGPoint(x: self.paddleNode!.frame.midX, y: self.paddleNode!.frame.maxY + radius)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        ball.physicsBody!.affectedByGravity = false
        ball.physicsBody!.velocity = CGVector(dx: velocityX, dy: velocityY)
        ball.physicsBody!.restitution = 1.0
        ball.physicsBody!.linearDamping = 0
        ball.physicsBody!.friction = 0
        ball.physicsBody!.usesPreciseCollisionDetection = true
        ball.physicsBody!.categoryBitMask = ballCategory
        ball.physicsBody!.contactTestBitMask = 0x1 << 0
        self.ballNode = ball
        
        self.addChild(ball)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1, body2: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if BlockNode.isBlockCategory(bit: body1.categoryBitMask)  && body2.categoryBitMask & self.ballCategory != 0 {
            let blockNode = body1.node as! BlockNode
            blockNode.decrementLife()
        }
    }
    
    private func addStageLabel() {
        let margin: CGFloat = 15.0
        let fontSize: CGFloat = 18.0
        
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = String(format: "STAGE %d", self.stage)
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .right
        label.fontSize = fontSize
        label.zPosition = 1.0
        label.position = CGPoint(x: self.frame.maxX - margin, y: self.frame.maxY - margin)
        label.name = "stageLabel"
        self.addChild(label)
    }
    
    private func addLifeLabel() {
        let margin: CGFloat = 15.0
        let fontSize: CGFloat = 18.0
        
        let label = LifeLabel(life: life)
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .left
        label.fontSize = fontSize
        label.zPosition = 1.0
        label.name = "lifeLabel"
        label.position = CGPoint(x: margin, y: self.frame.maxY - margin)
        label.updateText()
        self.lifeLabel = label
        
        self.addChild(label)
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let pw = self.paddleNode!.size.width / 2
        var moveToX: CGFloat = location.x
        if location.x < pw {
            moveToX = pw + self.blockMargin
        } else if location.x > self.frame.maxX - pw {
            moveToX = self.frame.maxX - pw - self.blockMargin
        }
        
        let move = SKAction.moveTo(x: moveToX, duration: 0.5)
        self.paddleNode?.run(move)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if Int(currentTime) % 5 == 0 {
            var vec = self.ballNode?.physicsBody!.velocity
            vec?.dx *= 1.001
            vec?.dy *= 1.001
            self.ballNode?.physicsBody!.velocity = vec ?? CGVector(dx: 1.0, dy: 1.0)
        }
    }
    
    func blockNodes() -> [SKNode] {
        var ret: [SKNode] = []
        self.enumerateChildNodes(withName: "block") {
            (node: SKNode, _) in
            ret.append(node)
        }
        return ret
    }
    
    override func didEvaluateActions() {
        if self.blockNodes().count < 1 {
            self.nextLevel()
        }
    }
    
    override func didSimulatePhysics() {
        let ballY = self.ballNode!.position.y
        let ballRadius = self.ballNode!.path!.boundingBox.width
        if ballY < ballRadius * 2 {
            if !self.decrementLife() {
                self.gameOver()
            }
        }
    }
    
    func decrementLife() -> Bool {
        if self.life > 1 {
            self.life -= 1
            self.lifeLabel?.decrementLife()
            resetPosition()
            return true
        }
        return false
    }
    
    func resetPosition() {
        let ballRadius = self.ballNode!.path!.boundingBox.width
        self.paddleNode!.position = CGPoint(x: self.frame.midX, y: self.paddleNode!.position.y)
        self.ballNode!.position = CGPoint(x: self.paddleNode!.frame.midX, y: self.paddleNode!.frame.maxY + ballRadius)
    }
    
    func gameOver() {
        let scene = GameOverScene(size: self.size)
        let transition = SKTransition.push(with: .down, duration: 1.0)
        self.view?.presentScene(scene, transition: transition)
    }
    
    func nextLevel() {
        let scene = GameScene(size: self.size, life: self.life, stage: self.stage + 1)
        let transition = SKTransition.push(with: .down, duration: 1.0)
        self.view?.presentScene(scene, transition: transition)
    }
}
