//
//  MainViewController.m
//  SpeedGauge
//
//  Created by Taras Kalapun on 6/18/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "MainViewController.h"
#import "TKSimpleDataFilter.h"

@interface MainViewController ()
@property (nonatomic, retain) NSTimer *dataTimer;
@end

@implementation MainViewController

@synthesize dataTimer=dataTimer_;

- (id)init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        self.gaugePath = [[path stringByAppendingPathComponent:@"Gauges"] stringByAppendingPathComponent:@"fuelpres.gauge"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    [self welcome];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
}


#pragma mark - Random Timer

- (IBAction)toggleRandomTimer:(id)sender {
    
	if (self.dataTimer) {
		[dataTimer_ invalidate];
        self.dataTimer = nil;
		return;
	}
    
	[dataTimer_ invalidate];
	self.dataTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                      target:self
                                                    selector:@selector(handleRandomTimer:)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)handleRandomTimer:(NSTimer *)timer {
     float f = [TKSimpleDataFilter floatRandFrom:[self minValue] to:[self maxValue]];
     [self setValue:f];
}
@end
