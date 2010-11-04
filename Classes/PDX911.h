//
//  PDX911.h
//  BezierGarden
//
//  Created by P. Mark Anderson on 11/3/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//
// TODO: pull data from http://www.portlandonline.com/scripts/911incidents-kml_link.cfm
//


#import <Foundation/Foundation.h>

#import "SimpleKML.h"
#import "SimpleKMLContainer.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLFeature.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPoint.h"
#import "SimpleKMLPolygon.h"
#import "SimpleKMLLinearRing.h"

@interface PDX911 : NSObject 
{

}

- (void) parseIncidents;

@end
