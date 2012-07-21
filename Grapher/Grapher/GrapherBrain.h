//
//  GrapherBrain.h
//  Grapher
//
//  Created by SATINDAR S DHILLON on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrapherBrain : NSObject

@property (readonly) id program; // program is always guaranteed to be a Property List

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation usingVariableValues:(NSDictionary *)variableValues;
- (void)clearProgram;
- (void)clearLastOperand;

+ (double)runProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end
