//
//  BlockNode.swift
//  block
//
//  Created by Kei Kamikawa on 2021/01/01.
//

import SpriteKit

class BlockNode: SKSpriteNode {
    private (set) public var life = Int.random(in: 1 ... 5)
    
    public init(w: Double, h: Double) {
        super.init(texture: nil, color: SKColor.cyan, size: CGSize(width: w, height: h))
        self.name = "block"
        self.alpha = CGFloat(self.life) * 0.2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func decrementLife() {
        if life > 0 {
            self.life -= 1
            self.alpha = CGFloat(self.life) * 0.2
        }
    }
}
