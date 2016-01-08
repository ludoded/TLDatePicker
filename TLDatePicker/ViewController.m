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

- (IBAction)showPicker:(id)sender {
    TLDatePicker *p = [[TLDatePicker alloc] initWithinView:self.view];
    p.delegate = self;
    p.endDate = [NSDate date];
    [p setEndDate:[NSDate date]];
    [p show];
}

- (void)pickerDidSelectStartDate:(NSDate *)startDate {
    NSLog(@"start: %@", startDate);
}

- (void)pickerDidSelectEndDate:(NSDate *)endDate {
    NSLog(@"end: %@", endDate);
}

@end
