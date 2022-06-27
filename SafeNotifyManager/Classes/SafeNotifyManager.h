//
//  SafeNotifyManager.h
//  Pods-SafeNotifyManager_Example
//
//  Created by keping on 2022/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define safeMgr [SafeNotifyManager sharedManager]

@protocol SafeNotifyCallback <NSObject>

/// 通知回调
/// @param key 回调事件标识
/// @param info 回调数据
-(void)notifyCallbackWithKey:(id<NSCopying>)key userInfo:(nullable NSDictionary *)info;

@end

@interface SafeNotifyManager : NSObject

+(instancetype)sharedManager;

/// 给对象添加观察事件
/// @param object 观察的对象
/// @param key 事件标识
-(void)addObserveForObject:(id)object withKey:(id<NSCopying>)key;

/// 移除对象指定事件的观察
/// @param object 观察的对象
/// @param key 移除的事件标识
-(void)removeObserveForObject:(id)object withKey:(id<NSCopying>)key;

/// 移除对象所有的观察事件
-(void)removeAllObserveForObject:(id)object;

/// 通知观察的对象
/// @param key 事件标识
/// @param userInfo 需要通知的数据
-(void)postNotifyToObserverWithKey:(id<NSCopying>)key userInfo:(nullable NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
