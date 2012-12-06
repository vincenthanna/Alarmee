//
//  itemViewController.m
//  Alarmee
//
//  Created by 김 연희 on 12. 2. 28..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//


#import "itemViewController.h"
#import "vh1981AppDelegate.h"
#import "db_access.h"

@implementation itemViewController

@synthesize _item;
@synthesize inputAccView;
@synthesize btnDone;
@synthesize btnNext;
@synthesize btnPrev;
@synthesize textInputView;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)loadView {
    // base가 될 기본 view를 만든다.
    UIView *contentView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = contentView;    

    // 전체를 덮을 table view를 만든다.
    _detailTableView = [[UITableView alloc]init];
    CGRect rect = [self.view frame];
    rect.origin.y = 0;
    [_detailTableView setFrame:rect];
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;    
    [self.view addSubview:_detailTableView];

    _textInputSet = [[NSMutableOrderedSet alloc]init];
    
    [self createInputAccessoryView];
    
    // date picker for due date :
    _duedatePicker = [[UIDatePicker alloc] init];
    
    // picker view for repeat mode :
    _repeatPicker = [[UIPickerView alloc]init];
    _repeatPicker.delegate = self;
    _repeatPicker.showsSelectionIndicator = YES;
    
    // navigation right button for resigning picker views
    _barButtonDone = [[UIBarButtonItem alloc]
                      initWithTitle: @"Done"
                      style: UIBarButtonItemStyleBordered
                      target:self action:@selector(hidePicker)];
    
    // bar button for modify
    _barButtonApply = [[UIBarButtonItem alloc]
                        initWithTitle: NSLocalizedString(@"Modify", nil)
                        style: UIBarButtonItemStyleBordered
                        target:self action:@selector(applyChange)];
    self.navigationItem.rightBarButtonItem = _barButtonApply;
}

-(void)hidePicker {
    [self pickerDone:YES];
}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter]
        addObserver:self  
        selector:@selector(keyboardMoved:)
        name:UIKeyboardDidShowNotification
        object:nil];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    if (operatingMode == ItemViewMode_New) {
        [_barButtonApply setTitle:NSLocalizedString(@"Add",nil)];
    }
    else{
        [_barButtonApply setTitle:NSLocalizedString(@"Modify",nil)];
    }
    
    // reload data
    self.navigationItem.rightBarButtonItem = _barButtonApply;
    
    // table cell의 height를 계산해 둔다.
    CGRect rect = [self.view frame];
    sizeByRow[ROW_TITLE] = 40;
    sizeByRow[ROW_DUEDATE] = 40;
    sizeByRow[ROW_REPEAT] = 40;
    sizeByRow[ROW_JOB_DONE_OR_ADD_NEW] = 40;
    sizeByRow[ROW_TODO] = (rect.size.height -
                           (sizeByRow[ROW_TITLE] + sizeByRow[ROW_DUEDATE] + sizeByRow[ROW_REPEAT]
                            + sizeByRow[ROW_JOB_DONE_OR_ADD_NEW]));
    
    [_detailTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
    if (_textFieldTitle != nil)
        [_textFieldTitle resignFirstResponder];
    if (_textViewToDo != nil)
        [_textViewToDo resignFirstResponder];
    [self pickerDone:NO];
}


