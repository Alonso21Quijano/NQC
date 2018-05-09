//
//  GameScene.swift
//  QuantChess
//
//  Created by  Mike Check on 09.04.2018.
//  Copyright © 2018 Alonso Quixano. All rights reserved.
//

import SpriteKit

class quant_board
{
    var board: [[Int]] = []
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

class Board: SKSpriteNode
{
    var CellSize: CGFloat = 0
    var boundSize: CGFloat = 0
    var boards: [quant_board] = [quant_board()]
    func create(ParentNode: SKNode)
    {
        ParentNode.addChild(self)
        self.size = CGSize(width: 0.5, height: 0.5)
        self.position = CGPoint(x: 0.5, y: 0.5)
        self.CellSize =  1 / 9 * size.width
        self.boundSize = 1 / 18 * size.width
    }
    
}


class figures: SKSpriteNode
{
    convenience init(col: Int)
    {
        if col == 1
        {self.init(imageNamed: "testfig")}
        else
        {self.init(imageNamed: "testfig")}
        g_col = col
    }
    var g_col: Int = 0
    var probability: Double = 1.0
    func corr_moves(dx: Int, dy: Int, board: quant_board) -> Int {return 1}
    var touched = 0
    let image_inc: CGFloat = 1.4
    var x: Int = 0
    var y: Int = 0
    
    
    func onTap()
    {
        if touched == 0
        {
            self.size = CGSize(width: self.size.width * image_inc, height: self.size.height * image_inc)
            touched = 1
        }
        else
        {
            self.size = CGSize(width: self.size.width / image_inc, height: self.size.height / image_inc)
            touched = 0
        }
    }

    func moveby(dx: CGFloat, dy: CGFloat, parent: Board) -> Bool
    {
        let move_x = dx * parent.CellSize
        let move_y = dy * parent.CellSize
        var did_moved: Bool = false //Show if at least on one of boards the figure was moved
        var did_blocked: Bool = false //Show if at least on one of boards the figure was blocked
        for board in parent.boards
        {
            if board.board[x][y] != 0
            {
                if (x + Int(dx) >= 0) && (y + Int(dy) >= 0) && (x + Int(dx) < 8) && (y + Int(dy) < 8) && corr_moves(dx: Int(dx), dy: Int(dy), board: board) == 1
                {
                    did_moved = true
                    onTap()
                    board.set(i: x,j: y,val: 0)
                    x += Int(dx)
                    y += Int(dy)
                    board.set(i: x, j: y, val: self.g_col)
                }
                else
                {
                    did_blocked = true
                }
            }
        }
        //let new_fig = (type(of: self)).init(col: g_col)
        //if did_moved && did_blocked
        //{
        //    let new_fig = type(of: self)
            
        //}
        if did_moved
        {self.run(SKAction.move(by: CGVector(dx: move_x,dy: move_y), duration: 0.1))}
        return did_moved
    }
    
    func put(ParentNode: Board, position: int2, board: quant_board){
        ParentNode.addChild(self)
        x = Int(position[0])
        y = Int(position[1])
        var put_x = -ParentNode.size.width / 2 + ParentNode.boundSize + 0.5 * ParentNode.CellSize
        put_x += CGFloat(position[0]) * ParentNode.CellSize //Beautiful example why this language is a piece of.....is not very good
        var put_y = -ParentNode.size.width / 2 + ParentNode.boundSize + 0.5 * ParentNode.CellSize
        put_y += CGFloat(position[1]) * ParentNode.CellSize
        self.position = CGPoint(x: put_x, y: put_y)
        self.size = CGSize(width: ParentNode.CellSize, height: ParentNode.CellSize)
        board.set(i: Int(position[0]), j: Int(position[1]), val: g_col) //Ставим фигуру на доск
    }
}


class horse: figures
{
    convenience init(col: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_horse")}
        else
        {self.init(imageNamed: "b_horse")}
        g_col = col
    }
    override func corr_moves(dx: Int, dy: Int, board: quant_board) -> Int
    {
        if board.board[x + dx][y + dy] == g_col
        {return 0}
        if (abs(dx) + abs(dy) == 3) && (abs(dx * dy) == 2)
        {
            return 1
        }
        else
        {
            return 0
        }
    }
}


class king: figures
{
    convenience init(col: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_king")}
        else
        {self.init(imageNamed: "b_king")}
        g_col = col
    }
    override func corr_moves(dx: Int, dy: Int, board: quant_board) -> Int
    {
        if board.board[x + dx][y + dy] == g_col
        {return 0}
        if (abs(dx) <= 1) && (abs(dy) <= 1) && (abs(dx) + abs(dy) != 0)
        {
            return 1
        }
        else
        {
            return 0
        }
    }
}


class queen: figures
{
    convenience init(col: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_queen")}
        else
        {self.init(imageNamed: "b_queen")}
        g_col = col
    }
    
