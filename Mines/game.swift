//
//  game.swift
//  Mine Sweeper BL
//
//  Created by Usman Rashid on 9/20/18.
//  Copyright © 2018 Usman Rashid. All rights reserved.
//

import Foundation

class GameSquare {
    let row: Int
    let col: Int
    var value: Value
    var show: Bool

    // All possible values for a Game Square
    enum Value : Int {
        // Square has mine
        case Mine = -1

        // No mine in the square or its neighbors
        case Empty
        
        // No mine in the square but has mines in its neighbors
        case One, Two, Three, Four, Five, Six, Seven, Eight
        
        // Square has mine and was revealed
        case Done
    }
    
    // Bring to life, default value: Empty
    init (row: Int, col: Int, value: Value = .Empty)
    {
        self.row = row
        self.col = col
        self.value = value
        self.show = false
    }
    
    // Restore to initial state
    func reset() -> Void
    {
        self.value = .Empty
        self.show = false
    }

    // Calculate number of mines in an empty squares neighbors
    func setCount(with neighbors: [GameSquare]) -> Void
    {
        // No count if square has a mine
        if self.hasMine() {
            return
        }
        var count = 0
        for item in neighbors {
            if item.hasMine() {
                count += 1
            }
        }
        self.value = Value(rawValue: count)!
//        print (row, col, neighbors.count, count, self.value)
    }

    func setRevealed () -> Void
    {
        self.show = true
    }

    func isRevealed () -> Bool
    {
        return self.show
    }
    
    func isEmpty () -> Bool
    {
        return self.value == .Empty
    }

    func hasMine () -> Bool
    {
        return self.value == .Mine
    }

    func count () -> Int
    {
        return self.value.rawValue
    }
}


class Board
{
    let mines: Int
    let rows: Int
    let cols: Int
    var grid = [GameSquare]() // Array to hold GameSquares
    var squaresRemaining: Int = 0

    // Creates an empty board
    // Add Pre-condition: mine < (rows * cols)
    init (rows:Int, cols:Int, mines:Int)
    {
        self.mines = mines
        self.rows = rows
        self.cols = cols
        self.squaresRemaining = rows * cols

        // For each position initialize an empty GameSquare
        for row in 0..<rows {
            for col in 0..<cols {
                self.grid.append(GameSquare.init(row: row, col: col))
            }
        }
    }

    // Returns a GameSquare at a given location
    // Add Pre-condition: 0 <= row < rows
    // Add Pre-condition: 0 <= col < cols
    subscript (row: Int, col: Int) -> GameSquare
    {
        get {
            return grid[row * cols + col]
        }
    
        set {
            grid[row * cols + col] = newValue
        }
    }

    // Find all valid neighbors for a give square
    func neighbors (for square: GameSquare) -> [GameSquare]
    {
        // Start with empty neighbor list
        var result = [GameSquare]()
        
        // Check for valid locations by looking at
        // +/- 1 row and +/- 1 column
        for row in square.row-1...square.row+1 {
            for col in square.col-1...square.col+1 {
                // Check array bounds
                if (row >= 0 && row < rows) &&
                   (col >= 0 && col < cols) {
                    // Skip the square itself
                    if (row == square.row && col == square.col) {
                        continue
                    }
                    // If the location is valid and it isn't the square itself
                    // add it to neigbor list
                    result.append(self[row,col])
                }
            }
        }
        return result
    }

    // Set up a new board
    func reset()
    {
        // Reset all squares
        for square in grid {
            square.reset()
        }
        
        // Reset count of square to show
        squaresRemaining = rows * cols

        // Place mines at random locations
        var count = 1
        while count <= mines {
            let row = Int(arc4random()) % rows
            let col = Int(arc4random()) % cols

            // Only place a mine if the random location is empty
            if (self[row, col].isEmpty()) {
                self[row, col].value = .Mine
                count += 1
            }
        }

        // Set neighbor counts for empty square
        for square in grid {
            if (square.isEmpty()) {
                square.setCount(with:neighbors(for: square))
            }
        }
    }

    // Reveal the square at [row, col]
    func show (row: Int, col: Int)
    {
        let location = self[row, col]

        // Nothing to do if the Square is already revealed
        if location.isRevealed() {
            return
        }

        // Update the count of remaining squares
        location.setRevealed()
        squaresRemaining -= 1
        
        // If the square is empty, show its neighbors too
        if location.isEmpty() {
            for square in neighbors(for: location) {
                show(row: square.row, col: square.col) // Ignore return value
            }
        }
    }
    
    // Show all squares that have mines
    func showMines() -> Void {
        for square in grid {
            if square.hasMine() {
                square.setRevealed()
            }
        }
    }

    // Show entire board
    func showAll() -> Void {
        for square in grid {
            square.setRevealed()
        }
    }

    // Debug printout
    func printBoard()
    {
        let symbols = "M012345678#"
        for row in 0..<rows {
            for col in 0..<cols {
                let square = self[row,col]
                var char : Character = symbols.last!
                if square.isRevealed() {
                    char = symbols[symbols.index(symbols.startIndex, offsetBy: square.count()+1)]
                }
                print ("\(char)", terminator:"  ")
            }
            print ("\n")
        }
        print ("\n")
    }
}
