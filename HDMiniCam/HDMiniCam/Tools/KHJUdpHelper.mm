//
//  KHJUdpHelper.h
//  HDMiniCam
//
//  Created by 王涛 on 2020/1/12.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJUdpHelper.h"
#import <CocoaAsyncSocket/AsyncUdpSocket.h>
#import "PlayLocalMusic.h"
#import "AppDelegate.h"
#import "NAVVController.h"
//#import "KHJDeviceManager.h"

@interface KHJUdpHelper()<AsyncUdpSocketDelegate>
{
    AsyncUdpSocket* m_udpSocket;
}

@end

@implementation KHJUdpHelper

+ (KHJUdpHelper *)getinstance
{
    static KHJUdpHelper *instanceManager = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instanceManager = [[super allocWithZone:NULL] init] ;
    }) ;
    return instanceManager ;
}

+ (id) allocWithZone:(struct _NSZone *)zone
{
    return [KHJUdpHelper getinstance] ;
}

- (id) copyWithZone:(struct _NSZone *)zone
{
    return [KHJUdpHelper getinstance] ;
}

- (void)openUDPServer
{
    m_udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    NSError* error = nil;
    BOOL ret = [m_udpSocket bindToPort:6008 error:&error];
    if (ret) {
        CLog(@"绑定成功");
        [m_udpSocket joinMulticastGroup:@"224.0.1.2" error:&error];
        [m_udpSocket receiveWithTimeout:-1 tag:0];
    }
    else {
        CLog(@"绑定失败")
    }
}

- (BOOL)onUdpSocket:(AsyncUdpSocket*)sock
     didReceiveData:(NSData*)data
            withTag:(long)tag
           fromHost:(NSString*)host
               port:(UInt16)port
{
    return NO;
}
//{
//    NSLog(@"onUdpSocket successful");
//    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data
//                                                         options:NSJSONReadingMutableContainers
//                                                           error:nil];
//    CLog(@"body = %@",body);
//    KHJDeviceManager *dManager = [[KHJDeviceManager alloc] init];
//    [dManager creatCameraBase:body[@"uid"]];
//    [dManager connect:@"888888" withUid:body[@"uid"] flag:0 successCallBack:^(NSString *uidStr, NSInteger isSuccess) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (isSuccess == 0) {
//                CLog(@"连接成功");
//                // 1.用888888连接成功
//                // 2.设置设备密码，设置成功后
//                [dManager setPassword:@"888888" Newpassword:@"U4I6384375Wr9L01" withUid:body[@"uid"] returnCallBack:^(BOOL b) {
//                    if (b) {
//                        // 3.向服务器添加设备
//                        [[KHJNetWorkingManager sharedManager] addDeviceToUser:body[@"uid"] account:body[@"account"] pwd:@"JZIq6XMBtH38iQHIsCZUsA==" dVersion:@"0.0.0" dType:body[@"type"] dName:@"" returnCode:^(NSDictionary *dict, NSInteger c) {
//                            if (c == 1) {
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    [[KHJToast share] showToastActionWithToastType:_WarningType toastPostion:_CenterPostion tip:@""
//                                                                           content:KHJLocalizedString(@"addSuccess", nil)];
//                                    WeakSelf
//                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                        [[KHJToast share] dismissToast];
//                                        [weakSelf popMainViewCtrl];
//                                    });
//                                });
//                            }
//                            CLog(@"dict = %@",dict);
//                        }];
//                    }
//                }];
//            }
//            else {
//                WeakSelf
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [[KHJToast share] dismissToast];
//                    [weakSelf popMainViewCtrl];
//                });
//            }
//        });
//    } offLineCallBack:^{
//
//    }] ;
//
//
//    return YES;
//}

- (void)popMainViewCtrl
{
//    [[PlayLocalMusic shareInstance] stopPlay];
//    TabVController *tab = (TabVController *)[UIApplication sharedApplication].delegate.window.rootViewController;
//    NSInteger sIndec =  [[NSUserDefaults standardUserDefaults] integerForKey:KHJNaviBarItemIndexKey];
//    NAVVController *nav =  [tab.viewControllers objectAtIndex:sIndec];
//    [nav popToRootViewControllerAnimated:YES];
//    [[NSNotificationCenter defaultCenter] postNotificationName:needReloadList_Noti object:nil];
}

- (void)onUdpSocket:(AsyncUdpSocket*)sock didNotSendDataWithTag:(long)tag dueToError:(NSError*)error
{
    NSLog(@"error1");
}

- (void)onUdpSocket:(AsyncUdpSocket*)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError*)error
{

    NSLog(@"error2");
}
- (void)closeUpdServer{
    
    if (m_udpSocket) {
        [m_udpSocket close];
    }
}

@end