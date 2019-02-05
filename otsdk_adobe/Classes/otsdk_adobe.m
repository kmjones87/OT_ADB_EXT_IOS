    //
//  otsdk_adobe.m
//  SE Custom Demo App
//
//  Created by Justin Devenish on 1/22/19.
//  Copyright © 2019 OneTrust. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////
//
//  Changing consent status for testing. In production, this extension
//  should NEVER set the this value.
//
//  #import <ACPCore_iOS/ACPCore_iOS.h>
//  [ACPCore setPrivacyStatus:ACPMobilePrivacyStatusOptOut];
//  [ACPCore setPrivacyStatus:ACPMobilePrivacyStatusOptIn];
//  [ACPCore setPrivacyStatus:ACPMobilePrivacyStatusUnknown];
//
///////////////////////////////////////////////////////////////////////////

/*
 * TO-DO:
 *
 *
 */

#import "otsdk_adobe.h"
#import "otsdk_adobe_listener.h"

@interface otsdk_adobe () <NSURLSessionDelegate>

@end

@implementation otsdk_adobe

/**
 * Return extension name
 */
- (nullable NSString*) name {
    return @"com.OneTrust.OTSDK_Adobe";
}

/**
 * Return extension version
 */
- (nullable NSString*) version {
    return @"1.0.1";
}

/**
 * Initializes the OneTrust extension and registers listener
 */
- (instancetype) init {
    if (self = [super init]) {
        NSError *error = nil;
        
        
        // Listener definition - triggers when changes to the event hub occur
        if ([self.api registerListener: [otsdk_adobe_listener class]
                             eventType:@"com.adobe.eventType.hub"
                           eventSource:@"com.adobe.eventSource.sharedState"
                                 error:&error]) {
            NSLog(@"MyExtensionListener successfully registered for Hub Shared State events");
        } else if (error) {
            NSLog(@"An error occured while registering MyExtensionListener: %ld", [error code]);
        }
    }
    return self;
}

/**
 * Conducts cleanup when extension had been unregistered
 */
- (void) onUnregister {
    [super onUnregister];
    // your cleanup code goes here
}


/**
 * Handles action from an event
 */

- (void) handleEvent: (ACPExtensionEvent*) event {
    NSError* error = nil;
    NSDictionary* configurationSharedState = [self.api getSharedEventState:@"com.adobe.module.configuration" event:event error:&error];
    _serverData = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverData"];
    if(_serverData){ // Handle Returning Users
        // Check if value of global.privacy has changed from previous value
        if([[_serverData valueForKey:@"global.privacy"] isEqualToString:[configurationSharedState valueForKey:@"global.privacy"]]){
            //NSLog(@"[OT-ADOBE] Equal Server Data: %@",[_serverData valueForKey:@"global.privacy"]);
            //NSLog(@"[OT-ADOBE] Eaual Live Data: %@",[configurationSharedState valueForKey:@"global.privacy"]);
            return;
        } else {
            //NSLog(@"[OT-ADOBE] Diff Server Data: %@",[_serverData valueForKey:@"global.privacy"]);
            //NSLog(@"[OT-ADOBE] Diff Live Data: %@",[configurationSharedState valueForKey:@"global.privacy"]);
            //NSLog(@"[OT-ADOBE] Saving Consent for existing user");
            [self uploadToOneTrustServer: configurationSharedState];
            _serverData = [NSMutableDictionary dictionaryWithDictionary:configurationSharedState];
            [[NSUserDefaults standardUserDefaults] setObject:_serverData forKey:@"serverData"];
        }
    } else{ // Handle New Users
        //NSLog(@"[OT-ADOBE] Saving Consent for new user");
        _serverData = [NSMutableDictionary dictionaryWithDictionary:configurationSharedState];
        [[NSUserDefaults standardUserDefaults] setObject:_serverData forKey:@"serverData"];
        [self uploadToOneTrustServer: configurationSharedState];
    }
    
}


/**
 * Logs additional information when unexpected error occurs
 */
// The default implementation of "unexpectedError" will log error message using NSLog
- (void) unexpectedError:(NSError *)error {
    //[super unexpectedError];
    // your error handling code goes here
}

/**
 * Send value of global.privacy to OneTrust for consent logging
 */
