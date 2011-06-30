//
//  UtilFunctions.m
//  AnimationReplicator
//
//  Created by Ling Wang on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UtilFunctions.h"

CGRect rectForPoint(CGPoint point) {
	return CGRectMake(point.x - 1.f, point.y - 1.f, 2.f, 2.f);
}

void WLCGPathApplierFunc (void *info, const CGPathElement *element) {
	CGMutablePathRef debugPath = (CGMutablePathRef)info;
	
	switch (element->type) {
		case kCGPathElementMoveToPoint:
			CGPathAddEllipseInRect(debugPath, NULL, rectForPoint(element->points[0]));
			NSLog(@"MoveToPoint: %@", NSStringFromCGPoint(element->points[0]));
			break;
			
		case kCGPathElementAddLineToPoint:
			CGPathAddEllipseInRect(debugPath, NULL, rectForPoint(element->points[0]));
			NSLog(@"AddLineToPoint: %@", NSStringFromCGPoint(element->points[0]));
			break;
			
		case kCGPathElementAddQuadCurveToPoint:
			CGPathAddEllipseInRect(debugPath, NULL, rectForPoint(element->points[0]));
			CGPathAddEllipseInRect(debugPath, NULL, rectForPoint(element->points[1]));
			NSLog(@"AddQuadCurveToPoint: %@, %@", NSStringFromCGPoint(element->points[0]), NSStringFromCGPoint(element->points[1]));
			break;
			
		case kCGPathElementAddCurveToPoint:
			CGPathAddEllipseInRect(debugPath, NULL, rectForPoint(element->points[0]));
			CGPathAddEllipseInRect(debugPath, NULL, rectForPoint(element->points[1]));
			CGPathAddEllipseInRect(debugPath, NULL, rectForPoint(element->points[2]));
			NSLog(@"AddCurveToPoint: %@, %@, %@", NSStringFromCGPoint(element->points[0]), NSStringFromCGPoint(element->points[1]),  NSStringFromCGPoint(element->points[2]));
			break;
			
		case kCGPathElementCloseSubpath:
			break;
			
		default:
			break;
	}
};
