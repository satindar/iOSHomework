//
//  GrapherBrain.m
//  Grapher
//
//  Created by SATINDAR S DHILLON on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GrapherBrain.h"

@interface GrapherBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation GrapherBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

- (void)clearLastOperand
{
    if (_programStack)  [self.programStack removeLastObject];
}


- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues
{
    if ([operation isEqualToString:@"+ / -"] && 
           [[self.programStack lastObject] isKindOfClass:[NSString class]] && 
           [[self.programStack lastObject] isEqualToString:@"+ / -"]) {
        [self.programStack removeLastObject];
    } else {
        [self.programStack addObject:operation];
    }
    return [GrapherBrain runProgram:self.program usingVariableValues:variableValues];
}

- (id)program
{
    return [self.programStack copy];
}


+ (double)popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor) result = [self popOperandOffStack:stack] / divisor;
        } else if ([operation isEqualToString:@"π"]) {
            result = [@"3.14" doubleValue];
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"√"]) {
            result = sqrt([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"log"]) {
            result = log([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"e"]) {
            result = 2.71828;
        } else if ([operation isEqualToString:@"+ / -"]) {
            result = -1 * [self popOperandOffStack:stack];
        }
    }
    return result;
}

+ (NSString *)removeExtraneousParentheses:(NSString *)description
{
    NSString *newDescription = description;
    if ([description hasPrefix:@"("] && [description hasSuffix:@")"]) {
        newDescription = [newDescription substringFromIndex:1];
        newDescription = [newDescription substringToIndex:[newDescription length] - 1];
    }  
    NSRange openBracket = [newDescription rangeOfString:@"("];
    NSRange closeBracket = [newDescription rangeOfString:@")"];
    
    if (openBracket.location <= closeBracket.location) return newDescription;
    else return description;
}


+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack 
{
    NSString *description = @"";
    NSSet *variablesUsed = [self variablesUsedInProgram:stack];
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        description = [topOfStack stringValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            NSString *adder = [self removeExtraneousParentheses:[self descriptionOfTopOfStack:stack]];
            description = [NSString stringWithFormat:@"(%@ + %@)", 
                           [self removeExtraneousParentheses:[self descriptionOfTopOfStack:stack]], adder];
        } else if ([operation isEqualToString:@"*"]) {
            NSString *multiplier= [self descriptionOfTopOfStack:stack];
            description = [NSString stringWithFormat:@"%@ * %@", 
                           [self descriptionOfTopOfStack:stack], 
                           multiplier];
        } else if ([operation isEqualToString:@"-"]) {
            NSString *subtrahend = [self removeExtraneousParentheses:[self descriptionOfTopOfStack:stack]];
            description = [NSString stringWithFormat:@"(%@ - %@)", 
                           [self removeExtraneousParentheses:[self descriptionOfTopOfStack:stack]], subtrahend];
        } else if ([operation isEqualToString:@"/"]) {
            NSString *divisor = [self descriptionOfTopOfStack:stack];
            description = [NSString stringWithFormat:@"%@ / %@", 
                           [self descriptionOfTopOfStack:stack], divisor];
        } else if ([operation isEqualToString:@"π"]) {
            description = @"π";
        } else if ([operation isEqualToString:@"sin"]) {
            description = [NSString stringWithFormat:@"sin(%@)", 
                           [self removeExtraneousParentheses:[self descriptionOfTopOfStack:stack]]];
        } else if ([operation isEqualToString:@"cos"]) {
            description = [NSString stringWithFormat:@"cos(%@)", 
                           [self removeExtraneousParentheses:[self descriptionOfTopOfStack:stack]]];
        } else if ([operation isEqualToString:@"√"]) {
            description = [NSString stringWithFormat:@"sqrt(%@)", 
                           [self removeExtraneousParentheses:[self descriptionOfTopOfStack:stack]]];
        } else if ([operation isEqualToString:@"log"]) {
            description = [NSString stringWithFormat:@"log(%@)", 
                           [self removeExtraneousParentheses:[self descriptionOfTopOfStack:stack]]];
        } else if ([operation isEqualToString:@"e"]) {
            description = @"2.71828";
        } else if ([operation isEqualToString:@"+ / -"]) {
            description = [NSString stringWithFormat:@"-%@", [self descriptionOfTopOfStack:stack]];
        } else if ([variablesUsed containsObject:operation]) {
            description = operation;
        } 
    }
    return description;
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
    if ([variablesUsed count] == 0) return nil;
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

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}


+ (NSString *)descriptionOfProgram:(id)program;
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    NSMutableArray *expressionArray = [NSMutableArray array];    
    while (stack.count > 0) {
        NSString *expression = [self removeExtraneousParentheses:[self descriptionOfTopOfStack:stack]];
        [expressionArray addObject:expression];
    }
    return [expressionArray componentsJoinedByString:@", "];
}

- (void)clearProgram
{
    self.programStack = nil;
}

   
@end


