-(void)keyboardMoved:(NSNotification *)notification
{
    if(notification.name == UIKeyboardDidShowNotification) {
        
        CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];

        // keyboardFrame 으로부터 키보드의 높이를 구해서 뷰의 크기를 조정 
        // 가로세로 모드인지를 확인해야 한다. 사이즈는 항상 세로 기준으로 나온다.
        NSLog(@"keyboard size x=%f y=%f w=%f h=%f",
              keyboardFrame.origin.x, keyboardFrame.origin.y,
              keyboardFrame.size.width, keyboardFrame.size.height);
        NSLog(@"hello");
        
        // 키보드가 올라올 때 textView 사이즈를 줄어든 화면에 맞도록 조정한다.
        CGRect navRect = self.navigationController.navigationBar.frame;
        
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        
        int smallTextViewHeight = screenRect.size.height -
            (sizeByRow[ROW_TITLE] + keyboardFrame.size.height + (navRect.size.height + navRect.origin.y));
        CGRect sizeRect = CGRectMake(10, 10, screenRect.size.width - (10 * 2), smallTextViewHeight);
        NSLog(@"small textView x=%f y=%f w=%f h=%f",
              sizeRect.origin.x, sizeRect.origin.y, sizeRect.size.width, sizeRect.size.height);
        [_textViewToDo setFrame:sizeRect];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setOperatingMode:(int)mode
{
    if (mode < ItemViewMode_MAX) {
        operatingMode = mode;
    }
}

- (void)loadData:(Item*)item
{
    _item = item;
}

// table view delegate/datasource
#pragma mark -
#pragma mark UITableView delegate/data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    [tableView setBackgroundColor:[UIColor clearColor]];
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // title, todo, duedate, repeatmode
	return ROW_MAX;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"[%s]%d cell %d", __func__,__LINE__, indexPath.row); 
    
	UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:_reuseId];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_reuseId];        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        CGRect viewRect = [cell frame];
        CGRect sizeRect;
        switch(indexPath.row) {
            case ROW_TITLE:
            {
                UITextField *textField=[[UITextField alloc] initWithFrame:CGRectMake(100,10,150,27)];
                textField.delegate = self;
                textField.returnKeyType = UIReturnKeyDone;
                textField.tag = indexPath.row + 1;
                textField.autocorrectionType = UITextAutocorrectionTypeNo;          
                textField.autocapitalizationType =  UITextAutocapitalizationTypeSentences;
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [cell.contentView addSubview:textField];
                
                NSString *title = NSLocalizedString(@"Title", nil);
                title = [title stringByAppendingString:@":"];
                CGSize textSize = [title sizeWithFont:textField.font];
                CGFloat cellHeight = sizeByRow[ROW_TITLE];
                sizeRect = CGRectMake(textSize.width + 20,
                                           (cellHeight - textSize.height)/2,
                                           viewRect.size.width - (textSize.width + 20),
                                           textSize.height);
                [cell.textLabel setText:title];
                [textField setFrame:sizeRect];
                [textField setInputAccessoryView:inputAccView];
                _textFieldTitle = textField;
                [_textInputSet addObject:_textFieldTitle];
                NSLog(@"[%s]%d _textInputSet.count=%d", __func__,__LINE__, [_textInputSet count]);
            }
                break;
            case ROW_TODO:
            {
                CGFloat cellHeight = sizeByRow[ROW_TODO];                
                UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(100,10,150,27)];
                textView.delegate = self;
                textView.returnKeyType = UIReturnKeyDone;
                textView.tag = (indexPath.row + 1);
                textView.autocorrectionType = UITextAutocorrectionTypeNo;
                textView.autocapitalizationType =  UITextAutocapitalizationTypeNone;
                [cell.contentView addSubview:textView];
    
                sizeRect = CGRectMake(10, 10, viewRect.size.width - (10 * 2), cellHeight - 10);
                [textView setFrame:sizeRect];                
                [textView setInputAccessoryView:inputAccView];
                _textViewToDo = textView;
                [_textInputSet addObject:_textViewToDo];
                NSLog(@"[%s]%d _textInputSet.count=%d", __func__,__LINE__, [_textInputSet count]);
            }
                break;
        }
    }
    
    //fill data by indexPath.row
    switch (indexPath.row) {
        case ROW_TITLE:
        {
            [_textFieldTitle setText:_item.title];
            [_textFieldTitle setPlaceholder:NSLocalizedString(@"Title",nil)];
            break;
        }
        case ROW_TODO:
        {
            [_textViewToDo setText:_item.todo];
            CGFloat cellHeight = sizeByRow[ROW_TODO];
            CGRect viewRect = [cell frame];
            CGRect sizeRect = CGRectMake(10, 10, viewRect.size.width - (10 * 2), cellHeight - (10 * 2));
            [_textViewToDo setFrame:sizeRect];
            break;
        }
        case ROW_DUEDATE:
        {
            [cell.textLabel setText:[_item dueDateString:false]];
            break;
        }
        case ROW_REPEAT:
        {
            [cell.textLabel setText:[_item repeatModeString]];
            break;
        }
        case ROW_JOB_DONE_OR_ADD_NEW:
        {
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            if (operatingMode == ItemViewMode_New) {
                [cell.textLabel setText:NSLocalizedString(@"Add", nil)];
            }
            else {
                [cell.textLabel setText:NSLocalizedString(@"JOB_DONE", nil)];
            }
        }
            break;
        default:
        {
            assert(false);
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"[%s]%d row=%d", __FUNCTION__, __LINE__, indexPath.row);
    switch(indexPath.row) {
        case ROW_TITLE:
        case ROW_TODO:
        {
            NSLog(@"[%s]%d", __FUNCTION__,__LINE__);
  //          UIResponder *responder = [cell.contentView viewWithTag:indexPath.row+1];
  //          [responder becomeFirstResponder];
            break;
        }
        case ROW_DUEDATE:
        {
            [self duedateTouched:self];
            break;
        }
        case ROW_REPEAT:
        {
            [self repeatTouched:self];
            break;
        }
        case ROW_JOB_DONE_OR_ADD_NEW:
        {
            if (operatingMode == ItemViewMode_New) {
                [self applyChange];
            }
            else if (operatingMode == ItemViewMode_Apply){
                [self todoDone];
            }
            else {
                assert(false);
            }
            break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return sizeByRow[indexPath.row];
}

#pragma mark - textField / textView delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textInputView = textField;
}

-(void)textViewDidChange:(UITextView *)textView
{
    _item.todo = textView.text;
    [self todoScroll:textView];
}

-(void)todoScroll:(UITextView*)textView
{
    NSRange range = [textView selectedRange];
    NSLog(@"[%s]%d location=%d length=%d", __func__,__LINE__, range.location, range.length);
    if (range.location < 10) {
        [textView scrollRangeToVisible:NSMakeRange(/*location*/ 0, /*length*/ 10)];
    }
    else {

        [textView scrollRangeToVisible:NSMakeRange(/*location*/ range.location, /*length*/ 5)];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _textFieldTitle)  {
        _item.title = [_textFieldTitle text];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView 
{
    textInputView = textView;
    [self todoScroll:textView];
}

#pragma mark - 키보드 악세사리 컨트롤 추가 코드
-(void)createInputAccessoryView{
    
    float buttonOffset = 5;
    float buttonPosX = 0;
    CGRect rect = self.view.frame;
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, rect.size.width, 40.0)];

    [inputAccView setBackgroundColor:[[UIColor alloc]initWithWhite:0.0f alpha:0.5f]];
    
    btnPrev = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [btnPrev setFrame: CGRectMake(buttonOffset, 5.0, 80.0, 30.0)];
    [btnPrev setTitle:NSLocalizedString(@"Previous",nil) forState: UIControlStateNormal];
    [btnPrev addTarget: self action: @selector(gotoPrevTextfield) forControlEvents:UIControlEventTouchUpInside];
    buttonPosX += (btnPrev.frame.origin.x + btnPrev.frame.size.width + buttonOffset);
    
    btnNext = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnNext setFrame:CGRectMake(buttonPosX, 5.0f, 80.0f, 30.0f)];
    [btnNext setTitle:NSLocalizedString(@"Next",nil) forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(gotoNextTextfield) forControlEvents:UIControlEventTouchUpInside];
    buttonPosX += (btnPrev.frame.origin.x + btnPrev.frame.size.width + buttonOffset);
    
    btnDone = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnDone setFrame:CGRectMake(240.0, 5.0f, 80.0f - buttonOffset, 30.0f)];
    [btnDone setTitle:NSLocalizedString(@"Done",nil) forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    
    [inputAccView addSubview:btnPrev];
    [inputAccView addSubview:btnNext];
    [inputAccView addSubview:btnDone];
}

