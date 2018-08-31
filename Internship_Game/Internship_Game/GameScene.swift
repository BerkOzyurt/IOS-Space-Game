//
//  GameScene.swift
//  Internship_Game
//
//  Created by Berk Ozyurt on 1.08.2018.
//  Copyright © 2018 Berk Ozyurt. All rights reserved.
//

import SpriteKit

var Score = 0

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    
    let label_score = SKLabelNode(fontNamed: "The Bold Font")
    
    var level = 0
    
    var lives = 5
    let label_lives = SKLabelNode(fontNamed: "The Bold Font")
    
    
    let player = SKSpriteNode(imageNamed: "ship")
    
    let bullet_sound = SKAction.playSoundFileNamed("sound_preview.mp3", waitForCompletion: false)
    
    let explosion_sound = SKAction.playSoundFileNamed("explosionSoundEffect", waitForCompletion: false)
    
    let StartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    
    var currentState = gameState.preGame
    
    struct PhysicsType {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    
    var gameArea: CGRect
    override init(size: CGSize){
        let maxAspectRatio : CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        Score = 0
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1{
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0  )
            background.position = CGPoint(x: self.size.width/2,
                                          y: self.size.height*CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
            
        }
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsType.Player
        player.physicsBody!.collisionBitMask = PhysicsType.None
        player.physicsBody!.contactTestBitMask = PhysicsType.Enemy
        self.addChild(player)
        
        label_score.text = "Score : 0"
        label_score.fontSize = 80
        label_score.fontColor = SKColor.white
        label_score.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        label_score.position = CGPoint(x: self.size.width*0.15, y: self.size.height + label_score.frame.size.height)
        label_score.zPosition = 100
        self.addChild(label_score)
        
        label_lives.text = "Lives : 5"
        label_lives.fontSize = 80
        label_lives.fontColor = SKColor.white
        label_lives.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        label_lives.position = CGPoint(x: self.size.width*0.85, y: self.size.height + label_lives.frame.size.height)
        label_lives.zPosition = 100
        self.addChild(label_lives)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        label_score.run(moveOnToScreenAction)
        label_lives.run(moveOnToScreenAction)
        
        StartLabel.text = "Click For Begin"
        StartLabel.fontSize = 120
        StartLabel.fontColor = SKColor.white
        StartLabel.zPosition = 1
        StartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        StartLabel.alpha = 0
        self.addChild(StartLabel)

        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        StartLabel.run(fadeInAction)
        
    }
    
    var lastUpdateTime : TimeInterval = 0
    var deltaFrameTime :TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    //Arka planı hareket ettirmek için gerekli olan kod.
    
    override func update(_ currentTime: TimeInterval){
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodes(withName: "Background") {
            background, stop in
            if self.currentState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
        
    }
    
    func startGame(){
        currentState = gameState.inGame
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        StartLabel.run(deleteSequence)
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
        
    }
    
    func LifeChanger(){
        lives -= 1
        label_lives.text = "Lives : \(lives)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        label_lives.run(scaleSequence)
        
        if lives == 0 {
            runGameOver()
        }
    }
    
    
	
    
    func runGameOver(){
        currentState = gameState.afterGame
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet") {
            bullet, stop in
            bullet.removeAllActions()
            
        }
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        _ = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneAction)
    }
    
    func changeScene(){
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()	
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsType.Player && body2.categoryBitMask == PhysicsType.Enemy{
            //if the player has hit enemy
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
            
        }
        
        if body1.categoryBitMask == PhysicsType.Bullet && body2.categoryBitMask == PhysicsType.Enemy && (body2.node?.position.y)! < self.size.height {
            //if the bullet hit the enemy
            ScoreChanger()
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    func ScoreChanger(){
        Score += 1
        label_score.text = "Score : \(Score)"
        
        if Score == 10 || Score == 25 || Score == 50 {
            startNewLevel()
        }
    }
    func spawnExplosion(spawnPosition: CGPoint){
        let explositon = SKSpriteNode(imageNamed: "explosition")
        explositon.position = spawnPosition
        explositon.zPosition = 3
        explositon.setScale(0)
        self.addChild(explositon)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        
        let explosionSequence = SKAction.sequence([explosion_sound, scaleIn, fadeOut, delete])
        explositon.run(explosionSequence)
    }
    
    func startNewLevel(){
        level += 1
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        switch level {
        case 1:
            levelDuration = 1.2
        case 2:
            levelDuration = 1
        case 3:
            levelDuration = 0.8
        case 4:
            levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn  = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
        
    }
    
    func fireBullet(){
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsType.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsType.None
        bullet.physicsBody!.contactTestBitMask = PhysicsType.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bullet_sound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    func spawnEnemy(){
        let randomXStart = random(min: 0, max: 1250)
        let randomXEnd = random(min: 0, max: 1250)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsType.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsType.None
        enemy.physicsBody!.contactTestBitMask = PhysicsType.Player | PhysicsType.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(LifeChanger)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentState == gameState.inGame{
            enemy.run(enemySequence)
            
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentState == gameState.preGame{
            startGame()
        }
        else if currentState == gameState.inGame{
            fireBullet()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let TouchPoint = touch.location(in: self)
            let previousPoint = touch.previousLocation(in: self)
            let amountDragged =  TouchPoint.x - previousPoint.x
            if currentState == gameState.inGame{
                player.position.x += amountDragged
            }
            /*
            if player.position.x > gameArea - player.size.width/2  {
                player.position.x = CGRectGetMaxX(gameArea) - player.size.width/2
            }
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width/2{
                player.position.x = CGRectGetMinX(gameArea) + player.size.width/2
            }*/
            
            
        }
    }
}
