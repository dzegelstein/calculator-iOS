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
  
  var userTyped = false
  
  var description = " "
  
  var isPartialResult: Bool {
    return pending == nil
  }
  
  func setOperand(operand: Double) {
    accumulator = operand
    internalProgram.append(operand as AnyObject)
  }
  
  func setOperand(operand: String) {
    if let value = variableValues[operand] {
      accumulator = value
      internalProgram.append(operand as AnyObject)
    } else {
      accumulator = 0.0
    }
  }
  
  var variableValues: Dictionary<String, Double> = [:]
  
  private var operations: Dictionary<String, Operation> = [
    "π": Operation.Constant(Double.pi),
    "e": Operation.Constant(M_E),
    "±": Operation.UnaryOperation({ -$0 }),
    "1/x": Operation.UnaryOperation({ 1/$0 }),
    "%": Operation.UnaryOperation({ $0 / 100 }),
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
    "c": Operation.Clear,
    "→M": Operation.SetVariable,
    "M": Operation.UseVariable,
    "→X": Operation.SetVariable,
    "X": Operation.UseVariable
  ]
  
  private enum Operation {
    case Constant(Double)
    case UnaryOperation((Double) -> Double)
    case BinaryOperation((Double, Double) -> Double)
    case Equals
    case Clear
    case SetVariable
    case UseVariable
  }
  
  func performOperation(symbol: String) {
    internalProgram.append(symbol as AnyObject)
    if let operation = operations[symbol] {
      switch operation {
        
      case .Constant(let value):
        accumulator = value
        if !userTyped && pending != nil {
          executePendingBinaryOperation(" \(symbol)")
        } else {
          description += " \(symbol)"
        }
        
      case .UnaryOperation(let function):
        executePendingBinaryOperation(formatAccumulator())
        // Doesn't allow the square root of negative numbers
        if symbol == "√" && accumulator < 0 {
          return
        }
        accumulator = function(accumulator)
        if description.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
          description = " \(symbol) (\(formatAccumulator()))"
        } else {
          description = " \(symbol)(\(description))"
        }
        userTyped = false
        
      case .BinaryOperation(let function):
        
        if pending == nil && userTyped {
          description = "\(formatAccumulator()) \(symbol)"
        } else {
          executePendingBinaryOperation(" \(formatAccumulator())")
          if (description.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "") {
            description = "\(formatAccumulator()) \(symbol)"
          } else {
            description += " \(symbol)"
          }
        }
        pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
        
      case .Equals:
        if userTyped && pending == nil {
          description = formatAccumulator()
        } else if userTyped {
          executePendingBinaryOperation(" \(formatAccumulator())")
        } else {
          executePendingBinaryOperation("")
        }
        
      case .Clear:
        clear()
        
      case .SetVariable:
        var variable: String = symbol
        variable.removeFirst()
        variableValues[variable] = accumulator
        
      case .UseVariable:
        setOperand(operand: symbol)
        if pending != nil {
          executePendingBinaryOperation(" \(symbol)")
        } else {
          description = symbol
        }
      }
    }
  }
  
  private func executePendingBinaryOperation(_ newDescription: String) {
    if pending != nil {
      description += newDescription
      accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
      pending = nil
      userTyped = false
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
    variableValues = [:]
  }
  
  private func formatAccumulator() -> String {
    return round(accumulator) == accumulator ? String(Int(accumulator)) : String(accumulator)
  }
  
  var result: Double {
    get {
      return accumulator
    }
    
    set {
      accumulator = newValue
    }
  }
}
