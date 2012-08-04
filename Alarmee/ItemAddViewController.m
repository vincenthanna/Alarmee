//
//  ItemAddViewController.m
//  Alarmee
//
//  Created by 김 연희 on 12. 4. 11..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import "ItemAddViewController.h"
#import "vh1981AppDelegate.h"
#import "db_access.h"
#import "Item.h"

@implementation ItemAddViewController

@synthesize txtActiveField;
@synthesize inputAccView;
@synthesize btnDone;
@synthesize btnNext;
@synthesize btnPrev;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define PERCENTAGE(a,b) (((a) * (b))/100)
- (void)loadView
{
    // base가 될 기본 view를 만든다.
    UIView *contentView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = contentView;    
    [self setTitle:@"Add New Item"];
    
    _repeatPickerStrings = [[NSMutableArray alloc] init];
    [_repeatPickerStrings addObject:NSLocalizedString(@"No Repeat", nil)];
    [_repeatPickerStrings addObject:NSLocalizedString(@"Daily", nil)];
    [_repeatPickerStrings addObject:NSLocalizedString(@"Weekly", nil)];
    [_repeatPickerStrings addObject:NSLocalizedString(@"Monthly", nil)];
    _repeatMode = REPEAT_NONE;
    
    _textFieldSet = [[NSMutableOrderedSet alloc]init];
    
    CGRect frameRect,viewRect;
    CGRect labelRect,nameRect,memoRect, duedateRect, repeatRect, saveButtonRect;
    viewRect = [self.view frame];
    float controlOffset = 10;
    
    float viewWidth, viewHeight, frameWidthOffset, frameHeightOffset, positionY = 0;
    
    viewWidth = viewRect.size.width;
    viewHeight = viewRect.size.height;
    frameWidthOffset = (viewWidth - PERCENTAGE(viewWidth,80)) / 2;
    frameHeightOffset = (viewHeight - PERCENTAGE(viewHeight,80)) / 2;
    frameRect = CGRectMake(frameWidthOffset, frameHeightOffset, viewRect.size.width - (frameWidthOffset * 2), viewRect.size.height - (frameHeightOffset*2));
    positionY = frameHeightOffset;
    
    labelRect = CGRectMake(frameWidthOffset, positionY, PERCENTAGE(viewWidth, 30), 30.0);
    nameRect = CGRectMake(frameWidthOffset + labelRect.size.width + controlOffset,
                          positionY, 
                          viewWidth - (labelRect.origin.x + labelRect.size.width + frameWidthOffset + controlOffset), 
                          30);
    positionY += (30 + controlOffset);
    memoRect = CGRectMake(frameWidthOffset, positionY, frameRect.size.width, PERCENTAGE(frameRect.size.height, 50));
    positionY += (PERCENTAGE(frameRect.size.height, 50) + controlOffset);
    duedateRect = CGRectMake(frameWidthOffset, positionY, frameRect.size.width, 30);
    positionY += (30 + controlOffset);
    repeatRect = CGRectMake(frameWidthOffset, positionY, frameRect.size.width, 30);
    positionY += (30 + controlOffset);
    saveButtonRect = CGRectMake(frameWidthOffset, positionY, PERCENTAGE(frameRect.size.width, 40), 30);
    positionY += (30 + controlOffset);

    //name 타이틀
    {
        NSLog(@"############title=%@", NSLocalizedString(@"Title", @"제목"));
        UILabel *label = [[UILabel alloc]initWithFrame:labelRect];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setNumberOfLines:1];
        [label setFont:[UIFont systemFontOfSize:17.0]];
        [label setTextAlignment:UITextAlignmentLeft];
        [label setText:NSLocalizedString(@"Title", @"제목")];
        [self.view addSubview:label];
    }
    
    // name 입력 필드
    {
        _textFieldName = [[UITextField alloc] initWithFrame:nameRect];
        [_textFieldName setDelegate:self];
        [_textFieldName setBorderStyle:UITextBorderStyleRoundedRect];
        [_textFieldName setKeyboardType:UIKeyboardTypeDefault];
        [_textFieldName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_textFieldName setFont:[UIFont systemFontOfSize:17.0]];
        [_textFieldName setTextAlignment:UITextAlignmentLeft];
        [self.view addSubview:_textFieldName];
        [_textFieldSet addObject:_textFieldName];
    }
    
    // 본문 입력 필드
    {
        _textFieldToDo = [[UITextField alloc] initWithFrame:memoRect];
        [_textFieldToDo setDelegate:self];
        [_textFieldToDo setBorderStyle:UITextBorderStyleRoundedRect];
        [_textFieldToDo setKeyboardType:UIKeyboardTypeDefault];
        [_textFieldToDo setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_textFieldToDo setFont:[UIFont systemFontOfSize:17.0]];
        [_textFieldToDo setTextAlignment:UITextAlignmentLeft];
        [self.view addSubview:_textFieldToDo];
        [_textFieldSet addObject:_textFieldToDo];
    }
    
    // due date 설정 버튼
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setFrame:duedateRect];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        _duedate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:_duedate]; 
        [btn setTitle:dateString forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(duedateTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];  
        
        _duedateButton = btn;
    }
    
    // repeat 설정 버튼
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setFrame:repeatRect];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:[_repeatPickerStrings objectAtIndex:REPEAT_NONE] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(repeatTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];        
        _repeatButton = btn;
    }
    
    //저장버튼
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [btn setFrame:saveButtonRect];
        [btn setTitle:@"Add Item" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];        
    }

    // date picker for due date
    _duedatePicker = [[UIDatePicker alloc] init];
    

    // picker view for repeat mode
    _repeatPicker = [[UIPickerView alloc]init];
    _repeatPicker.delegate = self;
    _repeatPicker.showsSelectionIndicator = YES;

    // navigation right button for resigning picker views
    _barButtonDone = [[UIBarButtonItem alloc]
                      initWithTitle: @"Done"
                      style: UIBarButtonItemStyleBordered
                      target:self action:@selector(pickerDone)];


}


