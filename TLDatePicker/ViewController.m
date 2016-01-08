//
//  ViewController.m
//  TLDatePicker
//
//  Created by Aik Ampardjian on 07.01.16.
//  Copyright © 2016 Ayk. All rights reserved.
//

#import "ViewController.h"
#import "TLDatePicker.h"

@interface ViewController () <TLDatePickerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showStartPicker:(id)sender {
    TLDatePicker *p = [[TLDatePicker alloc] initWithinView:self.view];
    p.delegate = self;
    [p show];
}

- (void)pickerDidSelectStartDate:(NSDate *)startDate {
    self.startLabel.text = [NSString stringWithFormat:@"start: %@", startDate];
    NSLog(@"start: %@", startDate);
}

- (void)pickerDidSelectEndDate:(NSDate *)endDate {
    self.endLabel.text = [NSString stringWithFormat:@"start: %@", endDate];
    NSLog(@"end: %@", endDate);
}

- (IBAction)showEndPicker:(id)sender {
    TLDatePicker *p = [[TLDatePicker alloc] initWithinView:self.view];
    p.delegate = self;
    [p setStartDate:[NSDate date]];
    p.mode = TLDatePickerModeEndDate;
    [p show];
}
@end
