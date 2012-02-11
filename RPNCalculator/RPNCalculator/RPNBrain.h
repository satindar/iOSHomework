//
//  RPNBrain.h
//  RPNCalculator
//
//  Created by SATINDAR S DHILLON on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPNBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushVariable:(NSString *)variable;
- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues;
- (void)clearProgramStack;
- (void)clearLastOperand;

@property (readonly) id program; 

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end





