//
//  GameScene.swift
//  Snake
//
//  Created by Vanquisher Winbringer on 03.07.2018.
//  Copyright © 2018 Vanquisher Winbringer. All rights reserved.
//

import SpriteKit
import GameplayKit
import Darwin

struct PCategory {
    static var foodCategory:UInt32 = 0x1
    static var framesCategory: UInt32 = 0x1 << 1
    static var snakeCategory: UInt32 = 0x1 << 2
}

struct Point {
    var node:SKSpriteNode
    var x:Int
    var y:Int
    
    func setPhysics(_ category: UInt32, _ contactTest: UInt32, _ isDynamic: Bool) {
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.size.width - 1, height: node.size.height - 1))
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.categoryBitMask = category
        node.physicsBody?.contactTestBitMask = contactTest
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.isDynamic = isDynamic
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var food:Point!
    var snake: [Point] = []
    var frames: [Point] = []
    private static  let POINT_SIZE = 10

    func didBegin(_ contact: SKPhysicsContact){
        let foodAndSnake = PCategory.foodCategory | PCategory.snakeCategory
        let framesAndSnake = PCategory.snakeCategory | PCategory.framesCategory
        switch contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask {
        case foodAndSnake:
            spawnFood()
            grouSnake()
        case framesAndSnake:
            layoutScene()
        case PCategory.snakeCategory:
            layoutScene()
        default:
            print("Contact O_o")
        }
    }

    func grouSnake(){
        let point = createYellowPoint(x: 1000, y: 1000)
        addChild(point.node)
        snake.append(point)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let pos =  t.location(in: self)
            touchDown(pos)
        }
    }

    func touchDown( _ pos: CGPoint){
        let p = ( Double(pos.x - self.frame.midX), Double(pos.y - frame.midY))
        switch p {
        case let (x,y) where y > 0 && y > abs(x) :
            dX = 0
            dY = GameScene.POINT_SIZE
        case let (x,y) where y < 0 && abs(y) > abs(x) :
            dX = 0
            dY =  -GameScene.POINT_SIZE
        case let (x,y) where x > 0 && x > abs(y) :
            dX = GameScene.POINT_SIZE
            dY = 0
        case let (x,y) where x < 0 && abs(x) > abs(y) :
            dX = -GameScene.POINT_SIZE
            dY = 0
        default:
            print("Center O_o")
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        layoutScene()
    }

    var dX = GameScene.POINT_SIZE
    var dY = 0

    func moveSnake(){
        var x = 0.0
        var y = 0.0
        var head = true
        for p in snake {
            let a = head ?
                SKAction.move(by: CGVector(dx:dX,dy:dY), duration: 0) :
                SKAction.move(to: CGPoint(x:x,y:y), duration: 0)
            x = Double(p.node.position.x)
            y = Double(p.node.position.y)
            p.node.run(a)
            head = false
        }
    }

    var timeDelta:TimeInterval = 0
    var oldTime:TimeInterval = 0

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        timeDelta = timeDelta + (currentTime - oldTime)
        oldTime = currentTime
        if timeDelta > 0.2 {
           moveSnake()
            timeDelta = 0
        }
    }
    
    func layoutScene(){
        backgroundColor = UIColor(red: 0, green:0, blue:0, alpha:1.0)
        dX = GameScene.POINT_SIZE
        dY = 0
        spawnFood()
        spawnFrames()
        spawnSnake()
    }
    
    func spawnFood(){
        if food != nil{
            food.node.removeFromParent()
            food = nil
        }
        let node = SKSpriteNode(
            color: UIColor(red:1.0, green:0.0, blue: 0.0, alpha: 1.0),
            size: CGSize(width: GameScene.POINT_SIZE, height: GameScene.POINT_SIZE)
        )
        let x = arc4random_uniform(UInt32((frame.width - CGFloat( 3*GameScene.POINT_SIZE))))
        let y = arc4random_uniform(UInt32((frame.height - CGFloat( 3*GameScene.POINT_SIZE))))
        node.position = CGPoint(x: Int( x), y:Int( y))
        addChild(node)
        food = Point(node: node, x: Int(x), y: Int(y))
        food.setPhysics(PCategory.foodCategory, PCategory.snakeCategory, false)
    }
    
    func spawnFrames() {
        for f in frames{
            f.node.removeFromParent()
        }
        frames = []
        let width = Int(frame.width)
        let height = Int( frame.height)
        createHorisontalFrame(y: 0, minX: 0, maxX: width)
        createHorisontalFrame(y: height, minX: 0, maxX: width)
        createVerticalFrame(x: 0, minY: 0, maxY: height)
        createVerticalFrame(x: width, minY: 0, maxY: height)
    }
    
    func spawnSnake(){
        for s in snake{
            s.node.removeFromParent()
        }
        snake = []
        createSnake(x: Int(frame.midX), y: Int(frame.midY))
    }
    
    func createBluePoint(x:Int, y:Int) -> Point {
        let node = SKSpriteNode(
            color: UIColor(red:0.0, green:0.0, blue: 1.0, alpha: 1.0),
            size: CGSize(width: GameScene.POINT_SIZE, height: GameScene.POINT_SIZE)
        )
        node.position = CGPoint(x:  x, y: y)
        let point = Point(node: node, x: x, y: y)
        point.setPhysics(PCategory.framesCategory, PCategory.snakeCategory, false)
        return point
    }
    
    func createYellowPoint(x:Int, y:Int) -> Point {
        let node = SKSpriteNode(
            color: UIColor(red:1.0, green:1.0, blue: 0.0, alpha: 1.0),
            size: CGSize(width: GameScene.POINT_SIZE, height: GameScene.POINT_SIZE))
        node.position = CGPoint(x:  x, y: y)
        let point = Point(node: node, x: x, y: y)

        point.setPhysics(PCategory.snakeCategory, PCategory.foodCategory | PCategory.framesCategory | PCategory.snakeCategory, true)
        point.node.physicsBody?.usesPreciseCollisionDetection = true
        return point
    }
    
    func createHorisontalFrame(y:Int, minX:Int, maxX: Int){
        for i in stride(from: minX, to: maxX, by: GameScene.POINT_SIZE){
            let point = createBluePoint(x: i, y: y)
            addChild(point.node)
            frames.append(point)
        }
    }
    
    func createVerticalFrame(x:Int, minY:Int, maxY: Int){
        for i in stride(from: minY, to: maxY, by: GameScene.POINT_SIZE){
            let point = createBluePoint(x: x, y: i)
            addChild(point.node)
            frames.append(point)
        }
    }
    
    func createSnake(x:Int, y:Int){
        for i in 0...2 {
            let point = createYellowPoint(x: x - GameScene.POINT_SIZE*i, y: y)
            if i == 0 {
                point.node.color = UIColor(red:1.0, green: 0.0, blue: 0.5, alpha: 1.0)
            }
            addChild(point.node)
            snake.append(point)
        }
    }
}
