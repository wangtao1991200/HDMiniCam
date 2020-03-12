//
//  KHJCollectionViewCell_three.m
//  HDMiniCam
//
//  Created by khj888 on 2020/3/4.
//  Copyright © 2020 王涛. All rights reserved.
//

#import "KHJCollectionViewCell_three.h"

@implementation KHJCollectionViewCell_three

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)btnAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(chooseItemWith:)]) {
        [_delegate chooseItemWith:self.tag - FLAG_TAG];
    }
}

- (IBAction)delelte:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteItemWith:)]) {
        [_delegate deleteItemWith:self.tag - FLAG_TAG];
    }
}

@end