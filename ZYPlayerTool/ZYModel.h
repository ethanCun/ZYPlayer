//
//  ZYModel.h
//  ZYPlayer
//
//  Created by macOfEthan on 17/11/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYModel : NSObject

@property (nonatomic, copy) NSString *playTitle;
@property (nonatomic, copy) NSString *playUrl;

/**background view*/
@property (nonatomic, copy) NSString *playMaskViewNetUrl;

@end
