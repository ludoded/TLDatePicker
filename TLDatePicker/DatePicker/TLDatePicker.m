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

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) UIView *superView;
@property (strong, nonatomic) FSCalendar *calendar;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UILabel *startDateLabel;
@property (strong, nonatomic) UILabel *endDateLabel;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *redoButton;
@property (strong, nonatomic) TLDatePickerTime *startTime;
@property (strong, nonatomic) TLDatePickerTime *endTime;

@property (strong, nonatomic) NSDate *currentDate;
@property (nonatomic) TLCurrentDate currentDateType;

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
    self.startTime = [[TLDatePickerTime alloc] init];
    self.endTime = [[TLDatePickerTime alloc] init];
    
    // Adding Calendar View
    CGSize selfSize = self.bounds.size;
    CGFloat quarterWidth = selfSize.width / 4;
    CGFloat ninthHeight = selfSize.height / 9;
    UIFont *font = [UIFont systemFontOfSize:10];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:10];
    
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, ninthHeight, self.frame.size.width, self.frame.size.height * 1 / 3)];
    self.calendar.delegate = self;
    self.calendar.dataSource = self;
    self.calendar.allowsMultipleSelection = YES;
    self.calendar.appearance.todayColor = [UIColor clearColor];
    self.calendar.appearance.titleTodayColor = [UIColor blackColor];
    
    [self addSubview:self.calendar];
    
    // Adding informative labels
    UILabel *startDateInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, quarterWidth / 2, ninthHeight)];
    startDateInfo.textAlignment = NSTextAlignmentRight;
    startDateInfo.text = @"Start:";
    startDateInfo.font = boldFont;
    startDateInfo.minimumScaleFactor = 0.5;
    [self addSubview:startDateInfo];
    
    self.startDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(quarterWidth / 2, 0, quarterWidth * 2, ninthHeight)];
    self.startDateLabel.textAlignment = NSTextAlignmentLeft;
    self.startDateLabel.font = font;
    self.startDateLabel.minimumScaleFactor = 0.5;
    [self addSubview:self.startDateLabel];
    
    UILabel *endDateInfo = [[UILabel alloc] initWithFrame:CGRectMake(quarterWidth * 2, 0, quarterWidth / 2, ninthHeight)];
    endDateInfo.textAlignment = NSTextAlignmentRight;
    endDateInfo.text = @"End:";
    endDateInfo.font = boldFont;
    endDateInfo.minimumScaleFactor = 0.5;
    [self addSubview:endDateInfo];
    
    self.endDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(quarterWidth * 2.5, 0, quarterWidth * 2, ninthHeight)];
    self.endDateLabel.textAlignment = NSTextAlignmentLeft;
    self.endDateLabel.font = font;
    self.endDateLabel.minimumScaleFactor = 0.5;
    [self addSubview:self.endDateLabel];
    
    [self updateDateLabels];
    
    // Adding action buttons
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, ninthHeight * 8, ninthHeight, ninthHeight)];
    [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    [self.cancelButton.imageView setContentMode: UIViewContentModeScaleAspectFit];
    [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    
    self.redoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ninthHeight, ninthHeight)];
    self.redoButton.center = CGPointMake(quarterWidth * 2, ninthHeight * 8.5);
    [self.redoButton setBackgroundImage:[UIImage imageNamed:@"Redo"] forState:UIControlStateNormal];
    [self.redoButton.imageView setContentMode: UIViewContentModeScaleAspectFit];
    [self.redoButton addTarget:self action:@selector(redo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.redoButton];
    
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - ninthHeight, ninthHeight * 8, ninthHeight, ninthHeight)];
    [self.doneButton setImage:[UIImage imageNamed:@"Checkmark"] forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.doneButton];
    
    // Adding Picker View
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ninthHeight * 4, self.frame.size.width, self.frame.size.height * 1 / 3)];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self setCurrentHoursAndMinutesForDateType:TLCurrentDateStart];
    
    [self addSubview:self.pickerView];
}

/** 
 Method to update info labels
 **/
