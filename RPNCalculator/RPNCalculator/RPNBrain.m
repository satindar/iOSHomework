//
//  RPNBrain.m
//  RPNCalculator
//
//  Created by SATINDAR S DHILLON on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPNBrain.h"

@interface RPNBrain() 
@property (nonatomic, strong) NSMutableArray *programStack ;
@end

@implementation RPNBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack // aded only as an exercise
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void)clearProgramStack
{
    if (self.programStack) [self.programStack removeAllObjects];
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}


- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [RPNBrain runProgram:self.program];
}

- (id)program
{
    return [self.programStack copy]; // returns immutable array, protects internal data
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement this in assignment 2";
    // use recursion to to implement this
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([@"-" isEqualToString:operation]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        } else if ([@"/" isEqualToString:operation]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor) result = [self popOperandOffStack:stack] / divisor;
        } else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffStack:stack]);
        } else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffStack:stack]);
        } else if ([@"pi" isEqualToString:operation]) {
            result = 3.14;
        } else if ([@"sqrt" isEqualToString:operation]) {
            result = sqrt([self popOperandOffStack:stack]);
        }
    }
    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy]; // returns an object (id)
    }
    return [self popOperandOffStack:stack];   
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    // Implement class method here
    // Initialize set
    // enumerate through program
    // add variables to NSSet (containing NSString objects)
    // return nil if there are no variables used
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    // Implement class method here
    // convert variable values to operations (use zero if variable has no value assigned)
    // call runProgram
    // return result
}
@end
























