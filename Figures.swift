//
//  GameScene.swift
//  QuantChess
//
//  Created by  Mike Check on 09.04.2018.
//  Copyright © 2018 Alonso Quixano. All rights reserved.
//

import SpriteKit


class stamp:SKSpriteNode
{
    convenience init(col: Int, parent: Board)
    {
        if col == 1
        {self.init(imageNamed: "w_win")}
        else
        {self.init(imageNamed: "b_win")}
        parent.addChild(self)
        self.position = CGPoint(x: 0, y: 0)
        self.size = CGSize(width: 0.3, height: 0.3)
        self.zPosition = 5
    }
}


class figures: SKSpriteNode
{
    required convenience init(col: Int, set_ID: Int)
    {
        if col == 1
        {self.init(imageNamed: "testfig")}
        else
        {self.init(imageNamed: "testfig")}
        g_col = col
        ID = set_ID
    }
    
    var g_col: Int = 0 //color. Don't remember what "g_" means
    func corr_moves(dx: Int, dy: Int, board: quant_board) -> Int {return 1} //function to check if you move figure correctly
    var touched = 0 //let understand if we heck or unchek figure
    let image_inc: CGFloat = 1.4
    var x: Int = 0 //position
    var y: Int = 0 //position
    var ID: Int = 0 //need for understanding when conflict appears
    
    
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
        let old_x = x
        let old_y = y
        let move_x = dx * parent.CellSize
        let move_y = dy * parent.CellSize
        var did_moved: Bool = false //Show if at least on one of boards the figure was moved
        var did_blocked: Bool = false //Show if at least on one of boards the figure was blocked
        var passed: [quant_board] = []
        var conflict: [quant_board] = []
        var has_conflict = false
        var king_eaten = false
        
        
        
        if !((x + Int(dx) >= 0) && (y + Int(dy) >= 0) && (x + Int(dx) < 8) && (y + Int(dy) < 8))
        {return false}
        if parent.showboard.figs[x + Int(dx)][y + Int(dy)] != nil && (parent.showboard.figs[x + Int(dx)][y + Int(dy)] as! figures).ID != self.ID
        {
            has_conflict = true
            if(parent.showboard.figs[x + Int(dx)][y + Int(dy)] as! figures).ID == -16 * g_col
            {
                king_eaten = true
            }
        }
        
        for board in parent.boards //on all board make move if possible
        {
            if board.board[x + Int(dx)][y + Int(dy)] != 0 && has_conflict
            {
                conflict.append(board)
            }
            if board.board[x][y] != 0
            {
                if corr_moves(dx: Int(dx), dy: Int(dy), board: board) == 1
                {
                    if let del_ind = conflict.index(where: {$0 === board})
                    {
                        conflict.remove(at: del_ind) //Hope it is working!
                    }
                    did_moved = true
                    onTap()
                    passed.append(board)
                    board.set(i: x,j: y,val: 0)
                    x += Int(dx)
                    y += Int(dy)
                    if king_eaten && board.board[x][y] == -g_col
                    {
                        board.has_king = false
                    }
                    board.set(i: x, j: y, val: self.g_col)
                }
                else
                {
                    did_blocked = true
                }
            }
        }
        
        if did_moved && did_blocked //correct move but only on some boards it's possiblle -- need to duplicate
        {
            let Type = type(of: self)
            let new_fig = Type.init(col: g_col, set_ID: ID) //create a figure of the same type and color
            new_fig.put(ParentNode: parent, position: [Int32(old_x), Int32(old_y)], boards: []) //[] -- because we do not need to change any board yet
        }
        if did_moved
        {
            if conflict.count != 0
            {
                let conflict_solution = (Int(arc4random_uniform(UInt32(passed.count + conflict.count) + 1)) > passed.count) //True -- you loose (opponents figure saved)
                if conflict_solution
                {
                    for board in passed
                    {
                        parent.boards = parent.boards.filter {$0 !== board}
                    }
                }
                else //You are lucky
                {
                    for board in conflict
                    {
                        parent.boards = parent.boards.filter {$0 !== board}
                    }
                    if king_eaten
                    {
                        EatKing(parent: parent)
                    }
                    self.run(SKAction.move(by: CGVector(dx: move_x,dy: move_y), duration: 0.1))
                    parent.showboard.set(i: x, j: y, val: self)
                }
            }
            else
            {
                self.run(SKAction.move(by: CGVector(dx: move_x,dy: move_y), duration: 0.1))
                if king_eaten
                {
                    EatKing(parent: parent)
                }
                parent.showboard.set(i: x, j: y, val: self)
            }
            if !did_blocked
            {
                parent.showboard.set(i: old_x, j: old_y, val: nil)
            }
            parent.showboard.update(boards: parent.boards, won: parent.w_won_boards+parent.b_won_boards)
            parent.showboard.draw(parent: parent)
        }
        return did_moved
    }
    
    
    func EatKing(parent: Board)
    {
        for board in parent.boards
        {
            if !board.has_king
            {
                let numb_of_won_boards = (parent.boards.filter {$0 === board}).count //hope this thing return 0 or 1 only
                parent.boards = parent.boards.filter {$0 !== board}
                if g_col == 1
                {
                    parent.w_won_boards += numb_of_won_boards
                }
                else
                {
                    parent.b_won_boards += numb_of_won_boards
                }
            }
        }
    }
    
    
    func put(ParentNode: Board, position: int2, boards: [quant_board]){
        ParentNode.addChild(self)
        x = Int(position[0])
        y = Int(position[1])
        var put_x = -ParentNode.size.width / 2 + ParentNode.boundSize + 0.5 * ParentNode.CellSize
        put_x += CGFloat(position[0]) * ParentNode.CellSize //Beautiful example why this language is a piece of.....is not very good
        var put_y = -ParentNode.size.width / 2 + ParentNode.boundSize + 0.5 * ParentNode.CellSize
        put_y += CGFloat(position[1]) * ParentNode.CellSize
        self.position = CGPoint(x: put_x, y: put_y)
        self.size = CGSize(width: ParentNode.CellSize, height: ParentNode.CellSize)
        self.zPosition = 2
        for board in boards
        {
            board.set(i: Int(position[0]), j: Int(position[1]), val: g_col) //Ставим фигуру на досках указнных в массивах
        }
        ParentNode.showboard.set(i: Int(position[0]), j: Int(position[1]), val: self)
    }
}


class horse: figures
{
    required convenience init(col: Int, set_ID: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_horse")}
        else
        {self.init(imageNamed: "b_horse")}
        g_col = col
        ID = set_ID
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
    required convenience init(col: Int, set_ID: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_king")}
        else
        {self.init(imageNamed: "b_king")}
        g_col = col
        ID = set_ID
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
    required convenience init(col: Int, set_ID: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_queen")}
        else
        {self.init(imageNamed: "b_queen")}
        g_col = col
        ID = set_ID
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
    required convenience init(col: Int, set_ID: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_rook")}
        else
        {self.init(imageNamed: "b_rook")}
        g_col = col
        ID = set_ID
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
    required convenience init(col: Int, set_ID: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_bishop")}
        else
        {self.init(imageNamed: "b_bishop")}
        g_col = col
        ID = set_ID
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
    required convenience init(col: Int, set_ID: Int)
    {
        if col == 1
        {self.init(imageNamed: "w_pawn")}
        else
        {self.init(imageNamed: "b_pawn")}
        g_col = col
        ID = set_ID
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