- (void) uploadToOneTrustServer: (NSDictionary*) privacySetting{
    // Check for and existing GUID when user has selected RandomGUID as the identifier type
    if(![[NSUserDefaults standardUserDefaults].dictionaryRepresentation.allKeys containsObject:@"RandomGUID"]){
        // If identifier doesn't exist, create it
        [[NSUserDefaults standardUserDefaults] setValue:[[NSUUID UUID] UUIDString] forKey:@"RandomGUID"];
    }
    
    // Retrieve Adobe configureation information
    NSDictionary* OneTrustKeys = [privacySetting valueForKeyPath:@"collectionPointKeys"];
    
    // Retrieve data needed to send consent to OneTrust
    NSString* CP_Endpoint = [OneTrustKeys valueForKey:@"Endpoint"];
    NSString* CP_APIToken = [OneTrustKeys valueForKey:@"Token"];
    NSString* CP_PurposeID = [OneTrustKeys valueForKey:@"PurposeId"];
    NSString* CP_IdentifierType = [OneTrustKeys valueForKey:@"DataSubjectIDType"];
    
    // Check for Identifier Type and retireve the appropriate Data Subject ID
    NSString* IdentifierValue = @"";
    if([CP_IdentifierType isEqualToString:@"Random GUID"]){
        IdentifierValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"RandomGUID"];
    } else if ([CP_IdentifierType isEqualToString:@"Supply Own"]){
        // Retrieve custom identifier from disk. Defined when initializing SDK
        IdentifierValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"SupplyOwn"];
    }
    
    
    // Define endpoint
    NSString *strURL = CP_Endpoint;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    // Define call method
    [request setHTTPMethod:@"POST"];
    
    
    // Define headers
    NSDictionary *headers = @{ @"Content-Type": @"application/json",
                               @"cache-control": @"no-cache" };
    [request setAllHTTPHeaderFields:headers];
    
    
    
    // Build request body
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    payload[@"identifier"] = IdentifierValue;
    payload[@"requestInformation"] = CP_APIToken;
    payload[@"test"] = [NSNumber numberWithBool:false];
    payload[@"purposes"] = @[@{@"Id": CP_PurposeID}];
    payload[@"customPayload"] = @{@"Adobe Launch Privacy Setting":[privacySetting valueForKeyPath:@"global.privacy"]};
    
    // Ready my JSON dictionary
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&err];
    if (err) {
        NSLog(@"error jsonData: %@", err);
        return;
    }
    
    // Set the request body
    [request setHTTPBody:jsonData];
    
    // Send request
    NSURLSessionDownloadTask *task = [self.backgroundSession downloadTaskWithRequest:request];
    if (task) {
        NSString* payloadKey = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:privacySetting forKey:payloadKey];
        [task setTaskDescription:[NSString stringWithFormat:@"uploadToOneTrustServer:%@", payloadKey]];
        [task resume];
    }
}

#pragma mark - Retry Logic
- (NSURLSession *)backgroundSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceTokenBackgroundSession;
    dispatch_once(&onceTokenBackgroundSession, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.OneTrust_Adobe.BackgroundSession"];
        configuration.HTTPMaximumConnectionsPerHost = 2;
        configuration.allowsCellularAccess = YES;
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    
    return session;
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    if (downloadTask.taskDescription) {
        if ([downloadTask.taskDescription hasPrefix:@"uploadToOneTrustServer:"]) {
            NSArray *parts = [[downloadTask taskDescription] componentsSeparatedByString:@":"];
            NSString *payloadKey = [parts objectAtIndex:1];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:payloadKey];
            // clear the retry
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"OT_retryCounter"];
            NSLog(@"[OT-ADOBE] Successfully saved to OneTrust");
        }
    }
}

-(NSString *)validatePath:(NSString *)proposedPath{
    return proposedPath;
}

-(NSURL *)validateURL:(NSURL *)proposedURL{
    return proposedURL;
}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error != nil) {
        if (task.taskDescription) {
            if ([task.taskDescription hasPrefix:@"uploadToOneTrustServer:"]) {
                NSArray *parts = [[task taskDescription] componentsSeparatedByString:@":"];
                NSString *payloadKey = [parts objectAtIndex:1];
                NSDictionary *payload = [[NSUserDefaults standardUserDefaults] objectForKey:payloadKey];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSInteger OT_retryCounter = [[NSUserDefaults standardUserDefaults] integerForKey:@"OT_retryCounter"]+1;
                    [[NSUserDefaults standardUserDefaults] setInteger:OT_retryCounter forKey:@"OT_retryCounter"];
                    if(OT_retryCounter <= 3){
                        [self uploadToOneTrustServer:payload];
                    }
                });
            }
        }
    }
}


@end
