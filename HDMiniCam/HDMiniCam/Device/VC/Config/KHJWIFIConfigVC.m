//
//  KHJWIFIConfigVC.m
//  SuperIPC
//
//  Created by 王涛 on 2020/1/18.
//  Copyright © 2020年 王涛. All rights reserved.
//

#import "KHJWIFIConfigVC.h"
#import "KHJWIFIConfigCell.h"
#import "ZQAlterField.h"
#import "TTFirmwareInterface_API.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface KHJWIFIConfigVC ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *wifiListArr;
    UIView *back_groundView;
    __weak IBOutlet UIView *topView;
    __weak IBOutlet NSLayoutConstraint *topViewCH;
    __weak IBOutlet UILabel *wifiName;
    __weak IBOutlet UITableView *contentTBV;
}

@end

@implementation KHJWIFIConfigVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[TTHub shareHub] showText:@"" addToView:self.view type:0];

    self.titleLab.text = TTLocalString(@"wfSetp_", nil);
    [self.leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [[TTFirmwareInterface_API sharedManager] getDeviceWiFi_with_deviceID:self.deviceInfo.deviceID reBlock:^(NSInteger code) {}];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(OnGetDeviceWiFi:)
                                                 name:TT_getDeviceWiFiCmdResult_noti_KEY
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPhoneWifi];
}

- (void)getPhoneWifi
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *item in ifs) {
        NSDictionary *info = [NSDictionary dictionaryWithDictionary:(__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)item)];
        NSString *wifiName = info[@"SSID"];
        if ([wifiName hasPrefix:@"IPC_"]) {
            topView.hidden = YES;
            topViewCH.constant = 0;
        }
    }
}

- (void)OnGetDeviceWiFi:(NSNotification *)noti
{
    
    NSDictionary *result = (NSDictionary *)noti.object;
    int ret = [result[@"ret"] intValue];
    NSDictionary *body = [NSDictionary dictionaryWithDictionary:result[@"NetWork.Wireless"]];
    if (ret == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self->wifiName.text = body[@"SSID"];
        });
        [[TTFirmwareInterface_API sharedManager] searchDeviceWiFi_with_deviceID:self.deviceInfo.deviceID reBlock:^(NSInteger code) {}];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSearchDeviceWiFi:) name:TT_getSearchDeviceWiFi_noti_KEY object:nil];
    }
    else {
        [self.view makeToast:TTLocalString(@"gtDevWfFaile_", nil)];
    }
}

- (void)getSearchDeviceWiFi:(NSNotification *)noti
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TTHub shareHub].hud.hidden = YES;
    });
    NSDictionary *result = (NSDictionary *)noti.object;
    int ret = [result[@"ret"] intValue];
    if (ret == 0) {
        wifiListArr = result[@"NetWork.WirelessSearch"][@"Aplist"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *array = [NSMutableArray arrayWithArray:self->wifiListArr];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *body = (NSDictionary *)obj;
                NSString *wifi = body[@"SSID"];
                if ([wifi isEqualToString:self->wifiName.text]) {
                    [array removeObject:body];
                    *stop = YES;
                }
            }];
            self->wifiListArr = [array mutableCopy];
            [self->contentTBV reloadData];
        });
    }
    else {
        [self.view makeToast:TTLocalString(@"gtDevWfFaile_", nil)];
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return wifiListArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KHJWIFIConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KHJWIFIConfigCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KHJWIFIConfigCell" owner:nil options:nil][0];
    }
    cell.tag = indexPath.row + FLAG_TAG;
    TTWeakSelf
    NSDictionary *body = wifiListArr[indexPath.row];
    cell.block = ^(NSInteger row) {
        TLog(@"row = %ld",(long)row);
        [weakSelf changewifi:body];
    };
    cell.name.text = body[@"SSID"];
    cell.safeLab.text = TTStr(@"%@：%@",TTLocalString(@"sfe_", nil),body[@"EncType"]);
    cell.stronglyLab.text = TTStr(@"%@：%@",TTLocalString(@"singStrog_", nil),body[@"RSSI"]);
    return cell;
}

- (void)changewifi:(NSDictionary *)body
{
    TTWeakSelf
    ZQAlterField *alertView = [ZQAlterField alertView];
    alertView.title = TTStr(@"%@：%@",TTLocalString(@"changeWF_", nil),body[@"SSID"]);
    alertView.placeholder = TTLocalString(@"inputWFPwd_", nil);
    alertView.Maxlength = 50;
    alertView.ensureBgColor = TTCommon.appMainColor;
    [alertView ensureClickBlock:^(NSString *inputString) {
        TLog(@"输入内容为%@",inputString);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf changeConnectWifi:body password:inputString];
        });
    }];
    [alertView show];
}

- (void)changeConnectWifi:(NSDictionary *)body password:(NSString *)password
{
    [[TTFirmwareInterface_API sharedManager] setDeviceWiFi_with_deviceID:self.deviceInfo.deviceID ssid:body[@"SSID"] password:password encType:body[@"EncType"] reBlock:^(NSInteger code) {}];
    TTWeakSelf
    [self.view makeToast:TTLocalString(@"wtReconect_", nil)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    });
}

@end
