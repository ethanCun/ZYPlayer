//
//  ZYModel.m
//  ZYPlayer
//
//  Created by macOfEthan on 17/11/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "ZYModel.h"

@implementation ZYModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"playTitle = %@,\n playUrl = %@, \n,playMaskViewNetUrl = %@\n", self.playTitle, self.playUrl, self.playMaskViewNetUrl];
}

@end
