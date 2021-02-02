import Foundation

/**
 Represents the terrain on Mars surface.
 */
class Mars {
  
  enum MarsConfigurationError: Error {
    case invalidDimensions
  }
  
  var width: Int
  var height: Int
  var forbiddenPositions = [String]()
  
  init(width: Int, height:Int) throws {
    if (width < 0 || height < 0) {
      throw MarsConfigurationError.invalidDimensions
    }
    self.width = width
    self.height = height
  }
  
  func addForbidden(position: String) {
    self.forbiddenPositions.append(position)
  }
  
  func isForbidden(position: String) -> Bool {
    return forbiddenPositions.contains(position)
  }
}

/**
 Represents a position occupied by a Robot in Mars.
*/
class Position : Equatable {
  
  var x = 0
  var y = 0
  var orientation = "N"
  var isLost = false

  init(x: Int, y:Int) {
    self.x = x
    self.y = y
  }

  func isOutOfBounds(mars: Mars) -> Bool {
    if (self.x > mars.width || self.y > mars.height || self.y < 0 || self.x < 0) {
      if (self.orientation == "N") {
        self.y = mars.height
      }
      if (self.orientation == "E") {
        self.x = mars.width
      }
      if (self.orientation == "S") {
        self.y = 0
      }
      if (self.orientation == "W") {
        self.x = 0
      }
      self.isLost = true
      return self.isLost
    }
    return false
  }
  
  public var description: String {
      return "\(self.x) \(self.y) \(self.orientation) \(self.isLost ? "LOST" : "")"
  }
  
  static func == (lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.orientation == rhs.orientation
  }
  
}

/**
 Represents a Robot moving on Mars surface.
*/
class Robot {
  
  let leftRotations = ["N":"W", "W":"S", "S":"E", "E":"N"]
  let rightRotations = ["N":"E", "E":"S", "S":"W", "W":"N"]
  var position = Position(x: 0, y:0)
  let mars:Mars
  
  init(mars: Mars) {
    self.mars = mars
  }
  
  func setPosition (position: String) {
    let startPosition = position.components(separatedBy: " ")
    self.position = Position(x: Int(startPosition[0])!, y: Int(startPosition[1])!)
    self.position.orientation = startPosition[2]
  }

  func move(instructions: String) -> String {
    for simpleInstruction in instructions {
      if (self.isLost()) {
        break
      }
      
      if (self.canTurnLeft(instruction: simpleInstruction)) {
        self.turnLeft()
      }
      if (self.canTurnRight(instruction: simpleInstruction)) {
        self.turnRight()
      }
      if (self.canMoveForward(instruction: simpleInstruction)) {
        self.moveForward()
      }
    }
    return self.position.description
  }

  func moveForward() {
    let startingPosition = position.description
    if (self.isLost() || self.mars.isForbidden(position: startingPosition)) {
      return
    }
    
    if (self.position.orientation == "N") {
      self.position.y += 1
    }
    if (self.position.orientation == "E") {
      self.position.x += 1
    }
    if (self.position.orientation == "S") {
      self.position.y -= 1
    }
    if (self.position.orientation == "W") {
      self.position.x -= 1
    }
    
    if (self.position.isOutOfBounds(mars: self.mars)) {
      self.mars.addForbidden(position: startingPosition)
    }
  }

  func turnLeft() {
    self.position.orientation = leftRotations[position.orientation]!
  }

  func turnRight() {
    self.position.orientation = rightRotations[position.orientation]!
  }

  func canTurnLeft(instruction: Character) -> Bool {
    return instruction == "L"
  }

  func canTurnRight(instruction: Character) -> Bool {
    return instruction == "R"
  }
  
  func canMoveForward(instruction: Character) -> Bool {
    return instruction == "F"
  }
  
  func isLost() -> Bool {
    return self.position.isLost
  }
  
}

/**
 Main class that gives instructions to Robots to move around Mars.
*/
class MarsController {
  
  func readInstructions(instructions: String) -> String {
    var output = ""
    let instructionSet = instructions.components(separatedBy: "\n")

    let marsSize = instructionSet[0].components(separatedBy: " ")
    let mars = try! Mars(width: Int(marsSize[0])!, height: Int(marsSize[1])!)
    var robot = Robot(mars: mars)

    for var i in (1..<instructionSet.count) {
      let instruction = instructionSet[i]
      if (self.isNewRobot(instruction: instruction)) {
        robot = Robot(mars: mars)
      } else if (isInitialPosition(instruction: instruction)) {
        robot.setPosition(position: instruction)
      } else {
        output += (output.count > 0 ? "\n" : "") + robot.move(instructions: instruction)
      }
      i += 1
    }
    return output
  }

  func isNewRobot(instruction: String) -> Bool {
    return instruction == ""
  }

  func isInitialPosition(instruction: String) -> Bool {
    return instruction.contains(" ")
  }
}

/// Main logic to read input file and print results.
do {
  let instructions = try String(contentsOfFile: "input.txt")
  let marsController = MarsController()
  print(marsController.readInstructions(instructions: instructions))
} catch {
  print("Unexpected error: \(error).")
}
