//
//  GameScene.swift
//  QuantChess
//
//  Created by  Mike Check on 02.04.2018.
//  Copyright © 2018 Alonso Quixano. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene
{
    var board: Board! //!!!!!!!!!!!!BAD BAD BAD BAD BAD BAD!!!!!!!!!!!!!!!!
    var turn: Int = 1
    override func didMove(to view: SKView)
    {
        self.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1.0)
        board = Board(imageNamed: "TestBoard")
        board.create(ParentNode: self)
        board.showboard.update(boards: board.boards)
        board.showboard.draw(parent: board)
    }
    
    var smb_touched = false//Выбрана ли фигура для хода
    var touchedNode: Figure?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in (touches)
        {
            let location = touch.location(in: self)
            let Node = atPoint(location)
            if Node is stamp
            {
                board.removeFromParent()
                board = Board(imageNamed: "TestBoard")
                board.create(ParentNode: self)
                board.showboard.update(boards: board.boards)
                board.showboard.draw(parent: board)
                turn = 1
                touchedNode = nil
                smb_touched = false
            }
            let TapNode = Node as? Figure
            if touch.tapCount == 1
            {
                if !smb_touched && TapNode?.g_col == turn || TapNode == touchedNode
                {
                    touchedNode = TapNode
                    if let node = touchedNode
                    {
                        smb_touched = !smb_touched //IMPORTANT!!! DO NOT MAKE TRUE IN CASE YOU'VE MISSED
                        node.onTap(parent: board)
                    }
                }
                else
                if smb_touched && touchedNode != nil
                {
                    let move_position = touch.location(in: board)
                    let dx = ((move_position.x - touchedNode!.position.x)/board.CellSize).rounded(.toNearestOrAwayFromZero)
                    let dy = ((move_position.y - touchedNode!.position.y)/board.CellSize).rounded(.toNearestOrAwayFromZero)
                    if (touchedNode!.moveby(dx: dx, dy: dy, parent: board)) //Don't understand why '!'
                    {
                        smb_touched = !smb_touched
                        turn = -turn
                        touchedNode = nil
                        if board.showboard.check(boards: board.boards)
                        {
                            smb_touched = true
                            if board.boards[Int(arc4random_uniform(UInt32(board.boards.count)))].win == -1
                            {
                                //black wins
                                let _ = stamp(col: -1, parent: board)
                            }
                            else
                            {
                                //white wins
                                let _ = stamp(col: 1, parent: board)
                            }
                        }
                    }
                }
            }
            else if touch.tapCount == 2
            {
                if !smb_touched && TapNode?.g_col == turn || TapNode == touchedNode
                {
                    touchedNode = TapNode
                    if let node = touchedNode
                    {
                        node.onDoubleTap()
                    }
                }
            }
        }
    }
}



