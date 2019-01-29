//
//  otsdk_adobe_listener.m
//  SE Custom Demo App
//
//  Created by Justin Devenish on 1/22/19.
//  Copyright © 2019 OneTrust. All rights reserved.
//

#import "otsdk_adobe_listener.h"
#import "otsdk_adobe.h"

@interface otsdk_adobe_listener ()

@end

@implementation otsdk_adobe_listener

/**
 * Handles logic for listener events
 */
- (void) hear:(ACPExtensionEvent *)event {
    NSError* error = nil;
    otsdk_adobe* parentExtension = [self getParentExtension];
    NSDictionary* eventDataDict = event.eventData;
    NSString* stateowner = [eventDataDict objectForKey:@"stateowner"];
    
    // Confirm event is from the configuration module. Ignore event otherwise
    if (stateowner && [stateowner isEqualToString:@"com.adobe.module.configuration"]) {
        NSDictionary* configurationSharedState = [[[self getParentExtension] api] getSharedEventState:@"com.adobe.module.configuration" event:event error:&error];
        
        // Only handle event if the shared configuration state is not NULL
        if (configurationSharedState){
            
            // Used for testing and debugging
            //NSString* privacySetting = [configurationSharedState valueForKey:@"global.privacy"];
            //NSDictionary* OneTrustKeys = [configurationSharedState valueForKeyPath:@"collectionPointKeys"];
            //NSLog(@"[OT-ADOBE] configuration:");
            //NSLog(@"[OT-ADOBE] API Endpoint: %@",[OneTrustKeys valueForKey:@"Endpoint"]);
            //NSLog(@"[OT-ADOBE] API Token: %@",[OneTrustKeys valueForKey:@"Token"]);
            //NSLog(@"[OT-ADOBE] Purpose ID: %@", [OneTrustKeys valueForKey:@"PurposeId"]);
            //NSLog(@"[OT-ADOBE] Global Privacy: %@", privacySetting);
            
            [parentExtension handleEvent:event];
        }
    }
}

/**
 * Returns the parent extension that owns this listener
 */
- (otsdk_adobe*) getParentExtension {
    otsdk_adobe* parentExtension = nil;
    
    if ([[self extension] isKindOfClass:otsdk_adobe.class]) {
        parentExtension = (otsdk_adobe*) [self extension];
    }
    
    return parentExtension;
}


@end