-(void)gotoPrevTextfield{
    int index = [_textInputSet indexOfObject:textInputView];
    if (index != NSNotFound) {
        index = (index + [_textInputSet count] - 1) % [_textInputSet count];
        UIResponder* responder = [_textInputSet objectAtIndex:index];
        [responder becomeFirstResponder];
    }
}

-(void)gotoNextTextfield{
    int index = [_textInputSet indexOfObject:textInputView];
    if (index != NSNotFound) {
        index = (index + 1) % [_textInputSet count];
        UIResponder* responder = [_textInputSet objectAtIndex:index];
        [responder becomeFirstResponder];
    }
}

-(void)doneTyping{
    [textInputView resignFirstResponder];
    [_detailTableView reloadData];
}


#pragma mark -
#pragma mark Picker 동작관련

-(void)duedateTouched:(id)sender {
    [_duedatePicker setDate:_item.duedate];
    _activatedPicker = _duedatePicker;
    [self showPicker:sender];
}

-(void)repeatTouched:(id)sender {
    _activatedPicker = _repeatPicker;
    [_repeatPicker selectRow:_item.repeat inComponent:0 animated:NO];
    [self showPicker:sender];
}

-(void) showPicker:(id)sender
{
    UIView* picker = _activatedPicker; // get selected picker
    
    // check if our date picker is already on screen
	if (picker.superview == nil) {
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

-(void)pickerDone:(BOOL)reload{
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

	[UIView commitAnimations];
    
    // restore previous bar button
    self.navigationItem.rightBarButtonItem = _barButtonOrignal;
    
    // update buttons
    if (view == _repeatPicker) {
    }
    else if (view == _duedatePicker) {
        _item.duedate = [_duedatePicker date];
    }
    
    if(reload) [_detailTableView reloadData];
}

#pragma mark -
#pragma mark UIPickerView delegate messages

/////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return REPEAT_MAX;
    }
    else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [Item getRepeatModeString:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _item.repeat = row;
}

#pragma mark - Modify function
-(void)applyChange
{
    BOOL bRet;
    
    // check input:
    if (_item.title == nil || [_item.title length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)  
														message:[NSString stringWithFormat:NSLocalizedString(@"PleaseWriteTitle", nil)] 
													   delegate:nil 
											  cancelButtonTitle:nil 
											  otherButtonTitles:NSLocalizedString(@"OK",nil),nil];
		[alert show];
        return;
    }
    
    // show alert view:
    UIAlertView *alert = [self showAlert:NSLocalizedString(@"Saving...", nil)];
    
    // 변경/추가 시 재 스케줄링을 해야 한다.
    [Schedule schedule:_item];
    
    DBAccessHelper *dbHelper = ((vh1981AppDelegate *)[[UIApplication sharedApplication] delegate]).dbHelper;
    int addMode = (operatingMode == ItemViewMode_New) ? 0 : 1;
    bRet = [dbHelper addNewItem:_item isExists:addMode];
    if (bRet != YES) {
        // 저장 실패:
        NSLog(@"[%s]%d Fail!", __func__,__LINE__);
        assert(false);
    }

    NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
    [userInfoDic setValue:alert forKey:@"alertView"];//UIAlertView
    [userInfoDic setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:@"popCurrentView"]; //끝나고 뒤로 갈 것인가.
    [userInfoDic setValue:[[NSNumber alloc] initWithBool:bRet] forKey:@"result"]; //처리결과 YES/NO

    // hide alert view:
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(performHideAlert:) userInfo:userInfoDic repeats:NO];
}

