//
//  TKGaugeViewController.m
//  TKGauge
//
//  Created by Taras Kalapun on 6/18/12.
//

#import <QuartzCore/QuartzCore.h>
#import "TKGaugeViewController.h"
#import "TKSimpleDataFilter.h"
#import "TKGaugeView.h"

#define DEGTORAD(x) ((x) * (M_PI / 180.0f))

@interface TKGaugeViewController ()

#ifdef __AudioToolbox_H
@property (nonatomic) SystemSoundID	soundFileObject;
#endif

@property (nonatomic, readwrite, assign) BOOL isFramePreset;

- (void)loadGaugeView;
- (void)addGestures;

@end

@implementation TKGaugeViewController

@synthesize gaugeView;
@synthesize uuid, mainConfig, skinConfig, dataFilter, gaugePath, skinPath, conversion;
@synthesize isFramePreset;
@synthesize allowDrag, allowResizeOnPinch, warnOnDoubleTap, savePositionAndSize;

#ifdef __AudioToolbox_H
@synthesize soundFileObject = soundFileObject_;
#endif

- (id)init
{
	self = [super init];
    
	if (self) {
		// Custom initialization
        self.warnOnDoubleTap = YES;
	}
    
	return self;
}

- (void)dealloc
{
#ifdef __AudioToolbox_H
	// FIXME: strange release here!
	AudioServicesDisposeSystemSoundID(soundFileObject_);
	// CFRelease(soundFileURLRef_);
#endif
	//[super dealloc];
}

- (void)loadDefailtSkinConfig
{
	self.skinConfig = [self.mainConfig objectForKey:@"skin"];
	self.skinPath   = self.gaugePath;
}

- (void)presetQuickVars
{
	if (!self.mainConfig) {
		//NSLog(@"No Gauge Info !!!");
		return;
	}
    
	BOOL newSkinLoaded = NO;
    
	// self.dataFilter = [[[DataFilter alloc] init] autorelease];
	// [self.dataFilter setMaxAverageCount:5];
    
	self.conversion = [self.mainConfig valueForKeyPath:@"config.conversion"];
    
	// NSLog(@"conversion : %@", self.conversion);
    
	scaleMin = [[self.mainConfig valueForKeyPath:@"config.scaleMin"] floatValue];
	scaleMax = [[self.mainConfig valueForKeyPath:@"config.scaleMax"] floatValue];
    
	warnHigh  = [[self.mainConfig valueForKeyPath:@"config.warnHigh"] floatValue];
	warnLow   = [[self.mainConfig valueForKeyPath:@"config.warnLow"] floatValue];
	warnSound = [[self.mainConfig valueForKeyPath:@"config.warnSound"] boolValue];
    
	[self.dataFilter setMaxAverageCount:[[self.mainConfig valueForKeyPath:@"config.averageFilter"] intValue]];
    
	// Skin section
    
	if ([self.mainConfig valueForKeyPath:@"config.skinFile"]) {
		NSString     *skinFile      = [self.mainConfig valueForKeyPath:@"config.skinFile"];
		NSString     *newSkinPath   = [[self.gaugePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:skinFile];
		NSDictionary *tmpSkinConfig = [NSDictionary dictionaryWithContentsOfFile:[newSkinPath stringByAppendingPathComponent:@"Info.plist"]];
        
		if ([self.uuid isEqualToString:[tmpSkinConfig objectForKey:@"uuid"]]) {
			self.skinConfig = [tmpSkinConfig objectForKey:@"skin"];
            
			// TODO: make this more cool
			if (![self.skinPath isEqualToString:newSkinPath]) {
				self.skinPath = newSkinPath;
				newSkinLoaded = YES;
			}
		} else {
			[self loadDefailtSkinConfig];
			newSkinLoaded = YES;
		}
	} else {
		[self loadDefailtSkinConfig];
	}
    
    
    
	arrowAngleMin = [[self.skinConfig objectForKey:@"arrowAngleMin"] floatValue];
	arrowAngleMax = [[self.skinConfig objectForKey:@"arrowAngleMax"] floatValue];
    
	if (viewLoaded) {
		TKGaugeView *v = self.gaugeView;
		v.digitalLabel.hidden = ![[self.mainConfig valueForKeyPath:@"config.showDigitalLabel"] boolValue];
        
        v.dimentionLabel.hidden = ![[self.mainConfig valueForKeyPath:@"config.showDimentionLabel"] boolValue];
        
		if (newSkinLoaded) {
			v.skinPath = self.skinPath;
			v.skin     = self.skinConfig;
			[v reloadImages];
		}
	}
}


- (void)loadGaugeView
{
	if (!self.gaugePath) {
		NSLog(@"No Gauge gaugePath !!!");
		return;
	}
    
	self.mainConfig = [NSDictionary dictionaryWithContentsOfFile:[self.gaugePath stringByAppendingPathComponent:@"Info.plist"]];
    
	self.uuid = [self.mainConfig valueForKey:@"uuid"];
    
	if (!self.mainConfig) {
		//NSLog(@"No Gauge Info !!!");
		return;
	}
    
	self.dataFilter = [[TKSimpleDataFilter alloc] init];
	[self.dataFilter setMaxAverageCount:1]; // config.averageFilter
    
	[self presetQuickVars];
    
	CGRect frame;
	frame.origin = CGPointMake(50.0f, 50.0f);
	frame.size   = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ?
    CGSizeMake(200.0f, 200.0f) : CGSizeMake(400.0f, 400.0f);
    
	TKGaugeView *gv = [[TKGaugeView alloc] initWithFrame:frame];
	gv.skin     = self.skinConfig;
	gv.skinPath = self.skinPath;
	[gv reloadImages];
	self.gaugeView = gv;
    
	/*
     NSString *infoFile = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist" inDirectory:@"Gauges/boost"];
     NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoFile];
     NSDictionary *skin = [info objectForKey:@"skin"];
	 */
    
	TKGaugeView *v = self.gaugeView;
	v.digitalLabel.hidden = ![[self.mainConfig valueForKeyPath:@"config.showDigitalLabel"] boolValue];
    v.dimentionLabel.hidden = ![[self.mainConfig valueForKeyPath:@"config.showDimentionLabel"] boolValue];
    v.dimentionLabel.text = @"km/h";
    
	viewLoaded = YES;
    
    self.isFramePreset = NO;
    if ([self.mainConfig valueForKeyPath:@"config.frame"]) {
        self.gaugeView.frame = CGRectFromString([self.mainConfig valueForKeyPath:@"config.frame"]);
        self.isFramePreset = YES;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self loadGaugeView];
    [self.view addSubview:self.gaugeView];
    
    [self addGestures];
        
	// Setup sound
#ifdef __AudioToolbox_H
	NSString *alertPath = [self.gaugePath stringByAppendingPathComponent:@"alert.wav"];
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:alertPath])
	{
		NSURL *soundURL = [NSURL fileURLWithPath:alertPath];
        
		// Create a system sound object representing the sound file.
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundFileObject_);
		// AudioServicesPlayAlertSound(soundFileObject_);
	}
