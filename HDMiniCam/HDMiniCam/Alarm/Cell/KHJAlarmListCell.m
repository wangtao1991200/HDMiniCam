//
//  KHJAlarmListCell.m
//  HDMiniCam
//
//  Created by khj888 on 2020/1/16.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJAlarmListCell.h"

@implementation KHJAlarmListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)action:(id)sender {
    if (_block) {
        _block(self.tag - FLAG_TAG);
    }
}

@end
