//
//  GameOverScene.swift
//  Internship_Game
//
//  Created by Berk Ozyurt on 6.08.2018.
//  Copyright © 2018 Berk Ozyurt. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene : SKScene{
    let restartLAbel = SKLabelNode(fontNamed: "The Bold Font")
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let gameOverLabel = SKLabelNode(fontNamed: "The Bold Font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 220
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        let label_score = SKLabelNode(fontNamed: "The Bold Font")
        label_score.text = "Score : \(Score)"
        label_score.fontSize = 135
        label_score.fontColor = SKColor.white
        label_score.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        label_score.zPosition = 1
        self.addChild(label_score)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        if Score > highScoreNumber{
            highScoreNumber = Score
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        let highScoreLAbel = SKLabelNode(fontNamed: "The Bold Font")
        highScoreLAbel.text = "High Scorre : \(highScoreNumber)"
        highScoreLAbel.fontSize = 135
        highScoreLAbel.fontColor = SKColor.white
        highScoreLAbel.zPosition = 1
        highScoreLAbel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        self.addChild(highScoreLAbel)
        
        let restartLAbel = SKLabelNode(fontNamed: "The Bold Font")
        restartLAbel.text = "Restart"
        restartLAbel.fontSize = 100
        restartLAbel.fontColor = SKColor.white
        restartLAbel.zPosition = 1
        restartLAbel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        self.addChild(restartLAbel)
        
    }
    
    func changeScene(){
        let sceneToMoveTo = GameScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        _ = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneAction)
        
        /*for touch: AnyObject in touches{
            let TouchPoint = touch.location(in: self)
            if restartLAbel.contains(TouchPoint){
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }*/
    }
    
}
