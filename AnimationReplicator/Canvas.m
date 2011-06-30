//
//  Canvas.m
//  AnimationReplicator
//
//  Created by Ling Wang on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Canvas.h"
#import "UtilFunctions.h"
#import <QuartzCore/QuartzCore.h>



@interface Canvas () <UIGestureRecognizerDelegate> {
@private
	CAShapeLayer *hose;
	CAShapeLayer *nozzle;
	CALayer *handle;
	CAReplicatorLayer *water;
	CALayer *droplet;
	CGPoint hoseRoot;
}

- (void)adjustHoseFollowingNozzle;

@end




@implementation Canvas

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super initWithCoder:decoder];
    if (self) {
		// Hose.
		hoseRoot = CGPointMake(20, CGRectGetMaxY(self.bounds) - 60);
		CGRect hoseBounds = CGRectMake(0, 0, 120, 40);
		hose = [[CAShapeLayer alloc] init];
		hose.lineWidth = 16;
		hose.lineCap = kCALineCapRound;
		hose.strokeColor = [UIColor greenColor].CGColor;
		hose.fillColor = [UIColor clearColor].CGColor;
		hose.bounds = hoseBounds;
		hose.position = CGPointMake(CGRectGetMidX(hoseBounds) + 20, CGRectGetMaxY(self.bounds) - CGRectGetMidY(hoseBounds) - 20);
		[self.layer addSublayer:hose];
		
		// Nozzle.
		CGRect nozzleBounds = CGRectMake(0, 0, 40, 16);
		nozzle = [[CAShapeLayer alloc] init];
		CGMutablePathRef nozzlePath = CGPathCreateMutable();
		CGPathMoveToPoint(nozzlePath, NULL, CGRectGetMinX(nozzleBounds), CGRectGetMinY(nozzleBounds));
		CGPathAddLineToPoint(nozzlePath, NULL, CGRectGetMaxX(nozzleBounds), CGRectGetMidY(nozzleBounds));
		CGPathAddLineToPoint(nozzlePath, NULL, CGRectGetMinX(nozzleBounds), CGRectGetMaxY(nozzleBounds));		
		nozzle.path = nozzlePath;
		CGPathRelease(nozzlePath);
		nozzle.fillColor = [UIColor grayColor].CGColor;
		nozzle.bounds = nozzleBounds;
		nozzle.position = CGPointMake(CGRectGetMaxX(hose.frame) + 20, CGRectGetMaxY(hose.frame));
		[self.layer addSublayer:nozzle];
		
		[self adjustHoseFollowingNozzle];
		
		// Handle
		handle = [[CALayer alloc] init];
		UIImage *handleImage = [UIImage imageNamed:@"handle"];
		handle.contents = objc_unretainedObject(handleImage.CGImage);
		handle.bounds = (CGRect){{0, 0}, {handleImage.size.width * 0.8, handleImage.size.height * 0.8}};
		handle.anchorPoint = CGPointMake(0.5, 1);
		handle.transform = CATransform3DMakeRotation(-M_PI/3, 0, 0, 1);
		handle.position = CGPointMake(8, 8);
		[nozzle addSublayer:handle];
		
		// Water
		water = [[CAReplicatorLayer alloc] init];
		droplet = [[CALayer alloc] init];
		droplet.contents = objc_unretainedObject([UIImage imageNamed:@"droplet"].CGImage);
		droplet.bounds = (CGRect){0, 0, 10, 10};
		droplet.position = (CGPoint){5, 5};
		droplet.opacity = 0;
		[water addSublayer:droplet];
		water.instanceCount = 18;
		CATransform3D t = CATransform3DMakeTranslation(7, 0, 0);
		t = CATransform3DScale(t, 1.02, 1.02, 1.02);
		water.instanceTransform = t;
		water.bounds = droplet.bounds;
		water.anchorPoint = (CGPoint){0, 0.5};
		water.position = (CGPoint){CGRectGetMaxX(nozzleBounds), CGRectGetMidY(nozzleBounds)};
		[nozzle addSublayer:water];
		
		// Drag gesture recognizer.
		UIPanGestureRecognizer *dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(nozzleIsDragged:)];
		dragRecognizer.delegate = self;
		[self addGestureRecognizer:dragRecognizer];		
    }
    return self;
}

