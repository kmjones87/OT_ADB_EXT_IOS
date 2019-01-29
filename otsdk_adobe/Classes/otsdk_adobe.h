//
//  otsdk_adobe.h
//  SE Custom Demo App
//
//  Created by Justin Devenish on 1/22/19.
//  Copyright © 2019 OneTrust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ACPCore/ACPCore.h>
#import <ACPCore/ACPExtension.h>


NS_ASSUME_NONNULL_BEGIN

@interface otsdk_adobe : ACPExtension

@property (nonatomic, strong, readonly) NSMutableDictionary *serverData;

/**
 * Return extension name
 */     
- (nullable NSString*) name;

/**
 * Return extension version
 */
- (nullable NSString*) version;

/**
 * Logs additional information when unexpected error occurs
 */
- (void) unexpectedError: (nonnull NSError*) error;

/**
 * Conducts cleanup when extension had been unregistered
 */
- (void) onUnregister;

/**
 * Allows OneTrust's extension to communicate with Adobe's Event Hub
 */
- (void) api: (nonnull NSError*) error;

/**
 * Handles action from an event
 */
- (void) handleEvent: (ACPExtensionEvent*) event;

@end

NS_ASSUME_NONNULL_END
