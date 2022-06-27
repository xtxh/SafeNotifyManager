//
//  SafeNotifyManager.m
//  Pods-SafeNotifyManager_Example
//
//  Created by keping on 2022/6/24.
//

#import "SafeNotifyManager.h"
#import <pthread.h>

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

static NSMapTable * _cache;
static pthread_mutex_t _lock;

static void _initializedValues() {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _cache = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    pthread_mutex_init(&_lock, NULL);
  });
}

@implementation SafeNotifyManager

+(instancetype)sharedManager {
  static SafeNotifyManager *_mgr = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _mgr = [[SafeNotifyManager alloc] init];
  });
  return _mgr;
}

-(void)addObserveForObject:(id)object withKey:(id<NSCopying>)key {
  if (!_cache) _initializedValues();
  
  NSArray *keys = NSAllMapTableKeys(_cache);
  NSHashTable *observers = nil;
  if ([keys containsObject:key]) {
    Lock();
    observers = (__bridge NSHashTable *)(NSMapGet(_cache, (__bridge const void * _Nullable)(key)));
    Unlock();
  }
  
  if (!observers) {
    observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:0];
    Lock();
    NSMapInsertIfAbsent(_cache, (__bridge const void * _Nullable)(key), (__bridge const void * _Nullable)(observers));
    Unlock();
  }
  
  if ([observers containsObject:object]) return;
  
  Lock();
  NSHashInsertIfAbsent(observers, (__bridge const void * _Nullable)(object));
  Unlock();
}

-(void)removeObserveForObject:(id)object withKey:(id<NSCopying>)key {
  if (!_cache) return;
  
  Lock();
  NSHashTable *observers = (__bridge NSHashTable *)(NSMapGet(_cache, (__bridge const void * _Nullable)(key)));
  Unlock();
  
  if (!observers) return;
  if ([observers containsObject:object]) {
    Lock();
    NSHashRemove(observers, (__bridge const void * _Nullable)(object));
    Unlock();
  }
}

-(void)removeAllObserveForObject:(id)object {
  if (!_cache) return;
  
  Lock();
  NSArray *keys = NSAllMapTableKeys(_cache);
  Unlock();
  
  for (id key in keys) {
    [self removeObserveForObject:object withKey:key];
  }
}

-(void)postNotifyToObserverWithKey:(id<NSCopying>)key userInfo:(NSDictionary *)userInfo {
  if (!_cache) return;
  
  Lock();
  NSHashTable *observers = (__bridge NSHashTable *)(NSMapGet(_cache, (__bridge const void * _Nullable)(key)));
  Unlock();
  
  if (!observers) return;
  
  for (id observer in observers) {
    if ([observer conformsToProtocol:@protocol(SafeNotifyCallback)]) {
      [observer notifyCallbackWithKey:key userInfo:userInfo];
    }
  }
}

-(void)dealloc {
  pthread_mutex_destroy(&_lock);
  NSFreeMapTable(_cache);
}

@end
