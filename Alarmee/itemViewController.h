//
//  itemViewController.h
//  Alarmee
//
//  Created by 김 연희 on 12. 2. 28..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

static NSString* _reuseId = @"DFDADFDSFASDF";
@interface itemViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate>
{
    enum{ItemViewMode_Apply=0, ItemViewMode_New, ItemViewMode_MAX};
    unsigned int operatingMode;
    UITableView *_detailTableView;
    Item* _item;
    
    enum {ROW_TITLE = 0, ROW_TODO, ROW_DUEDATE, ROW_REPEAT, ROW_JOB_DONE_OR_ADD_NEW, ROW_MAX};
    
    UIView *inputAccView;
    UIButton *btnDone;
    UIButton *btnNext;
    UIButton *btnPrev;
    UIView *textInputView;
    
    UITextField *_textFieldTitle;
    UITextView *_textViewToDo;
    
    CGFloat sizeByRow[ROW_MAX];
    
    NSMutableOrderedSet* _textInputSet;
    
    UIDatePicker *_duedatePicker;
    UIPickerView *_repeatPicker;
    id _activatedPicker;
    
    UIBarButtonItem *_barButtonDone;
    UIBarButtonItem *_barButtonOrignal;
    
    UIBarButtonItem *_barButtonApply;
}
- (void)setOperatingMode:(int)mode;
- (void)loadData:(Item*)item;

@property (nonatomic, retain)Item* _item;

@property (nonatomic, retain) UIView *inputAccView;
@property (nonatomic, retain) UIButton *btnDone;
@property (nonatomic, retain) UIButton *btnNext;
@property (nonatomic, retain) UIButton *btnPrev;
@property (nonatomic, retain) UIView *textInputView;

@end
