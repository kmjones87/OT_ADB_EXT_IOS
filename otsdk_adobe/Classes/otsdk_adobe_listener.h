//
//  otsdk_adobe_listener.h
//  SE Custom Demo App
//
//  Created by Justin Devenish on 1/22/19.
//  Copyright © 2019 OneTrust. All rights reserved.
//


#import <ACPCore/ACPExtensionListener.h>
#import <ACPCore/ACPCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface otsdk_adobe_listener : ACPExtensionListener

/**
 * Handles logic for listener events
 */
- (void) hear:(ACPExtensionEvent *)event;


- (nullable NSString*) extension;

@end

NS_ASSUME_NONNULL_END
