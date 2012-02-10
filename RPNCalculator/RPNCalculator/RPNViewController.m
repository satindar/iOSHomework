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
@property (nonatomic) BOOL userHasEnteredDecimalPoint;

@end


@implementation RPNViewController

@synthesize display = _display;
@synthesize inputDisplay = _inputDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize userHasEnteredDecimalPoint = _userHasEnteredDecimalPoint;

- (RPNBrain *)brain
{
    if (!_brain) _brain = [[RPNBrain alloc] init];
    return _brain;
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

- (IBAction)decimalPointPressed:(UIButton *)sender 
{
    NSString *decimal = @".";
    if (!self.userHasEnteredDecimalPoint) {
        self.userHasEnteredDecimalPoint = YES;
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
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.inputDisplay.text = [self.inputDisplay.text stringByAppendingString:self.display.text];
    self.inputDisplay.text = [self.inputDisplay.text stringByAppendingString:@" "];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userHasEnteredDecimalPoint = NO;
}


- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    self.inputDisplay.text = [self.inputDisplay.text stringByAppendingString:operation];
    self.inputDisplay.text = [self.inputDisplay.text stringByAppendingString:@" "];
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)clearPressed:(UIButton *)sender 
{
    [self.brain clearProgramStack];
    self.userHasEnteredDecimalPoint = NO;
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.display.text = @"0";
    self.inputDisplay.text = @"";
}

- (void)viewDidUnload {
    [self setInputDisplay:nil];
    [super viewDidUnload];
}
@end