    override func corr_moves(dx: Int, dy: Int, board: quant_board) -> Int
    {
        if board.board[x + dx][y + dy] == g_col
        {return 0}
        let kx = (dx == 0) ? 0 : Int(dx / abs(dx))
        let ky = (dy == 0) ? 0 : Int(dy / abs(dy))
        let d: Int = max(_: abs(dx), _: abs(dy))
        if abs(dx) != abs(dy) && dx*dy != 0 || abs(dx) + abs(dy) == 0
        {return 0}
        if d > 1 //this language makes me suffer
        {
            for i in 1 ..< d
            {
                if board.board[x + i*kx][y + i*ky] != 0
                {return 0}
            }
        }
        return 1
    }
}


class rook: figures
{
    convenience init(col: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_rook")}
        else
        {self.init(imageNamed: "b_rook")}
        g_col = col
    }
    
    override func corr_moves(dx: Int, dy: Int, board: quant_board) -> Int
    {
        if board.board[x + dx][y + dy] == g_col
        {return 0}
        let kx = (dx == 0) ? 0 : Int(dx / abs(dx))
        let ky = (dy == 0) ? 0 : Int(dy / abs(dy))
        let d: Int = max(_: abs(dx), _ : abs(dy))
        if kx*ky != 0 || abs(dx) + abs(dy) == 0
        {return 0}
        if d > 1 //this language makes me suffer
        {
            for i in 1 ..< d
            {
                if board.board[x + i*kx][y + i*ky] != 0
                {return 0}
            }
        }
        
        return 1
    }
}


class bishop: figures
{
    convenience init(col: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_bishop")}
        else
        {self.init(imageNamed: "b_bishop")}
        g_col = col
    }
    
    override func corr_moves(dx: Int, dy: Int, board: quant_board) -> Int
    {
        if board.board[x + dx][y + dy] == g_col
        {return 0}
        let kx = (dx == 0) ? 0 : Int(dx / abs(dx))
        let ky = (dy == 0) ? 0 : Int(dy / abs(dy))
        let d: Int = max(_: abs(dx), _ : abs(dy))
        if abs(dx) != abs(dy) || abs(dx) + abs(dy) == 0
        {return 0}
        if d > 1 //this language makes me suffer
        {
            for i in 1 ..< d
            {
                if board.board[x + i*kx][y + i*ky] != 0
                {return 0}
            }
        }
        return 1
    }
}


class pawn: figures
{
    convenience init(col: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_pawn")}
        else
        {self.init(imageNamed: "b_pawn")}
        g_col = col
    }
    
    override func corr_moves(dx: Int, dy: Int, board: quant_board) -> Int
    {
        if board.board[x + dx][y + dy] == g_col
        {return 0}
        //more crocodiles to the God of crocodiles!
        if dy == g_col && dx == 0 && board.board[x][y + g_col] == 0 || 1 == abs(dx) && dy == g_col && board.board[x + dx][y + dy] == -g_col || dy == 2*g_col && dx == 0 && y == ((g_col == 1) ? 1 : 6)
        {return 1}
        else
        {return 0}
    }
}

