//
//  ZYPlayerView.h
//  CzyLocalPlayer
//
//  Created by macOfEthan on 17/11/15.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZYModel.h"

@interface ZYPlayerView : UIView

/**url*/
@property (nonatomic, copy) NSString *playUrl;

/**maskView*/
@property (nonatomic, copy) NSString *maskBgViewImageName;

/**title*/
@property (nonatomic, copy) NSString *playTitle;

/**play model*/
@property (nonatomic, strong) ZYModel *model;

/**back*/
@property (nonatomic, copy) void(^back)(void);


- (void)play;

- (void)pause;

- (void)deallocPlayer;

@end
