//
//  File.swift
//  Quantum Chess
//
//  Created by  Mike Check on 11.05.2018.
//  Copyright © 2018 Alonso Quixano. All rights reserved.


import SpriteKit


class quant_board
{
    var board: [[Int]] = []
    var win: Int = 0
    var r_rook_move: [Bool] = [false, false]
    var l_rook_move: [Bool] = [false, false]
    var king_move: [Bool] = [false, false]
    init()
    {
        for _ in 0..<8
        {
            self.board.append([0, 0, 0, 0, 0, 0, 0, 0])
        }
    }
    func set(i: Int,  j: Int, val: Int)
    {
        board[i][j] = val
    }
}


class show_board
{
    var figs: [[AnyObject?]] = []
    var probability: [[Double]] = []
    init()
    {
        for _ in 0..<8
        {
            self.figs.append([nil, nil, nil, nil, nil, nil, nil, nil])
            self.probability.append([0, 0, 0, 0, 0, 0, 0, 0])
        }
    }
    func set(i: Int,  j: Int, val: AnyObject?)
    {
        figs[i][j] = val
    }
    func update(boards: [quant_board])
    {
        if boards.count == 0
        {
            return
        }
        for i in 0...7
        {
            for j in 0...7
            {
                probability[i][j] = 0
            }
        }
        for board in boards
        {
            for i in 0...7
            {
                for j in 0...7
                {
                    probability[i][j] += Double(board.board[i][j])
                }
            }
        }
        for i in 0...7
        {
            for j in 0...7
            {
                probability[i][j] = (_: probability[i][j]) / Double(boards.count)
            }
        }
    }
    
    func draw(parent: Board)
    {
        for kid in parent.children
        {
            if let child = kid as? figures
            {
                if (parent.showboard.figs[child.x][child.y] as! figures).ID != child.ID || (abs(_: parent.showboard.probability[child.x][child.y]) < 1e-8)  //if figure was removed by our, or all desks with it were destroyed
                {
                    child.removeFromParent()
                }
            }
        }
    }
    
    func check(boards: [quant_board]) -> Bool
    {
        for board in boards
        {
            if board.win == 0
            {
                return false
            }
        }
        return true
    }
}


class Board: SKSpriteNode
{
    var CellSize: CGFloat = 0
    var boundSize: CGFloat = 0
    var showboard: show_board = show_board()
    var boards: [quant_board] = [quant_board()]
    func create(ParentNode: SKNode)
    {
        ParentNode.addChild(self)
        self.size = CGSize(width: 0.5, height: 0.5)
        self.position = CGPoint(x: 0.5, y: 0.5)
        self.CellSize =  1 / 9 * size.width
        self.boundSize = 1 / 18 * size.width
        self.zPosition = -1 //Will it prevent figures from hiding?
        
        // THINK ABOUT "Friend conflict" WHEN YOU PUT THE FIGURE ON THE FIGURE OF YOUR COLOR
        // SHOULD YOU CONTROL THIS CONFLICT
        // SHOULD YOU IGNORE MERGERING FIGURES OF THE SAME TYPE IF THEY WERE NOT EQUIALENT EQUIVALENT AT THE BEGINING???
        
        //pawns
        var w_pawn: [pawn] = []
        var b_pawn: [pawn] = []
        for i in 0...7
        {
            w_pawn.append(pawn(col: 1, set_ID: i+1))
            w_pawn[i].put(ParentNode: self, position: [Int32(i), 1], boards: self.boards)
            b_pawn.append(pawn(col: -1, set_ID: -i+1))
            b_pawn[i].put(ParentNode: self, position: [Int32(i), 6], boards: self.boards)
        }
        //rooks
        let w_rook_1 = rook(col: 1, set_ID: 9)
        w_rook_1.put(ParentNode: self, position: [0, 0], boards: self.boards)
        let w_rook_2 = rook(col: 1, set_ID: 10)
        w_rook_2.put(ParentNode: self, position: [7, 0], boards: self.boards)
        let b_rook_1 = rook(col: -1, set_ID: -9)
        b_rook_1.put(ParentNode: self, position: [0, 7], boards: self.boards)
        let b_rook_2 = rook(col: -1, set_ID: -10)
        b_rook_2.put(ParentNode: self, position: [7, 7], boards: self.boards)
        //horses
        let w_horse_1 = horse(col: 1, set_ID: 11)
        w_horse_1.put(ParentNode: self, position: [1, 0], boards: self.boards)
        let w_horse_2 = horse(col: 1, set_ID: 12)
        w_horse_2.put(ParentNode: self, position: [6, 0], boards: self.boards)
        let b_horse_1 = horse(col: -1, set_ID: -11)
        b_horse_1.put(ParentNode: self, position: [1, 7], boards: self.boards)
        let b_horse_2 = horse(col: -1, set_ID: -12)
        b_horse_2.put(ParentNode: self, position: [6, 7], boards: self.boards)
        //bishops
        let w_bishop_1 = bishop(col: 1, set_ID: 13)
        w_bishop_1.put(ParentNode: self, position: [2, 0], boards: self.boards)
        let w_bishop_2 = bishop(col: 1, set_ID: 14)
        w_bishop_2.put(ParentNode: self, position: [5, 0], boards: self.boards)
        let b_bishop_1 = bishop(col: -1, set_ID: -13)
        b_bishop_1.put(ParentNode: self, position: [2, 7], boards: self.boards)
        let b_bishop_2 = bishop(col: -1, set_ID: -14)
        b_bishop_2.put(ParentNode: self, position: [5, 7], boards: self.boards)
        //queens
        let w_queen = queen(col: 1, set_ID: 15)
        w_queen.put(ParentNode: self, position: [3, 0], boards: self.boards)
        let b_queen = queen(col: -1, set_ID: -15)
        b_queen.put(ParentNode: self, position: [3, 7], boards: self.boards)
        //king
        let w_king = king(col: 1, set_ID: 16)
        w_king.put(ParentNode: self, position: [4, 0], boards: self.boards)
        let b_king = king(col: -1, set_ID: -16)
        b_king.put(ParentNode: self, position: [4, 7], boards: self.boards)
        
    }
}