- (void)updateDateLabels {
    [self setDate:self.startDate andTime:self.startTime forLabel:self.startDateLabel];
    [self setDate:self.endDate andTime:self.endTime forLabel:self.endDateLabel];
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
- (void)setHours:(int)hours andMinutes:(int)minutes forDateType:(TLCurrentDate)dateType {
    switch (dateType) {
        case TLCurrentDateStart:
            if (self.startDate) {
                [self setHours:hours andMinutes:minutes forTime:self.startTime];
            }
            break;
            
        default:
            if (self.endDate) {
                [self setHours:hours andMinutes:minutes forTime:self.endTime];
            }
            break;
    }
    
    [self updateDateLabels];
}

- (void)setCurrentHoursAndMinutesForDateType:(TLCurrentDate)dateType {
    unsigned unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.locale = self.calendar.locale;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:[NSDate date]];
    int hours = (int)comps.hour;
    int minutes = (int)comps.minute;
    
    [self setHours:hours andMinutes:minutes forDateType:dateType];
    
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
 Method is called when redo button is pressed
 It reset all the chosen dates
 **/
- (void)redo {
    if (self.startDate != nil) {
        [self.calendar deselectDate:self.startDate];
        self.startDate = nil;
    }
    
    if (self.endDate != nil) {
        [self.calendar deselectDate:self.endDate];
        self.endDate = nil;
    }
    
    [self updateDateLabels];
}

/**
 Method is called when done button is pressed
 It send dates to delegate method and removes itself
 **/
- (void)done {
    if ([self.delegate respondsToSelector:@selector(pickerDidSelectStartDate:)]) {
        NSDate *date = (self.startDate) ? [self addTime:self.startTime toDate:self.startDate] : nil;
        [self.delegate performSelector:@selector(pickerDidSelectStartDate:) withObject:date];
    }
    
    if ([self.delegate respondsToSelector:@selector(pickerDidSelectEndDate:)]) {
        NSDate *date = (self.endDate) ? [self addTime:self.endTime toDate:self.endDate] : nil;
        [self.delegate performSelector:@selector(pickerDidSelectEndDate:) withObject:date];
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
    if (self.startDate != nil) [self.calendar selectDate:self.startDate];
    if (self.endDate != nil) [self.calendar selectDate:self.endDate];
    [self updateDateLabels];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)setStartDate:(NSDate *)date {
    if (date != nil) {
        NSDate *zeroDate = [self addTime:[self zeroTime] toDate:date];
        _startDate = zeroDate;
        self.currentDateType = TLCurrentDateStart;
        [self setCurrentHoursAndMinutesForDateType:self.currentDateType];
        [self updateDateLabels];
    }
    else
        _startDate = date;
}

- (void)setEndDate:(NSDate *)date {
    if (date != nil) {
        NSDate *zeroDate = [self addTime:[self zeroTime] toDate:date];
        _endDate = zeroDate;
        self.currentDateType = TLCurrentDateEnd;
        [self setCurrentHoursAndMinutesForDateType:self.currentDateType];
        [self updateDateLabels];
    }
    else
        _endDate = date;
}

- (TLDatePickerTime *)zeroTime {
    TLDatePickerTime *res = [[TLDatePickerTime alloc] init];
    res.hours = 0;
    res.minutes = 0;
    
    return res;
}

// MARK: FSCalendar Delegate, DataSource & AppearanceDelegate
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    self.currentDate = date;
    
    if (self.endDate && self.startDate) {
        if ([date compare:self.endDate] != NSOrderedDescending) {
            [calendar deselectDate:self.startDate];
            self.startDate = date;
            self.currentDateType = TLCurrentDateStart;
        }
        else {
            [calendar deselectDate:self.endDate];
            self.endDate = date;
            self.currentDateType = TLCurrentDateEnd;
        }
    }
    else if (self.endDate) {
        if ([date compare:self.endDate] != NSOrderedDescending) {
            self.startDate = date;
            self.currentDateType = TLCurrentDateStart;
        }
        else {
            self.startDate = self.endDate;
            self.endDate = date;
            self.currentDateType = TLCurrentDateEnd;
        }
    }
    else if (self.startDate) {
        if ([date compare:self.startDate] != NSOrderedDescending) {
            self.endDate = self.startDate;
            self.startDate = date;
            self.currentDateType = TLCurrentDateStart;
        }
        else {
            self.endDate = date;
            self.currentDateType = TLCurrentDateEnd;
        }
    }
    else {
        self.startDate = date;
        self.currentDateType = TLCurrentDateStart;
    }
    
    [self setCurrentHoursAndMinutesForDateType:self.currentDateType];
    
    // Update labels
    [self updateDateLabels];
}

- (void)calendar:(FSCalendar *)calendar didDeselectDate:(NSDate *)date {
    if ([date compare:self.startDate] == NSOrderedSame)
        self.startDate = nil;
    else
        self.endDate = nil;
    
    [self updateDateLabels];
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
    int hours = [pickerView selectedRowInComponent:(NSInteger)0];
    int minutes = [pickerView selectedRowInComponent:(NSInteger)1];
    [self setHours:hours andMinutes:minutes forDateType:self.currentDateType];
}

@end


// MARK: Implementation of TLDatePickerTime
@implementation TLDatePickerTime

@end