//
//  LifeLabel.swift
//  block
//
//  Created by Kei Kamikawa on 2021/01/02.
//

import SpriteKit

class LifeLabel: SKLabelNode {
    private var life = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    init(life: Int) {
        super.init(fontNamed: "HelveticaNeue-Bold")
        self.life = life
        self.updateText()
        self.colorBlendFactor = 1.0
        self.color = SKColor.magenta
    }
    
    public func decrementLife() {
        if self.life > 0 {
            self.life -= 1
            self.updateText()
        }
    }
    
    public func updateText() {
        self.text = String.init(repeating: "♥", count: self.life)
    }
}
