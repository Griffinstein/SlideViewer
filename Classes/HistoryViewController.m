//
//  HistoryViewController.m
//  iSlideViewer
//
//  Created by Ed on 5/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"

@implementation HistoryViewController
@synthesize delegate, picker, pickerArray, slideDirectory, directory;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [pickerArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [pickerArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	slideDirectory = [pickerArray objectAtIndex:row];
	directory.text = [pickerArray objectAtIndex:row];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	directory.numberOfLines = 0;
	directory.text = [pickerArray objectAtIndex:0];
	slideDirectory = [pickerArray objectAtIndex:0];
}

- (void)testSetup:(NSMutableArray *)array  {
	
	pickerArray = [[NSMutableArray alloc] init];
	pickerArray = array;
	
	[pickerArray retain];
}

- (IBAction)cancel
{
	[self.delegate HistoryViewControllerCancel:self];
}

- (IBAction)loadHistory;
{
	[self.delegate HistoryViewControllerLoadHistory:self directory:slideDirectory];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[pickerArray release];
	
    [super dealloc];
}

@end
