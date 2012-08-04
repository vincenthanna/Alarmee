//
//  ItemAddViewController.h
//  Alarmee
//
//  Created by 김 연희 on 12. 4. 11..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemAddViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate>
{
    UITextField* _textFieldName;
    UITextField* _textFieldToDo;
    UIButton* _duedateButton;
    UIButton* _repeatButton;
    NSDate* _duedate;
    UIView *inputAccView;
    UIButton *btnDone;
    UIButton *btnNext;
    UIButton *btnPrev;
    UITextField *txtActiveField;
    
    UIDatePicker *_duedatePicker;
    
    NSMutableOrderedSet* _textFieldSet;    
    UIBarButtonItem *_barButtonDone;
    UIBarButtonItem *_barButtonOrignal;
    
    UIPickerView *_repeatPicker;
    
    NSMutableArray *_repeatPickerStrings;
    
    id _activatedPicker;
    
    int _repeatMode;
}
@property (nonatomic, retain) UIView *inputAccView;
@property (nonatomic, retain) UIButton *btnDone;
@property (nonatomic, retain) UIButton *btnNext;
@property (nonatomic, retain) UIButton *btnPrev;
@property (nonatomic, retain) UITextField *txtActiveField;

-(void)pickerDone;

@end
