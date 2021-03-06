#import "FlutterSiriSuggestionsPlugin.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <Intents/Intents.h>
@import CoreSpotlight;
@import MobileCoreServices;


@implementation FlutterSiriSuggestionsPlugin {
    FlutterMethodChannel *_channel;
}

NSString *kPluginName = @"flutter_siri_suggestions";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:kPluginName
                                     binaryMessenger:[registrar messenger]];
    FlutterSiriSuggestionsPlugin* instance = [[FlutterSiriSuggestionsPlugin alloc] initWithChannel:channel];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if([@"becomeCurrent" isEqualToString:call.method]) {
        return [self becomeCurrent:call result:result];
    } else if ([@"deleteAllSavedUserActivities" isEqualToString:call.method]) {
        return [self deleteAllSavedUserActivities:call result:result];
    } else if ([@"deleteByPersistentIdentifier" isEqualToString:call.method]) {
        return [self deleteByPersistentIdentifier:call result:result];
    }
    result(FlutterMethodNotImplemented);
}

- (void)deleteByPersistentIdentifier:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSArray *persistentIdentifier = call.arguments;
    if (@available(iOS 12.0, *)) {
        [NSUserActivity deleteSavedUserActivitiesWithPersistentIdentifiers:persistentIdentifier completionHandler:^{
            result(nil);
        }];
    } else {
        result(nil);
    }
}

- (void)deleteAllSavedUserActivities:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (@available(iOS 12.0, *)) {
        [NSUserActivity deleteAllSavedUserActivitiesWithCompletionHandler:^{
            result(nil);
        }];
    } else {
        result(nil);
    }
}

- (void)becomeCurrent:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    
    NSAssert( ([arguments objectForKey:@"key"] != nil), @"key must not nil!");
    
    NSString *title = [arguments objectForKey:@"title"];
    NSString *key = [arguments objectForKey:@"key"];
    NSDictionary *userInfo = [arguments objectForKey:@"userInfo"];
    NSNumber *isEligibleForSearch = [arguments objectForKey:@"isEligibleForSearch"];
    NSNumber *isEligibleForPrediction = [arguments objectForKey:@"isEligibleForPrediction"];
    NSString *contentDescription = [arguments objectForKey:@"contentDescription"];
    NSString *suggestedInvocationPhrase = [arguments objectForKey:@"suggestedInvocationPhrase"];
    NSString *persistentIdentifier = [arguments objectForKey:@"persistentIdentifier"];

    if (@available(iOS 9.0, *)) {
        NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:[NSString stringWithFormat:@"%@.%@", key, kPluginName]];
        
        [activity setEligibleForSearch:[isEligibleForSearch boolValue]];

        if (@available(iOS 12.0, *)) {
            [activity setEligibleForPrediction:[isEligibleForPrediction boolValue]];
        }

        CSSearchableItemAttributeSet *attributes = [[CSSearchableItemAttributeSet alloc] initWithItemContentType: (NSString *)kUTTypeItem];

        activity.title = title;
        attributes.contentDescription = contentDescription;
        activity.userInfo = userInfo;
        activity.contentAttributeSet = attributes;

        if (@available(iOS 12.0, *)) {
            activity.persistentIdentifier = persistentIdentifier;
            // SIMULATOR HAS NOT RESPOND SELECTOR
            #if !(TARGET_IPHONE_SIMULATOR)
            activity.suggestedInvocationPhrase = suggestedInvocationPhrase;
            #endif
        }

        [[self rootViewController] setUserActivity:activity];
        
        [activity becomeCurrent];
        
        result(key);
        return;

    }
    result(nil);
}

- (void)onAwake:(NSUserActivity*) userActivity {
    if (@available(iOS 9.0, *)) {
        [userActivity resignCurrent];
        [userActivity invalidate];
    }
    [_channel invokeMethod:@"onLaunch" arguments:@{@"title": userActivity.title, @"key" : [userActivity.activityType stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@-", kPluginName] withString:@""], @"userInfo" : userActivity.userInfo}];
}

#pragma mark -

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel {
    self = [super init];
    if(self) {
        _channel = channel;
    }
    return self;
}

- (UIViewController*)rootViewController {
    return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

#pragma mark - Application


- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    return true;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    if ([[userActivity activityType] hasSuffix:kPluginName]) {
        [self onAwake:userActivity];
        return true;
    }
    return false;
}



@end
