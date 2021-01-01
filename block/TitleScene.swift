//
//  TitleScene.swift
//  block
//
//  Created by Kei Kamikawa on 2021/01/01.
//

import SpriteKit

class TitleScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
        let titleLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        titleLabel.text = "シューティングブロック崩し"
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        titleLabel.fontSize = 50.0
        self.addChild(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyDown(with event: NSEvent) {
        let scene = GameScene(size: self.size)
        let transition = SKTransition.push(with: .up, duration: 1.0)
        self.view!.presentScene(scene, transition: transition)
    }
}