#pragma mark - UIPickerView delegate messages

/////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"numberOfRowsInComponent");
    /*
     numberOfRowsInComponent: 메서드는 각각의 PickerView 가 가져야 하는 행의 갯수를
     리턴해야 합니다.
     이 메서드는 numberOfComponentsInPickerView 에서 지정한 열의 수만큼 호출됩니다.
     호출시 인자값 component 값은 각각의 열이 가지는 index 값입니다.
     따라서 각각의 열이 가져야 하는 행의 수를 리턴시키면 됩니다.
     
     예를 들어 가장 왼쪽열의 행의 갯수를 10으로 하고 싶다면 이렇게 하면 됩니다.
     
     if( component == 0 )
     return 10;
     
     두번째 열의 경우 component 값이 1일 경우에 리턴값을 지정하면됩니다.
     */
    
    // 가장 왼쪽열의 행의 갯수를 지정합니다.
    if (component == 0) {
        return REPEAT_MAX;
    }
    else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_repeatPickerStrings objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{ 
    NSLog(@"repeat Picker = %d", row);
    _repeatMode = row;
}

/////////////////////////////////////////////////////////////////////////////


-(void)duedateTouched:(id)sender {
    _activatedPicker = _duedatePicker;
    [self showPicker:sender];
}

-(void)repeatTouched:(id)sender {
    _activatedPicker = _repeatPicker;
    [self showPicker:sender];
}

-(void) showPicker:(id)sender
{
    UIView* picker = _activatedPicker; // get selected picker
    
    // check if our date picker is already on screen
	if (picker.superview == nil){
		[self.view.window addSubview: picker];
    }
    
    // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
    // compute the start frame
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGSize pickerSize = [picker sizeThatFits:CGSizeZero]; //best한 size를 얻는다.
    CGRect startRect = CGRectMake(0.0,
                                  screenRect.origin.y + screenRect.size.height, //완전히 화면 아래쪽
                                  pickerSize.width, pickerSize.height);
    picker.frame = startRect;
    
    // compute the end frame
    CGRect pickerRect = CGRectMake(0.0,
                                   screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                   pickerSize.width,
                                   pickerSize.height);
    // start the slide up animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    // we need to perform some post operations after the animation is complete
    [UIView setAnimationDelegate:self];
    
    picker.frame = pickerRect;
    
    [UIView commitAnimations];
    
    // add the "Done" button to the nav bar
    _barButtonOrignal = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = _barButtonDone;
}