#endif
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)savePosition
{
    if (!self.savePositionAndSize) return;
    
    NSMutableDictionary *mutableInfo = [self.mainConfig mutableCopy];
    
    [mutableInfo setValue:NSStringFromCGRect(self.gaugeView.frame) forKeyPath:@"config.frame"];
    self.mainConfig = mutableInfo;
    
    // Saving settings to file
	[self.mainConfig writeToFile:[self.gaugePath stringByAppendingPathComponent:@"Info.plist"] atomically:YES];
}

#pragma mark - Gestures

- (void)addGestures {
    
    UIPinchGestureRecognizer *grPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.gaugeView addGestureRecognizer:grPinch];
    
    UIPanGestureRecognizer *grDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragGesture:)];
    [self.gaugeView addGestureRecognizer:grDrag];
    
	UITapGestureRecognizer *grDblTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
	grDblTap.numberOfTapsRequired = 2;
	[self.gaugeView addGestureRecognizer:grDblTap];

    
    UILongPressGestureRecognizer *grLP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
	grLP.minimumPressDuration = 1.0;
    [self.gaugeView addGestureRecognizer:grLP];
    
}


- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gr
{
    if (!self.allowResizeOnPinch) return;
    
	// Dirty Hack
	[self.gaugeView resetArrow];
	[self.gaugeView enableLayout];
    
    if (gr.state == UIGestureRecognizerStateBegan || gr.state == UIGestureRecognizerStateChanged) {
        
        // NSLog(@"pinch detected: %@", pgr);
        UIView *v  = self.gaugeView;
        
        [[v superview] bringSubviewToFront:v];
        
        CGRect b   = v.bounds;
        float  vel = 3 * gr.velocity;
        
        if (vel < 0) vel *= 2;
        
        b.size.height += vel;
        b.size.width  += vel;
        
        if (b.size.height < 60.0)
            b.size.height = b.size.width = 300.0;
        
        v.bounds = b;
        
        [self.gaugeView layoutSubviews];
        // Dirty Hack
        [self.gaugeView disableLayout];
        
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        [self savePosition];
    }
	
}

