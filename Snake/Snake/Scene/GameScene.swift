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

struct Point {
    var node:SKSpriteNode
    var x:Int
    var y:Int
    
    func setPhysics() {
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        
        node.physicsBody!.affectedByGravity = false
    }
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    var food:Point!
    var snake: [Point] = []
    var frames: [Point] = []
    let POINT_SIZE = 10
    
    func didBeginContact(contact: SKPhysicsContact){
        print("Contact!")
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        layoutScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let head = snake.removeFirst()
        let point = createYellowPoint(x: head.x, y: head.y + 1)
        snake.append(point)
        addChild(point.node)
        head.node.removeFromParent()
    }
    
    func layoutScene(){
        backgroundColor = UIColor(red: 44/255, green:62/255, blue: 80/255, alpha:1.0)
        spawnFood()
        spawnFrames()
        spawnSnake()
    }
    
    func spawnFood(){
        let node = SKSpriteNode(
            color: UIColor(red:1.0, green:0.0, blue: 0.0, alpha: 1.0),
            size: CGSize(width: POINT_SIZE, height: POINT_SIZE))
        let x = arc4random_uniform(UInt32((frame.width - CGFloat( 3*POINT_SIZE))))
        let y = arc4random_uniform(UInt32((frame.height - CGFloat( 3*POINT_SIZE))))
        node.position = CGPoint(x: Int( x), y:Int( y))
        addChild(node)
        food = Point(node: node, x: Int(x), y: Int(y))
        food.setPhysics()
    }
    
    func spawnFrames() {
        let width = Int(frame.width)
        let height = Int( frame.height)
        createHorisontalFrame(y: 0, minX: 0, maxX: width)
        createHorisontalFrame(y: height, minX: 0, maxX: width)
        createVerticalFrame(x: 0, minY: 0, maxY: height)
        createVerticalFrame(x: width, minY: 0, maxY: height)
    }
    
    func spawnSnake(){
        
        createSnake(x: Int(frame.midX), y: Int(frame.midY))
        
    }
    
    func createBluePoint(x:Int, y:Int) -> Point {
        let node = SKSpriteNode(
            color: UIColor(red:0.0, green:0.0, blue: 1.0, alpha: 1.0),
            size: CGSize(width: POINT_SIZE, height: POINT_SIZE))
        node.position = CGPoint(x:  x, y: y)
        return Point(node: node, x: x, y: y)
    }
    
    func createYellowPoint(x:Int, y:Int) -> Point {
        let node = SKSpriteNode(
            color: UIColor(red:1.0, green:1.0, blue: 0.0, alpha: 1.0),
            size: CGSize(width: POINT_SIZE, height: POINT_SIZE))
        node.position = CGPoint(x:  x, y: y)
        return Point(node: node, x: x, y: y)
    }
    
    func createHorisontalFrame(y:Int, minX:Int, maxX: Int){
        for i in stride(from: minX, to: maxX, by: POINT_SIZE){
            let point = createBluePoint(x: i, y: y)
            addChild(point.node)
            frames.append(point)
        }
    }
    
    func createVerticalFrame(x:Int, minY:Int, maxY: Int){
        for i in stride(from: minY, to: maxY, by: POINT_SIZE){
            let point = createBluePoint(x: x, y: i)
            addChild(point.node)
            frames.append(point)
        }
    }
    
    func createSnake(x:Int, y:Int){
        for i in 0...2 {
            let point = createYellowPoint(x: x+POINT_SIZE*i, y: y+POINT_SIZE*i)
            addChild(point.node)
            snake.append(point)
        }
    }
}
