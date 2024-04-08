#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(LocalSearchManager, RCTEventEmitter)
RCT_EXTERN_METHOD(searchLocationsAutocomplete:(NSString *)text)
RCT_EXTERN_METHOD(searchLocations:(NSString *)query near:(NSDictionary *)near resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(searchPointsOfInterest:(NSDictionary *)near resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
@end