- (void)handleDragGesture:(UIPanGestureRecognizer *)gr
{
    if (!self.allowDrag) return;
    
    if (gr.state == UIGestureRecognizerStateBegan || gr.state == UIGestureRecognizerStateChanged) {
        UIView *view = gr.view;
        [[view superview] bringSubviewToFront:view];
        CGPoint translation = [gr translationInView:view.superview];
        [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
        [gr setTranslation:CGPointZero inView:view.superview];
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        [self savePosition];
    }
}

- (void)handleDoubleTapGesture:(UIPinchGestureRecognizer *)gr
{
    if (self.warnOnDoubleTap) [self warn];
}

- (void)handleLongPressGesture:(UIPinchGestureRecognizer *)gr
{
    
}

#pragma mark - Other methods

// TODO: Remove
- (void)randomRotate
{
	// Dirty Hack
	[self.gaugeView disableLayout];
    
	NSInteger aValue = rand();
    
	float deg = (270. / 255.) * aValue;
    
    
	self.gaugeView.arrow.transform = CGAffineTransformMakeRotation(DEGTORAD(deg));
	// self.gaugeView.bg.transform = CGAffineTransformMakeRotation(DEGTORAD(deg));
    
    
	// CATransform3D rotatedTransform = arrow.layer.transform;
	// rotatedTransform = CATransform3DMakeRotation(aValue * M_PI / 180.0, 0.0f, 0.0f, 1.0f);
	// arrow.layer.transform = rotatedTransform;
}

- (void)setValue:(float)aValue
{
	if (isWelcome) return;
    
	// Using filter
    
	float average = 0;
    
	if ([self.dataFilter maxAverageCount] > 1) {
		BOOL added = [self.dataFilter addToAverageStack:aValue orAverage:&average];
        
		if (added) return;
		else aValue = average;
	} else {
		average = aValue;
	}
    
	TKGaugeView *v = self.gaugeView;
    
	// Dirty Hack
	[v disableLayout];
    
    
	if ((aValue < scaleMin) || (aValue > scaleMax)) {
		// NSLog(@"badValue: %f", aValue);
		return;
	}
    
	if ((aValue < warnLow) || (aValue > warnHigh)) {
		[self warn];
	} else {
		// [self warn:NO];
	}
    
	float k      = (arrowAngleMax - arrowAngleMin) / (scaleMax - scaleMin);
	float offset = (0 - scaleMin) / (scaleMax - scaleMin) * (arrowAngleMax - arrowAngleMin);
	float deg    = k * aValue + offset;
    
	if ((deg < arrowAngleMin) || (deg > arrowAngleMax)) {
		NSLog(@"Bad deg for value: %f -> %f deg, k: %f, offset: %f", aValue, deg, k, offset);
		return;
	}
    
	if (!v.digitalLabel.hidden) v.digitalLabel.text = [NSString stringWithFormat:@"%.2f", aValue];
    
	// v.arrow.transform = CGAffineTransformMakeRotation(DEGTORAD(deg));
    
	[UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         v.arrow.transform = CGAffineTransformMakeRotation (DEGTORAD (deg));
                     }
                     completion:nil];
}

- (void)warn
{
#ifdef __AudioToolbox_H
	// AudioServicesPlayAlertSound(soundFileObject_);
	if (warnSound) AudioServicesPlaySystemSound(soundFileObject_);
#endif
    
	TKGaugeView *v = self.gaugeView;
    
	// v.warn.alpha = (alert) ? 1.0f : 0.0f;
    
	v.warn.alpha = 1.0f;
    
	[UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         v.warn.alpha = 0.0f;
                     }
                     completion:nil];
}

- (void)welcome
{
	isWelcome = YES;
    
	TKGaugeView *v = self.gaugeView;
    
    
	// v.arrow.transform = CGAffineTransformMakeRotation(DEGTORAD(arrowAngleMin));
    
	int   rotations = 1;
	float duration  = 0.5f;
    
    
	CABasicAnimation *rotationAnimation;
	rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
	rotationAnimation.toValue   = [NSNumber numberWithFloat:DEGTORAD(arrowAngleMax) * 2.0 /* full rotation*/ * rotations * duration ];
	rotationAnimation.fromValue = [NSNumber numberWithFloat:DEGTORAD(arrowAngleMin) * 2.0 /* full rotation*/ * rotations * duration ];
    
	rotationAnimation.duration       = duration;
	rotationAnimation.autoreverses   = YES;
	rotationAnimation.cumulative     = YES;
	rotationAnimation.repeatCount    = 1.0;
	rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	rotationAnimation.delegate       = self;
    
	[v.arrow.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	isWelcome = NO;
}

#pragma mark - Getters

- (float)minValue {
	return scaleMin;
}

- (float)maxValue {
	return scaleMax;
}


@end
