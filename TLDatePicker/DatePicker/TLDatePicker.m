//
//  TLDatePicker.m
//  TLDatePicker
//
//  Created by Aik Ampardjian on 07.01.16.
//  Copyright © 2016 Ayk. All rights reserved.
//

#import "TLDatePicker.h"
#import <FSCalendar/FSCalendar.h>

@interface TLDatePicker () <FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UIView *superView;
@property (strong, nonatomic) FSCalendar *calendar;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) TLDatePickerTime *time;

@end

@implementation TLDatePicker

- (instancetype)initWithinView:(UIView *)view {
    self = [super init];
    if (self) {
        self.superView = view;
        [self customizePicker];
    }
    return self;
}

- (void)customizePicker {
    self.alpha = 0.0;
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.superView addSubview:self];
    
    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    
    // Adding constraints
    CGFloat aspectRatio = [self aspectRatioOfSize];
    
    // Width constraint, aspectRatio of parent view width
    [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:aspectRatio
                                                                constant:0]];
    
    // Height constraint, aspectRatio of parent view height
    [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superView
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:aspectRatio
                                                                constant:0]];
    
    // Center horizontally
    [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    // Center vertically
    [self.superView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self layoutIfNeeded];
    
    // Init startTime and endTime
    self.time = [[TLDatePickerTime alloc] init];
    
    // Adding Calendar View
    CGSize selfSize = self.bounds.size;
    CGFloat quarterWidth = selfSize.width / 4;
    CGFloat ninthHeight = selfSize.height / 9;
    UIFont *font = [UIFont systemFontOfSize:10];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:10];
    
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, ninthHeight, self.frame.size.width, self.frame.size.height / 3)];
    self.calendar.delegate = self;
    self.calendar.dataSource = self;
    self.calendar.allowsMultipleSelection = NO;
    self.calendar.appearance.todayColor = [UIColor clearColor];
    self.calendar.appearance.titleTodayColor = [UIColor blackColor];
    
    [self addSubview:self.calendar];
    
    // Adding informative labels
    UILabel *dateInfo = [[UILabel alloc] initWithFrame:CGRectMake(ninthHeight, 0, quarterWidth / 2, ninthHeight)];
    dateInfo.textAlignment = NSTextAlignmentLeft;
    dateInfo.text = @"Date";
    dateInfo.font = boldFont;
    dateInfo.minimumScaleFactor = 0.5;
    [self addSubview:dateInfo];
    
    UILabel *hourInfo = [[UILabel alloc] initWithFrame:CGRectMake(ninthHeight, ninthHeight * 4, quarterWidth / 2, ninthHeight)];
    hourInfo.textAlignment = NSTextAlignmentCenter;
    hourInfo.text = @"Hour";
    hourInfo.font = boldFont;
    hourInfo.minimumScaleFactor = 0.5;
    [self addSubview:hourInfo];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(quarterWidth / 2 + ninthHeight, 0, selfSize.width - quarterWidth - 2 * ninthHeight, ninthHeight)];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.textColor = [UIColor darkGrayColor];
    self.dateLabel.font = font;
    self.dateLabel.minimumScaleFactor = 0.5;
    [self addSubview:self.dateLabel];
    
    [self updateDateLabel];
    
    // Adding action buttons
    UIImageView *backImg = [[UIImageView alloc] initWithFrame:CGRectMake(ninthHeight / 4, ninthHeight / 4, ninthHeight / 2, ninthHeight / 2)];
    backImg.image = [UIImage imageNamed:@"Back"];
    backImg.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:backImg];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ninthHeight, ninthHeight)];
    [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - ninthHeight, ninthHeight * 8, ninthHeight, ninthHeight)];
    [self.doneButton setImage:[UIImage imageNamed:@"Checkmark"] forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.doneButton];
    
    // Adding Picker View
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ninthHeight * 5, self.frame.size.width, self.frame.size.height / 3)];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self setCurrentHoursAndMinutesForDateType];
    
    [self addSubview:self.pickerView];
}

/** 
 Method to update info labels
 **/
- (void)updateDateLabel {
    [self setDate:self.date andTime:self.time forLabel:self.dateLabel];
}

/** 
 Method to adjust the label for start or end dates
 **/