- (void)adjustHoseFollowingNozzle {
	CGPoint hoseTip = CGPointMake(CGRectGetMinX(nozzle.frame), CGRectGetMidY(nozzle.frame));
	CGRect hoseFrame = CGRectMake(hoseRoot.x, hoseRoot.y, hoseTip.x - hoseRoot.x, hoseTip.y - hoseRoot.y);
	hose.frame = hoseFrame;
	
	CGMutablePathRef hosePath = CGPathCreateMutable();
	CGPoint hoseRootInHoseLayer = [hose convertPoint:hoseRoot fromLayer:self.layer];
	CGPoint hoseTipInHoseLayer = [hose convertPoint:hoseTip fromLayer:self.layer];
	CGPathMoveToPoint(hosePath, NULL, hoseRootInHoseLayer.x, hoseRootInHoseLayer.y);
	CGPathAddCurveToPoint(hosePath, NULL, (hoseTipInHoseLayer.x + hoseRootInHoseLayer.x) / 2 + copysignf(10, hoseTipInHoseLayer.x - hoseRootInHoseLayer.x), hoseRootInHoseLayer.y, (hoseTipInHoseLayer.x + hoseRootInHoseLayer.x) / 2 - copysignf(10, hoseTipInHoseLayer.x - hoseRootInHoseLayer.x), hoseTipInHoseLayer.y, hoseTipInHoseLayer.x, hoseTipInHoseLayer.y);
	// Debug
	//	CGMutablePathRef debugPath = CGPathCreateMutable();
	//	CGPathApply(hosePath, debugPath, WLCGPathApplierFunc);
	//	CGPathAddPath(hosePath, NULL, debugPath);
	//	CGPathRelease(debugPath);
	
	hose.path = hosePath;
	CGPathRelease(hosePath);

}


#pragma mark - Gesture handling

- (void)nozzleIsDragged:(UIPanGestureRecognizer *)recognizer {
	[CATransaction setDisableActions:YES];
	nozzle.position = [recognizer locationInView:self];
	[self adjustHoseFollowingNozzle];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		if ([nozzle hitTest:[touch locationInView:self]] == nil) {
			[CATransaction setDisableActions:YES];
			water.instanceDelay = 0.05;
			[CATransaction setDisableActions:NO];
			
			handle.transform = CATransform3DMakeRotation(-M_PI/2, 0, 0, 1);
			
			CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
			opacityAnim.fromValue = [NSNumber numberWithFloat:0.8];
			opacityAnim.toValue = [NSNumber numberWithFloat:0.3];
			opacityAnim.duration = 1;
			opacityAnim.autoreverses = YES;
			opacityAnim.repeatCount = MAXFLOAT;
			opacityAnim.removedOnCompletion = NO;
			opacityAnim.fillMode = kCAFillModeForwards;
			[droplet addAnimation:opacityAnim forKey:@"opacity"];			
		}
	}
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([touches count] == 1) {
		[CATransaction setDisableActions:YES];
		water.instanceDelay = -0.05;
		[CATransaction setDisableActions:NO];
		
		handle.transform = CATransform3DMakeRotation(-M_PI/3, 0, 0, 1);

		CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		CGFloat fromValue = ((CALayer *)droplet.presentationLayer).opacity;
		opacityAnim.fromValue = [NSNumber numberWithFloat:fromValue];
		opacityAnim.toValue = [NSNumber numberWithFloat:0];
		opacityAnim.duration = 1;
		opacityAnim.removedOnCompletion = NO;
		opacityAnim.fillMode = kCAFillModeForwards;
		[droplet addAnimation:opacityAnim forKey:@"opacity"];
	}
	[super touchesEnded:touches withEvent:event];
}

# pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return [nozzle hitTest:[touch locationInView:self]] != nil;
}

@end
