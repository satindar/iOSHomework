//
//  RPNViewController.m
//  RPNCalculator
//
//  Created by SATINDAR S DHILLON on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RPNViewController.h"
#import "RPNBrain.h"

@interface RPNViewController()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) RPNBrain *brain;
@property (nonatomic, strong) NSMutableDictionary *variableTestValues;

@end


@implementation RPNViewController

@synthesize display = _display;
@synthesize inputDisplay = _inputDisplay;
@synthesize variablesUsedDisplay = _variablesUsedDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize variableTestValues = _variableTestValues;

- (RPNBrain *)brain
{
    if (!_brain) _brain = [[RPNBrain alloc] init];
    return _brain;
}

- (NSMutableDictionary *)variableTestValues
{
    if (!_variableTestValues) _variableTestValues = [[NSMutableDictionary alloc] init];
    return _variableTestValues;
}

- (void)updateDisplays
{
    self.variablesUsedDisplay.text = @"";
    self.inputDisplay.text = [RPNBrain descriptionOfProgram:self.brain.program];
    NSSet *variablesUsed = [RPNBrain variablesUsedInProgram:self.brain.program];
    for (id obj in variablesUsed) {
        self.variablesUsedDisplay.text = [self.variablesUsedDisplay.text stringByAppendingString:[NSString stringWithFormat:@"%@ = %@   ", obj, [self.variableTestValues objectForKey:obj]]];
    }
}

- (IBAction)testVariableButtonPressed:(UIButton *)sender 
{
    if ([[sender currentTitle] isEqualToString:@"Test 1"]) {
        self.variableTestValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0], @"x", [NSNumber numberWithDouble:0], @"a", [NSNumber numberWithDouble:0], @"b", nil];
    } else if ([[sender currentTitle] isEqualToString:@"Test 2"]) {
        self.variableTestValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:1.2], @"x",[NSNumber numberWithDouble:-10], @"a", [NSNumber numberWithDouble:-1], @"b", nil];
    } else if ([[sender currentTitle] isEqualToString:@"Test 3"]) {
        self.variableTestValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:2], @"x", [NSNumber numberWithDouble:5], @"a", [NSNumber numberWithDouble:10], @"b", nil];
    }
    [self updateDisplays];
    // NSLog(@"dictionary values %@", self.variableTestValues);
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
    // NSLog(@"user touched %@", digit);
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}


- (IBAction)decimalPointPressed:(UIButton *)sender // change implementation to remove bool property
{
    NSString *decimal = @".";
    NSRange range = [self.display.text rangeOfString:decimal];
    if (range.location == NSNotFound) {
        if (self.userIsInTheMiddleOfEnteringANumber) {
            self.display.text = [self.display.text stringByAppendingString:decimal];
        } else {
            self.display.text = [NSString stringWithFormat:@"0%@", decimal];
            self.userIsInTheMiddleOfEnteringANumber = YES;
        } 
    }
}

- (IBAction)enterPressed 
{
    if (!([self.display.text isEqualToString:@"x"] || [self.display.text isEqualToString:@"a"] || [self.display.text isEqualToString:@"b"])) {
        [self.brain pushOperand:[self.display.text doubleValue]];
    }
    [self updateDisplays];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)variablePressed:(id)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *variable = [sender currentTitle];
    [self.brain pushVariable:variable];
    self.display.text = variable;
    [self updateDisplays];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}


- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    double result = [self.brain performOperation:operation usingVariableValues:self.variableTestValues];
    [self updateDisplays];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)clearPressed:(UIButton *)sender 
{
    [self.brain clearProgramStack];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.display.text = @"0";
    self.inputDisplay.text = @"";
    self.variablesUsedDisplay.text = @"";
}

- (IBAction)undoPressed:(id)sender // needs work
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
        if (([self.display.text length] < 1) || [self.display.text isEqualToString:@"0"]) {
            self.userIsInTheMiddleOfEnteringANumber = NO;
            double priorResult = [RPNBrain runProgram:self.brain.program usingVariableValues:self.variableTestValues];
            self.display.text = [NSString stringWithFormat:@"%g", priorResult];
            [self updateDisplays];
        }
    } else if ([self.brain.program count] > 0) {
        [self.brain clearLastOperand];
        double priorOperationAnswer = [RPNBrain runProgram:self.brain.program usingVariableValues:self.variableTestValues];
        self.display.text = [NSString stringWithFormat:@"%g", priorOperationAnswer];
        [self updateDisplays];
    } else {
        self.display.text = @"0";
        [self updateDisplays];
    }
}



- (void)viewDidUnload {
    [self setInputDisplay:nil];
    [self setVariablesUsedDisplay:nil];
    [super viewDidUnload];
}

@end











