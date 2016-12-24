//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Danielle Zegelstein on 12/21/16.
//  Copyright © 2016 Danielle Zegelstein. All rights reserved.
//

import Foundation

class CalculatorBrain {
  
  private var accumulator = 0.0
  private var internalProgram = [AnyObject]()
  
  var description = ""
  
  var isPartialResult: Bool {
    return pending == nil
  }
  
  func setOperand(operand: Double) {
    accumulator = operand
    internalProgram.append(operand as AnyObject)
  }
  
  private var operations: Dictionary<String, Operation> = [
    "π": Operation.Constant(M_PI),
    "e": Operation.Constant(M_E),
    "±": Operation.UnaryOperation({ -$0 }),
    "√": Operation.UnaryOperation(sqrt),
    "cos": Operation.UnaryOperation(cos),
    "tan": Operation.UnaryOperation(tan),
    "sin": Operation.UnaryOperation(sin),
    "log": Operation.UnaryOperation(log),
    "×": Operation.BinaryOperation({ $0 * $1 }),
    "÷": Operation.BinaryOperation({ $0 / $1 }),
    "+": Operation.BinaryOperation({ $0 + $1 }),
    "−": Operation.BinaryOperation({ $0 - $1 }),
    "=": Operation.Equals,
    "c": Operation.Clear
  ]
  
  private enum Operation {
    case Constant(Double)
    case UnaryOperation((Double) -> Double)
    case BinaryOperation((Double, Double) -> Double)
    case Equals
    case Clear
  }
  func performOperation(symbol: String) {
    internalProgram.append(symbol as AnyObject)
    if let operation = operations[symbol] {
      switch operation {
      case .Constant(let value):
        accumulator = value
        if pending != nil {
          description += " " + formatAccumulator()
        } else {
          description = formatAccumulator()
        }
        
      case .UnaryOperation(let function):
        // Doesn't allow the square root of negative numbers
        if symbol == "√" && accumulator < 0 {
          return
        }
        accumulator = function(accumulator)
        if description.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
          description = " " + symbol + "(" + formatAccumulator() + ")"
        } else {
          description = " " + symbol + "(" + description + ")"
        }
      case .BinaryOperation(let function):
        executePendingBinaryOperation()
        pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
        if description.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
          description += formatAccumulator() + " " + symbol
        } else {
          description += " " + symbol
        }
        
      case .Equals:
        executePendingBinaryOperation()
      case .Clear:
        clear()
      }
    }
  }
  
  private func executePendingBinaryOperation() {
    if pending != nil {
      description += " " + formatAccumulator()
      accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
      pending = nil
    }
  }
  
  private var pending: PendingBinaryOperationInfo?
  
  private struct PendingBinaryOperationInfo {
    var binaryFunction: (Double, Double) -> Double
    var firstOperand: Double
  }
  
  typealias PropertyList = AnyObject
  var program: PropertyList {
    get {
      return internalProgram as CalculatorBrain.PropertyList
    }
    set {
      clear()
      if let arrayofOps = newValue as? [AnyObject] {
        for op in arrayofOps {
          if let operand = op as? Double {
            setOperand(operand: operand)
          } else if let operation = op as? String {
            performOperation(symbol: operation)
          }
        }
      }
    }
  }
  
  private func clear() {
    accumulator = 0.0
    pending = nil
    description = " "
  }
  
  private func formatAccumulator() -> String {
    return round(accumulator) == accumulator ? String(Int(accumulator)) : String(accumulator)
  }
  
  var result: Double {
    get {
      return accumulator
    }
  }
  
}
