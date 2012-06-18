//
//  MainViewController.h
//  SpeedGauge
//
//  Created by Taras Kalapun on 6/18/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "FlipsideViewController.h"
#import "TKGaugeViewController.h"

@interface MainViewController : TKGaugeViewController <FlipsideViewControllerDelegate>

- (IBAction)showInfo:(id)sender;
- (IBAction)toggleRandomTimer:(id)sender;

@end
