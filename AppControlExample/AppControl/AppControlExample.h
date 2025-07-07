//
//  STTExample.hpp
//  SwitchboardWhisperSampleApp
//
//  Created by Balazs Kiss on 2025. 03. 27..
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ControlDelegate

- (void)triggerDetected:(NSInteger)triggerType withKeyword:(NSString*)keyword;

@end

@interface AppControlExample : NSObject

@property (nonatomic, weak) id<ControlDelegate> delegate;

- (void)createEngine;
- (void)startEngine;
- (void)stopEngine;
- (void)setRuntimeTriggers:(NSArray<NSString*>*)triggers;

@end

NS_ASSUME_NONNULL_END
