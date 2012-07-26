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

- (NSMutableArray *)programStack 
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

- (void)clearLastOperand
{
    if (_programStack) [self.programStack removeLastObject];
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

- (void)pushVariable:(NSString *)variable
{
    [self.programStack addObject:variable];
}


- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues
{
    [self.programStack addObject:operation];
    return [RPNBrain runProgram:self.program usingVariableValues:variableValues];
}

- (id)program
{
    return [self.programStack copy]; // returns immutable array, protects internal data
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
    NSSet *twoOperandOperations = [[NSSet alloc] initWithObjects:@"+", @"-", @"*", @"/", nil];
    return [twoOperandOperations containsObject:operation] ? YES : NO;
}

+ (BOOL)isOneOperandOperation:(NSString *)operation
{
    NSSet *oneOperandOperations = [[NSSet alloc] initWithObjects:@"sin", @"cos", @"sqrt", nil];
    return [oneOperandOperations containsObject:operation] ? YES : NO;
}

+ (BOOL)isZeroOperandOperation:(NSString *)operation
{
    return [operation isEqualToString:@"pi"] ? YES : NO;
}

+ (BOOL)isVariable:(NSString *)operation
{
    NSSet *variables = [[NSSet alloc] initWithObjects:@"x", @"a", @"b",nil];
    return [variables containsObject:operation] ? YES : NO;
}

+ (NSString *)removeExtraneousParenthesesAndCommas:(NSString *)description
{
    NSString *processedString = description;
    if ([processedString hasPrefix:@"("] && [processedString hasSuffix:@")"]) {
        processedString = [processedString substringToIndex:([processedString length] - 1)];
        processedString = [processedString substringFromIndex:1];
    }
    // write implementation to remove redundant inner parentheses
    // write implementation to remove extra commas 
    return processedString;
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack 
{
    NSString *description = [NSString stringWithString:@""]; 
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        description = [NSString stringWithFormat:@"%g", [topOfStack doubleValue]];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([self isTwoOperandOperation:operation]) {
            NSString *rightOperand = [self descriptionOfTopOfStack:stack];
            NSString *leftOperand = [self descriptionOfTopOfStack:stack];
            description = [NSString stringWithFormat:@"(%@ %@ %@)", leftOperand, operation, rightOperand];
        } else if ([self isOneOperandOperation:operation]) {
            description = [NSString stringWithFormat:@"%@(%@)", operation, [self descriptionOfTopOfStack:stack]];
        } else if ([self isZeroOperandOperation:operation]) {
            description = [NSString stringWithFormat:@"%@", operation];
        } else if ([self isVariable:operation]) {
            description = [NSString stringWithFormat:@"%@", operation];
        }
    }
    if ([stack count]) {
    // not working fully
    //    description =[NSString stringWithFormat:@"%@, %@", [self descriptionOfTopOfStack:stack], description];
    }
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy]; // returns an object (id)
        
    }
    return [self removeExtraneousParenthesesAndCommas:[self descriptionOfTopOfStack:stack]];
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
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
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
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    if ([program isKindOfClass:[NSArray class]])  {
        stack = [program mutableCopy];
    }
    NSMutableSet *variablesUsed = [[NSMutableSet alloc] init];
    for (id obj in stack) {
        if ([obj isKindOfClass:[NSString class]]) {
            if ([@"x" isEqualToString:obj] || [@"a" isEqualToString:obj] || [@"b" isEqualToString:obj]) {
                [variablesUsed addObject:(NSString *)obj];
            }
        }
    }
    return (NSSet *)variablesUsed;
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        for (int i = 0; i < [stack count]; i++) {
            id object = [variableValues objectForKey:[stack objectAtIndex:i]];
            if (object) {
                [stack replaceObjectAtIndex:i withObject:object];
            }
        }
    }
    return [self popOperandOffStack:stack];
}



@end
























