//
//  ViewController.h
//  TLDatePicker
//
//  Created by Aik Ampardjian on 07.01.16.
//  Copyright © 2016 Ayk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;

- (IBAction)showStartPicker:(id)sender;
- (IBAction)showEndPicker:(id)sender;

@end