- (void)setDate:(NSDate *)date andTime:(TLDatePickerTime *)time forLabel:(UILabel *)label {
    if (date == nil) {
        label.text = @"No date";
    }
    else {
        NSString *labelText = [[self.calendar stringFromDate:date format:@"yyyy/MM/dd"] stringByAppendingString:[NSString stringWithFormat:@" %02d:%02d", time.hours, time.minutes]];
        label.text = labelText;
    }
}

/**
 Method to change the hours and minutes in the selected date
 **/
- (void)setHours:(int)hours andMinutes:(int)minutes {
    if (self.date)
        [self setHours:hours andMinutes:minutes forTime:self.time];
    
    [self updateDateLabel];
}

- (void)setCurrentHoursAndMinutesForDateType {
    unsigned unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.locale = self.calendar.locale;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:[NSDate date]];
    int hours = (int)comps.hour;
    int minutes = (int)comps.minute;
    
    [self setHours:hours andMinutes:minutes];
    
    // Set current hours in the picker
    [self.pickerView selectRow:hours inComponent:0 animated:YES];
    [self.pickerView selectRow:minutes inComponent:1 animated:YES];
}

- (void)setHours:(int)hours andMinutes:(int)minutes forTime:(TLDatePickerTime *)time {
    time.hours = hours;
    time.minutes = minutes;
}

- (NSDate *)addTime:(TLDatePickerTime *)time toDate:(NSDate *)date {
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.locale = self.calendar.locale;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    comps.hour = time.hours;
    comps.minute = time.minutes;
    
    return [calendar dateFromComponents:comps];
}

/**
 Method is called when cancel button is pressed
 It removes the view from its superview
 **/
- (void)cancel {
    [self dismiss];
}

/**
 Method is called when done button is pressed
 It send dates to delegate method and removes itself
 **/
- (void)done {
    NSDate *date = (self.date) ? [self addTime:self.time toDate:self.date] : nil;
    
    switch (self.mode) {
        case TLDatePickerModeStartDate:
        if ([self.delegate respondsToSelector:@selector(pickerDidSelectStartDate:)])
            [self.delegate performSelector:@selector(pickerDidSelectStartDate:) withObject:date];
        break;
    
        default:
        if ([self.delegate respondsToSelector:@selector(pickerDidSelectEndDate:)])
            [self.delegate performSelector:@selector(pickerDidSelectEndDate:) withObject:date];
        break;
    }
    
    [self dismiss];
}

- (void)dismiss {
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

/**
 Check if the current device is iPhone 4 or 4S
 If it is, then the area of picker should be the 3.5/4 of the screen
 otherwise should be the 3/4
 **/
- (CGFloat)aspectRatioOfSize {
    CGFloat height = [UIScreen mainScreen].nativeBounds.size.height;
    CGFloat numerator = (height <= 960) ? 3.5 : 3.0;
    return numerator / 4;
}

- (void)updateConstraints {
    [super updateConstraints];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)show {
    // Select dates if any
    if (self.date != nil) [self.calendar selectDate:self.date];
    [self updateDateLabel];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)setDate:(NSDate *)date {
    if (date != nil) {
        NSDate *zeroDate = [self addTime:[self zeroTime] toDate:date];
        _date = zeroDate;
        [self setCurrentHoursAndMinutesForDateType];
        [self updateDateLabel];
    }
    else
        _date = date;
}

- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate;
    [self.calendar reloadData];
}

- (TLDatePickerTime *)zeroTime {
    TLDatePickerTime *res = [[TLDatePickerTime alloc] init];
    res.hours = 0;
    res.minutes = 0;
    
    return res;
}

// MARK: FSCalendar Delegate, DataSource & AppearanceDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    self.date = date;
    [self setCurrentHoursAndMinutesForDateType];
    
    // Update labels
    [self updateDateLabel];
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date {
    if ([date compare:self.date] == NSOrderedSame)
        self.date = nil;
    
    [self updateDateLabel];
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return (self.startDate) ? self.startDate : [self.calendar dateWithYear:1970 month:1 day:1];;
}

// MARK: UIPickerView Delegate & DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return  (component == 0) ? 24 : 60;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%02d", (int)row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    int hours = (int)[pickerView selectedRowInComponent:0];
    int minutes = (int)[pickerView selectedRowInComponent:1];
    [self setHours:hours andMinutes:minutes];
}

@end


// MARK: Implementation of TLDatePickerTime
@implementation TLDatePickerTime

@end