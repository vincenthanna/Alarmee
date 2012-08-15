//
//  itemViewController.m
//  Alarmee
//
//  Created by 김 연희 on 12. 2. 28..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//


#import "itemViewController.h"
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
                      target:self action:@selector(pickerDone)];
    
    // bar button for modify
    _barButtonApply = [[UIBarButtonItem alloc]
                        initWithTitle: NSLocalizedString(@"Modify", nil)
                        style: UIBarButtonItemStyleBordered
                        target:self action:@selector(applyChange)];
    self.navigationItem.rightBarButtonItem = _barButtonApply;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)isViewLoaded {
    // table cell의 height를 계산해 둔다.
    CGRect rect = [self.view frame];
    sizeByRow[ROW_TITLE] = 40;
    sizeByRow[ROW_DUEDATE] = 40;
    sizeByRow[ROW_REPEAT] = 40;
    sizeByRow[ROW_TODO] = (rect.size.height - (sizeByRow[ROW_TITLE] + sizeByRow[ROW_DUEDATE] + sizeByRow[ROW_REPEAT]));   
    
    NSLog(@"[%s]%d _textInputSet.count=%d", __func__,__LINE__, [_textInputSet count]);
    [_detailTableView reloadData];
    
    if (operatingMode == ItemViewMode_New) {
        [_barButtonApply setTitle:NSLocalizedString(@"Add",nil)];
    }
    else{
        [_barButtonApply setTitle:NSLocalizedString(@"Modify",nil)];
    }
    
    return [super isViewLoaded];
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


/////////////////////////////////////////////////////////
// table view delegate/datasource
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:_reuseId];        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGRect viewRect = [cell frame];
        CGRect sizeRect;
        switch(indexPath.row) {
            case ROW_TITLE:
            {
                UITextField *textField=[[UITextField alloc] initWithFrame:CGRectMake(100,10,150,27)];
                textField.delegate = self;
                textField.returnKeyType = UIReturnKeyDone;
                textField.tag = indexPath.row+1;
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
                textView.tag = indexPath.row + 1;
                textView.autocorrectionType = UITextAutocorrectionTypeNo;
                textView.autocapitalizationType =  UITextAutocapitalizationTypeNone;
                [cell.contentView addSubview:textView];
    
                sizeRect = CGRectMake(10, 10, viewRect.size.width - (10 * 2), cellHeight);
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
            [_textFieldTitle setText:_item.title];
            [_textFieldTitle setPlaceholder:NSLocalizedString(@"Title",nil)];
            break;
        case ROW_TODO:
            [_textViewToDo setText:_item.todo];
            break;
        case ROW_DUEDATE:
            [cell.textLabel setText:[_item dueDateString]];
            break;
        case ROW_REPEAT:
            [cell.textLabel setText:[_item repeatModeString]];
            break;
        default:
            assert(false);
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch(indexPath.row) {
        case ROW_TITLE:
        case ROW_TODO:
        {
            UIResponder *responder = [cell.contentView viewWithTag:indexPath.row+1];
            [responder becomeFirstResponder];
        }
            break;
        case ROW_DUEDATE:
        {
            [self duedateTouched:self];
        }
            break;
        case ROW_REPEAT:
        {
            [self repeatTouched:self];
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return sizeByRow[indexPath.row];
}

#pragma mark - textField/textView delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textInputView = textField;
}

-(void)textViewDidChange:(UITextView *)textView
{
    _item.todo = textView.text;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"[%s]%d", __func__,__LINE__);
    if (textField == _textFieldTitle)  {
        _item.title = [_textFieldTitle text];
    }
}


#pragma mark - 키보드 악세사리 컨트롤 추가 코드
-(void)createInputAccessoryView{
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 310.0, 40.0)];

    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    [inputAccView setAlpha: 0.8];
    
    btnPrev = [UIButton buttonWithType: UIButtonTypeCustom];
    [btnPrev setFrame: CGRectMake(0.0, 0.0, 80.0, 40.0)];
    [btnPrev setTitle: @"Previous" forState: UIControlStateNormal];
    [btnPrev setBackgroundColor: [UIColor blueColor]];
    [btnPrev addTarget: self action: @selector(gotoPrevTextfield) forControlEvents:UIControlEventTouchUpInside];
    
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
}

-(void)textViewDidBeginEditing:(UITextView *)textView 
{
    textInputView = textView;
}

#pragma mark Picker functions

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
    }
    else if (view == _duedatePicker) {
        _item.duedate = [_duedatePicker date];    
    }
    
    [_detailTableView reloadData];
}

#pragma mark - UIPickerView delegate messages

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
    NSLog(@"[%s]%d", __func__,__LINE__);
    BOOL bRet;
    DBAccessHelper *dbHelper = [[DBAccessHelper alloc]init];
    int addMode = (operatingMode == ItemViewMode_New) ? 0 : 1;
    bRet = [dbHelper addNewItem:_item isExists:addMode];
    if (bRet != YES) {
        NSLog(@"[%s]%d Fail!", __func__,__LINE__);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
