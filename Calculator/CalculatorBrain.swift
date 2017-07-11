//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Erik Arvedson on 2017-07-06.
//  Copyright © 2017 Mindglowing Design. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator : (value: Double?, description: String) = (nil, "")
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
        case clear
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "ℯ" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "tan" : Operation.unaryOperation(tan),
        "cosh" : Operation.unaryOperation(cosh),
        "sinh" : Operation.unaryOperation(sinh),
        "tanh" : Operation.unaryOperation(tanh),
        "x²" : Operation.unaryOperation {$0 * $0},
        "x⁻¹" : Operation.unaryOperation {1 / $0},
        "±" : Operation.unaryOperation {-$0},
        "×" : Operation.binaryOperation {$0 * $1},
        "÷" : Operation.binaryOperation {$0 / $1},
        "+" : Operation.binaryOperation {$0 + $1},
        "−" : Operation.binaryOperation {$0 - $1},
        "=" : Operation.equals,
        "C" : Operation.clear
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, symbol + " ")
            case .unaryOperation(let function):
                if accumulator.value != nil {
                    accumulator = (function(accumulator.value!), accumulator.description + symbol + " ")
                }
            case .binaryOperation(let function):
                if resultIsPending {
                    performPendingBinaryOperation()
                }
                if accumulator.value != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.value!)
                    accumulator = (nil, accumulator.description + symbol + " ")
                }
            case .equals:
                performPendingBinaryOperation()
            case .clear:
                accumulator = (0, "")
                pendingBinaryOperation = nil;
            }
        }
        print(accumulator.description)
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.value != nil {
            accumulator = (pendingBinaryOperation!.perform(with: accumulator.value!), accumulator.description)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    var resultIsPending : Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand : Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, accumulator.description + " \(operand) ")
    }
    
    var result: Double? {
        get {
            return accumulator.value
        }
    }
    
    var description: String? {
        get {
            return accumulator.description
        }
    }
    
}
