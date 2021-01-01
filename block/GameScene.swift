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
    
    private let blockMargin: CGFloat = 16.0
    private let paddleSpeed = 2.0
    private var paddleNode: SKSpriteNode?
    
    override init(size: CGSize) {
        super.init(size: size)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.contactDelegate = self
        self.addBlocks()
        self.addPaddle()
        self.addBall()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addBlocks() {
        // initial config
        let rows = 5
        let cols = 6
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
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123: addDirection(.left)
        case 124: addDirection(.right)
        case 0x31: // space
            break
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func addDirection(_ newDir: PaddleDirection) {
        var x: CGFloat = self.paddleNode!.size.width
        switch newDir {
        case .left:
            x *= -1
        case .right:
            x *= 1
        }
        let move = SKAction.move(to: CGPoint(x: self.paddleNode!.position.x + x, y: self.paddleNode!.position.y), duration: 1.0)
        self.paddleNode?.run(move)
    }
}
