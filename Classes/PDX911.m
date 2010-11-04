//
//  PDX911.m
//  BezierGarden
//
//  Created by P. Mark Anderson on 11/3/10.
//  Copyright 2010 Bordertown Labs, LLC. All rights reserved.
//

#import "PDX911.h"
#import "SM3DAR.h"

@implementation PDX911

- (void) parseIncidents
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pdx911a.kml" ofType:nil];            
    NSError *error = nil;
    NSLog(@"[PDX911] Loading incidents from %@", filePath);

    // grab the example KML file (which we know will have no errors, but you should ordinarily check)
    //
    SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:filePath error:&error];
    
    if (error)
    {
        NSLog(@"[PDX911] ERROR parsing data: ", [error localizedDescription]);
    }
    else
    {        
        SM3DAR_Controller *sm3dar = [SM3DAR_Controller sharedController];
        NSMutableArray *allPoints = [NSMutableArray arrayWithCapacity:100];
        
        
        if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]])
        {
            NSLog(@"\n\nKML has feature\n\n");

            
            for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features)
            {
                
                
                if ([feature isKindOfClass:[SimpleKMLPlacemark class]] && ((SimpleKMLPlacemark *)feature).point)
                {
                    SimpleKMLPoint *point = ((SimpleKMLPlacemark *)feature).point;
                    
                    NSLog(@"point: %@, %.3f, %.3f", feature.name, point.coordinate.latitude, point.coordinate.longitude);
                    

                    SM3DAR_Point *poi = [sm3dar initPointOfInterestWithLatitude:point.coordinate.latitude 
                                                                        longitude:point.coordinate.longitude 
                                                                         altitude:0 
                                                                            title:feature.name 
                                                                         subtitle:nil
                                                                  markerViewClass:[SM3DAR_IconMarkerView class] 
                                                                       properties:nil];
                    
                    [allPoints addObject:poi];
                    [poi release];
                }
            }
            
        }

        [sm3dar addPointsOfInterest:allPoints];
        
        
        
    }
    
}


@end
