//
//  PreferenceViewController.m
//  Alarmee
//
//  Created by 연희 김 on 12. 8. 16..
//  Copyright (c) 2012년 Powerwave Interactive. All rights reserved.
//

#import "PreferenceViewController.h"

@interface PreferenceViewController ()

@end

@implementation PreferenceViewController

- (void)loadView {
    // 이곳에 처음 View가 로드될 때 필요한 함수들을 작성한다.
    UIView *contentView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = contentView;
    
    self.view.backgroundColor = [UIColor grayColor];
    
    self.title = NSLocalizedString(@"Preference", nil);
    
    // view를 UITableView로 변경한다.
    _preferenceListTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
    self.view = _preferenceListTableView;
    _preferenceListTableView.delegate = self;
    _preferenceListTableView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIView beginAnimations:@"animation2" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 0.7];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO]; 
    [UIView commitAnimations]; 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{   
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section) {
    case 0:
        return 1;
    default:
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier_VH1981222";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    int positionId = 100 * indexPath.section + indexPath.row;
    switch(positionId) {
        case 0:
            [cell.textLabel setText:NSLocalizedString(@"Clear All", nil)];
            break;
        case 1:
            break;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int positionId = 100 * indexPath.section + indexPath.row;
    
    switch(positionId) {
        case 0:
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Clear All", nil) 
                                  message:NSLocalizedString(@"Clear all?", nil) 
                                  delegate:self
                                  cancelButtonTitle:@"아니오"
                                  otherButtonTitles:@"예", nil];
            [alert show];
            
            UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setSelected:FALSE];
            
            break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0) {
        // 모두 지워야 한다.
        [self.navigationController popViewControllerAnimated:FALSE];
    }
}

@end
