//
//  XTXHViewController.m
//  SafeNotifyManager
//
//  Created by v_keping on 06/24/2022.
//  Copyright (c) 2022 v_keping. All rights reserved.
//

#import "XTXHViewController.h"
#import <SafeNotifyManager/SafeNotifyManager.h>

typedef enum : NSUInteger {
  SystemMessage,
  PlatformNotify,
  UserActivity,
} ObserverExampleKeys;

@interface XTXHViewController () <SafeNotifyCallback>

@end

@implementation XTXHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  NSLog(@"XTXHViewController viewDidLoad");
  
  //使用NSHashTable弱引用策略`NSPointerFunctionsWeakMemory`，并不会强引用当前self
  [safeMgr addObserveForObject:self withKey:@(SystemMessage)];
  [safeMgr addObserveForObject:self withKey:@(PlatformNotify)];
  [safeMgr addObserveForObject:self withKey:@(UserActivity)];
  [safeMgr addObserveForObject:self withKey:@"test"];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  NSLog(@"XTXHViewController viewWillAppear");
  [safeMgr postNotifyToObserverWithKey:@(SystemMessage) userInfo:@{@"msg": @"System Message"}];
  [safeMgr postNotifyToObserverWithKey:@(PlatformNotify) userInfo:@{@"msg": @"Platform Notify"}];
  [safeMgr postNotifyToObserverWithKey:@(UserActivity) userInfo:@{@"msg": @"User Activity"}];
  [safeMgr postNotifyToObserverWithKey:@"test" userInfo:@{@"msg": @"test"}];
  
}

-(void)notifyCallbackWithKey:(id<NSCopying>)key userInfo:(NSDictionary *)info {
  NSLog(@"%@ - %@", key, info);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
  NSLog(@"XTXHViewController dealloc");
  //[safeMgr removeAllObserveForObject:self];//即使不调用也不会强引用self
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  
  [self.navigationController pushViewController:[XTXHViewController new] animated:YES];
}

@end