#pragma mark - ToDo Done
-(void)todoDone
{
    BOOL bRet;
    
    // show alert view:
    UIAlertView *alert = [self showAlert:NSLocalizedString(@"JOB_DONE", nil)];

    // todo가 완료되었음을 db에 저장한다.
    DBAccessHelper *dbHelper = ((vh1981AppDelegate *)[[UIApplication sharedApplication] delegate]).dbHelper;
    _item.status = STAT_DONE;
    bRet = [dbHelper addNewItem:_item isExists:YES];
    if (bRet != YES) {
        // 저장 실패:
        NSLog(@"[%s]%d Fail!", __func__,__LINE__);
        assert(false);
    }

    // timer이벤트에 넘길 dictionary 만든다.
    NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
    [userInfoDic setValue:alert forKey:@"alertView"];//UIAlertView
    [userInfoDic setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:@"popCurrentView"]; //끝나고 뒤로 갈 것인가.
    [userInfoDic setValue:[[NSNumber alloc] initWithBool:bRet] forKey:@"result"]; //처리결과 YES/NO
    
    // hide alert view:
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(performHideAlert:) userInfo:userInfoDic repeats:NO];
}

#pragma mark - Show Alert & Go Back
-(UIAlertView*)showAlert:(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:nil delegate:nil cancelButtonTitle:nil
                          otherButtonTitles: nil];
    [alert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]
                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    indicator.center = CGPointMake(alert.bounds.size.width / 2,
                                   alert.bounds.size.height - 50);
    [indicator startAnimating];
    [alert addSubview:indicator];
    
    return alert;
}

- (void)performHideAlert:(NSTimer *)timer {
    NSMutableDictionary *userInfoDic = [timer userInfo];
    UIAlertView  *baseAlert = [userInfoDic valueForKey:@"alertView"]; // UIAlertView얻음
    NSNumber* bPopCurrentView = [userInfoDic valueForKey:@"popCurrentView"]; // alertView 닫은 이후에 무엇을 해야 하는지 확인
    NSNumber* bResult = [userInfoDic valueForKey:@"result"];
    
    // UIAlertView를 닫는다.
	[baseAlert dismissWithClickedButtonIndex:0 animated:YES];

    // 성공하면 list로 되돌아가고 실패시, 에러 alert창을 띄움
    if (bResult.boolValue) {
        // 저장 성공
        if (bPopCurrentView.boolValue) {
            [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(performEnd:) userInfo:nil repeats:NO];
        }
    }
    else {
        // 저장 실패
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														message:[NSString stringWithFormat:NSLocalizedString(@"SaveError", nil)]
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"OK",nil),nil];
		[alert show];
        return;
    }
}

-(void)performEnd:(NSTimer *)timer {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
