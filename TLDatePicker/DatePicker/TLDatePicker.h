//
//  TLDatePicker.h
//  TLDatePicker
//
//  Created by Aik Ampardjian on 07.01.16.
//  Copyright © 2016 Ayk. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TLCurrentDate) {
    TLCurrentDateStart,
    TLCurrentDateEnd
};

typedef NS_ENUM(NSInteger, TLDatePickerMode) {
    TLDatePickerModeStandard,
    TLDatePickerModeEndDate
};

@protocol TLDatePickerDelegate <NSObject>

@optional
- (void)pickerDidSelectStartDate:(NSDate *)startDate;
- (void)pickerDidSelectEndDate:(NSDate *)endDate;

@end

@interface TLDatePicker : UIView

@property (strong, nonatomic) id<TLDatePickerDelegate> delegate;
@property (nonatomic) TLDatePickerMode mode;

- (instancetype)initWithinView:(UIView *)view;

- (void)setStartDate:(NSDate *)date;
- (void)setEndDate:(NSDate *)date;

- (void)show;

@end

@interface TLDatePickerTime : NSObject

@property (nonatomic) int hours;
@property (nonatomic) int minutes;

@end