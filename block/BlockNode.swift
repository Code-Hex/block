//
//  BlockNode.swift
//  block
//
//  Created by Kei Kamikawa on 2021/01/01.
//

import SpriteKit

class BlockNode: SKSpriteNode {
    private static let category: UInt32 = 0x1 << 0
    private (set) public var life = Int.random(in: 1 ... 5)
    
    public init(w: Double, h: Double) {
        super.init(texture: nil, color: SKColor.cyan, size: CGSize(width: w, height: h))
        self.name = "block"
        self.alpha = CGFloat(self.life) * 0.2
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.isDynamic = false
        self.physicsBody!.categoryBitMask = BlockNode.category
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func decrementLife() {
        if life > 0 {
            self.life -= 1
            self.alpha = CGFloat(self.life) * 0.2
            
            if life == 0 {
                self.removeFromParent()
            }
        }
    }
    
    public static func isBlockCategory(bit: UInt32) -> Bool {
        return bit & category != 0
    }
}