-(void)pickerDone {    
    UIView *view = _activatedPicker;
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = view.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    // we need to perform some post operations after the animation is complete
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
    view.frame = endFrame;
    
    // restore previous bar button
    self.navigationItem.rightBarButtonItem = _barButtonOrignal;
	[UIView commitAnimations];
    
    // update buttons
    if (view == _repeatPicker) {
        // update button text
        [_repeatButton setTitle:[_repeatPickerStrings objectAtIndex:_repeatMode] forState:UIControlStateNormal];
    }
    else if (view == _duedatePicker) {
        _duedate = [_duedatePicker date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:_duedate]; 
        [_duedateButton setTitle:dateString forState:UIControlStateNormal];
    }
}

-(void)buttonTouchedUpInside:(id)sender {
    // open db
    
    BOOL bRet;
    Item* item = [[Item alloc]init];

    item.title = [_textFieldName text];
    item.todo = [_textFieldToDo text];
    item.duedate = _duedate;
    item.adddate = [NSDate date];
    item.repeat = _repeatMode;

    DBAccessHelper *dbHelper = [[DBAccessHelper alloc] init];
    bRet = [dbHelper addNewItem:item isExists:0];
    if (bRet != TRUE) {
        NSLog(@"[%s]%d add Error!", __func__,__LINE__);
    }
    
    [_textFieldName resignFirstResponder];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)createInputAccessoryView{
    CGRect rect = [self.view frame];
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, rect.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    [inputAccView setAlpha: 0.8];
    
    btnPrev = [UIButton buttonWithType: UIButtonTypeCustom];
    [btnPrev setFrame: CGRectMake(0.0, 0.0, 80.0, 40.0)];
    [btnPrev setTitle: @"Previous" forState: UIControlStateNormal];
    // Background color.
    [btnPrev setBackgroundColor: [UIColor blueColor]];    
    [btnPrev addTarget: self action: @selector(gotoPrevTextfield) forControlEvents:UIControlEventTouchUpInside];
    
    // Do the same for the two buttons left.
    btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setFrame:CGRectMake(85.0f, 0.0f, 80.0f, 40.0f)];
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [btnNext setBackgroundColor:[UIColor blueColor]];
    [btnNext addTarget:self action:@selector(gotoNextTextfield) forControlEvents:UIControlEventTouchUpInside];
    
    btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(240.0, 0.0f, 80.0f, 40.0f)];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone setBackgroundColor:[UIColor greenColor]];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    
    // Now that our buttons are ready we just have to add them to our view.
    [inputAccView addSubview:btnPrev];
    [inputAccView addSubview:btnNext];
    [inputAccView addSubview:btnDone];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self createInputAccessoryView];
    [textField setInputAccessoryView:inputAccView];
    txtActiveField = textField;
}

-(void)gotoPrevTextfield{
    NSLog(@"[%s]%d", __PRETTY_FUNCTION__,__LINE__);
    int index = [_textFieldSet indexOfObject:txtActiveField];
    if (index != NSNotFound) {
        index = (index + [_textFieldSet count] - 1) % [_textFieldSet count];
        UITextField* field = [_textFieldSet objectAtIndex:index];
        [field becomeFirstResponder];
    }
}

-(void)gotoNextTextfield{
    NSLog(@"[%s]%d", __PRETTY_FUNCTION__,__LINE__);
    int index = [_textFieldSet indexOfObject:txtActiveField];
    if (index != NSNotFound) {
        index = (index + 1) % [_textFieldSet count];
        UITextField* field = [_textFieldSet objectAtIndex:index];
        [field becomeFirstResponder];
    }
}

-(void)doneTyping{
    [txtActiveField resignFirstResponder];
}

@end
