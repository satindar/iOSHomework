//
//  GrapherViewController.m
//  Grapher
//
//  Created by SATINDAR S DHILLON on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GrapherViewController.h"
#import "GrapherBrain.h"
#import "GraphViewController.h"

@interface GrapherViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) GrapherBrain *brain;
@property (nonatomic, strong) NSMutableDictionary *variableValues;
@end

@implementation GrapherViewController

@synthesize display = _display;
@synthesize programDisplay = _programDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize variableValues = _variableValues;

- (GrapherBrain *)brain
{
    if (!_brain) _brain = [[GrapherBrain alloc] init];
    return _brain;
}

- (GraphViewController *)splitViewGraphViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}


- (NSMutableDictionary *)variableValues {
    if (!_variableValues) {
        _variableValues = [[NSMutableDictionary alloc] init];
    }
    return _variableValues;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Graph"]) {
        [segue.destinationViewController setProgram:self.brain.program];
    }
}
- (IBAction)graphProgram 
{
    if ([self splitViewGraphViewController]) {
        [self.splitViewGraphViewController setProgram:self.brain.program];
    }
}

- (IBAction)backspacePressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text substringToIndex:
                             [self.display.text length] - 1];
        if ([self.display.text length] < 1) {
            double oldAnswer = [[self.brain class] runProgram:self.brain.program 
                                          usingVariableValues:[self.variableValues mutableCopy]];
            self.display.text = [NSString stringWithFormat:@"%g", oldAnswer];
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    } else {
        [self.brain clearLastOperand];
        double priorOperationAnswer = [[self.brain class] runProgram:self.brain.program 
                                                 usingVariableValues:[self.variableValues mutableCopy]];
        self.display.text = [NSString stringWithFormat:@"%g", priorOperationAnswer];
    }
    self.programDisplay.text = [[self.brain class] descriptionOfProgram:self.brain.program];
    if ([self splitViewGraphViewController]) {
        [self.splitViewGraphViewController setProgram:self.brain.program];
    }
}

- (IBAction)clearPressed:(UIButton *)sender 
{
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearProgram];
    self.display.text = @"0";
    self.programDisplay.text = @"";
}

- (IBAction)decimalPressed:(UIButton *)sender 
{
    NSRange range = [self.display.text rangeOfString:[sender currentTitle]];
    if (range.location == NSNotFound) {
        self.display.text = [self.display.text stringByAppendingString:[sender currentTitle]];
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.programDisplay.text = [[self.brain class] descriptionOfProgram:self.brain.program];
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation= [sender currentTitle];
    double result = [self.brain performOperation:operation 
                             usingVariableValues:[self.variableValues mutableCopy]];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.programDisplay.text = [[self.brain class] descriptionOfProgram:self.brain.program];
}

- (IBAction)signFlipPressed:(UIButton *)sender 
{
    NSRange range = [self.display.text rangeOfString:@"-"];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if (range.location == NSNotFound) {
            self.display.text = [@"-" stringByAppendingString:self.display.text];
        } else {
            self.display.text = [self.display.text substringFromIndex:1];
        }
    } else {
        [self operationPressed:sender];
    }
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit]; 
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (self.splitViewController) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (void)viewDidUnload {
    [self setProgramDisplay:nil];
    [super viewDidUnload];
}

@end
