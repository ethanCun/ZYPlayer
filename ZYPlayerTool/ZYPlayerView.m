//
//  ZYPlayerView.m
//  CzyLocalPlayer
//
//  Created by macOfEthan on 17/11/15.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

// 细节参考：
// http://blog.csdn.net/u011270282/article/details/70314607
// http://www.jb51.net/article/114895.htm
// 关于播放失败后， 切换playerItem之后不走kvo:
// http://www.cocoachina.com/bbs/read.php?tid=1712133


#define CZYWEAK(obj) __weak typeof(obj) weak##obj = obj;

#import "ZYPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ZYAlert : NSObject

@property (nonatomic, strong) UILabel *messageLabel;

+ (instancetype)share;

- (void)showMessage:(NSString *)message inView:(UIView *)v;

- (void)dismiss;

@end

@implementation ZYAlert

static ZYAlert *alert = nil;

+ (instancetype)share
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        alert = [ZYAlert new];
    });
    return alert;
}

- (void)showMessage:(NSString *)message inView:(UIView *)v
{
    _messageLabel.layer.cornerRadius = 5.0;
    _messageLabel.layer.masksToBounds = YES;
    
    CGFloat w = [message boundingRectWithSize:CGSizeMake(MAXFLOAT, 25) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:25]} context:nil].size.width;
    
    _messageLabel = [UILabel new];
    _messageLabel.text = message;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.frame = CGRectMake(0, 0, w+10, 30);
    _messageLabel.center = v.center;
    _messageLabel.font = [UIFont systemFontOfSize:14];
    _messageLabel.textColor = [UIColor blackColor];
    _messageLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];

    [[UIApplication sharedApplication].keyWindow addSubview:_messageLabel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3f animations:^{
            
            _messageLabel.alpha = 0.1;
            
        } completion:^(BOOL finished) {
            
            [self dismiss];
        }];
    });
}

- (void)dismiss
{
    [_messageLabel removeFromSuperview];
    _messageLabel = nil;
}

@end

@interface ZYBrightnessView : UIView

@property (nonatomic, strong) UILabel *brightnessLabel;
@property (nonatomic, strong) UIImageView *sunImageView;
@property (nonatomic, strong) UIView *progressBgView;
@property (nonatomic, assign) CGFloat value;

@end

@implementation ZYBrightnessView

- (void)setValue:(CGFloat)value
{
    _value = value;
    
    if (value <= 0) {
        value = 0.1;
    }else if(value >= 1.0){
        value = 1.0;
    }
    
    NSInteger tag = value*10;
    
    for (UIView *v in self.progressBgView.subviews) {
                
        if (v.tag >= tag+101) {
            
            v.hidden = YES;
        }else{
            
            v.hidden = NO;
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        
        _brightnessLabel = [UILabel new];
        _brightnessLabel.frame = CGRectMake(0, 5, CGRectGetWidth(self.bounds), 25);
        _brightnessLabel.text = @"亮度";
        _brightnessLabel.font = [UIFont systemFontOfSize:14];
        _brightnessLabel.textColor = [UIColor whiteColor];
        _brightnessLabel.textAlignment = NSTextAlignmentCenter;
        
        _sunImageView = [UIImageView new];
        _sunImageView.frame = CGRectMake(CGRectGetWidth(self.bounds)/4, CGRectGetHeight(_sunImageView.frame)+35, CGRectGetWidth(self.bounds)/2, CGRectGetWidth(self.bounds)/2);
        [_sunImageView setImage:[UIImage imageNamed:@"brightness"]];
        
        _progressBgView = [[UIView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_sunImageView.frame)+20, CGRectGetWidth(self.bounds)-10, 5)];
        _progressBgView.backgroundColor = [UIColor blackColor];
        
        CGFloat w = (CGRectGetWidth(_progressBgView.frame)-9*1)/8;
        CGFloat h = 5;
        
        for (NSInteger i=0; i<8; i++) {
            
            UIView *v = [UIView new];
            v.backgroundColor = [UIColor whiteColor];
            v.frame = CGRectMake(1+(1+w)*i, 0, w, h);
            [_progressBgView addSubview:v];
            
            v.tag = 101+i;
        }
        
        [self addSubview:_brightnessLabel];
        [self addSubview:_sunImageView];
        [self addSubview:_progressBgView];
        
        self.value = [UIScreen mainScreen].brightness;
    }
    return self;
}

@end

@interface ZYProgessView : UIView

@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UILabel *timeLab;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation ZYProgessView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        
        _arrowImageView = [UIImageView new];
        _arrowImageView.frame = CGRectMake(CGRectGetWidth(self.bounds)/4, 5, CGRectGetWidth(self.bounds)/2, CGRectGetWidth(self.bounds)/2);
        
        _timeLab = [UILabel new];
        _timeLab.frame = CGRectMake(0, CGRectGetHeight(_arrowImageView.frame)+5, CGRectGetWidth(self.bounds), 25);
        _timeLab.font = [UIFont systemFontOfSize:14];
        _timeLab.textColor = [UIColor whiteColor];
        _timeLab.textAlignment = NSTextAlignmentCenter;
        
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.frame = CGRectMake(5, CGRectGetMaxY(_timeLab.frame)+5, CGRectGetWidth(self.bounds)-10, 2);
        _progressView.progress = 0;
        _progressView.tintColor = [UIColor whiteColor];
        
        [self addSubview:_arrowImageView];
        [self addSubview:_timeLab];
        [self addSubview:_progressView];
    }
    return self;
}

@end

typedef NS_ENUM(NSInteger, ZYPanDirection)
{
    ZYPanDirectionVetical,
    ZYPanDirectionHorizontal,
};

@interface ZYPlayerView ()

@property (weak, nonatomic) IBOutlet UIView *playerBgView;
@property (weak, nonatomic) IBOutlet UIView *topBgView;
@property (weak, nonatomic) IBOutlet UIView *bottomBgView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *fullBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIImageView *maskImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *cacheProgressiew;

/**play progress*/
@property (nonatomic, assign) CGFloat currentDuration;
@property (nonatomic, assign) CGFloat totalDuration;

/**layer*/
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

// wether show the control layer
@property (nonatomic, assign) BOOL isControlLayerShow;
// wether full screen
@property (nonatomic, assign) BOOL isFullScreen;
// wether the observer is dealloced
@property (nonatomic, assign) BOOL isDealloced;


@property (nonatomic, strong) UITapGestureRecognizer *sliderTap;

// panGes
// volume or brightness
@property (nonatomic, assign) BOOL isVolume;
// verticl or horizontal
@property (nonatomic, assign) ZYPanDirection panDirection;

// time when slide
@property (nonatomic, assign) CGFloat sumTime;
// ZYProgessView
@property (nonatomic, strong) ZYProgessView *zyProgressView;
// brightness View
@property (nonatomic, strong) ZYBrightnessView *brightnessView;
// system volume slider
@property (nonatomic, strong) UISlider *volumeSlider;
//replay
@property (nonatomic, strong) UIButton *replayBtn;

//last choose url , to avoid double click crash
@property (nonatomic, copy) NSString *lastChooseUrl;



@end

@implementation ZYPlayerView

#pragma mark - setter
- (void)setPlayTitle:(NSString *)playTitle
{
    _playTitle = playTitle;
    
    [self.title setText:_playTitle];
}

- (void)setMaskBgViewImageName:(NSString *)maskBgViewImageName
{
    _maskBgViewImageName = maskBgViewImageName;
    
    self.maskImageView.image = [UIImage imageNamed:_maskBgViewImageName];
}

- (void)setModel:(ZYModel *)model
{
    _model = model;
    
//    [self.maskImageView sd_setImageWithURL:[NSURL URLWithString:_model.playMaskViewNetUrl]];
    self.title.text = _model.playTitle;
    
    NSAssert(_model.playUrl.length, @"链接不能为空");

    [self replayWithUrl:_model.playUrl];
}

- (void)setPlayUrl:(NSString *)playUrl
{
    NSAssert(playUrl.length, @"链接不能为空");
    
    _playUrl = playUrl;
    
    // set to default image
    self.maskImageView.image = [UIImage imageNamed:@"ZYPlayer"];
    
    // change url
    [self replayWithUrl:_playUrl];
}

#pragma mark - replay
- (void)replayWithUrl:(NSString *)newPlayUrl
{
    //delete replay btn if any
    [self removeReplayBtn];
    
    // reset player
    if (self.player) {
        [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            
            [self.slider setValue:0 animated:NO];
            [self.cacheProgressiew setProgress:0 animated:NO];
            [self.timeLab setText:@"00:00:00"];
        }];
        [self.player pause];
    }
    
    //remove original layer
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
        
        [self removeReplayBtn];
    }
    
    // remove original observer
    if (_isDealloced == NO) {
        [self deallocPlayerObserver];
    }
    
    //set to 0 and nil
    self.currentDuration = 0;
    
    // start running
    [self showActivity];
    
    
    //to avoid double click crash
    if (newPlayUrl == _lastChooseUrl) {
        return;
    }
    
    _lastChooseUrl = newPlayUrl;
    
    // reInit
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:newPlayUrl]];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.playerBgView.layer addSublayer:self.playerLayer];
    
    [self.playerBgView bringSubviewToFront:self.topBgView];
    [self.playerBgView bringSubviewToFront:self.bottomBgView];
    
    //layout
    [self setNeedsLayout];
    
    // config player
    [self configPlayer];
}

#pragma mark - awakeFromNib
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self showActivity];
    
    _isDealloced = YES;
    
    //backround
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    //foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //headset
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
}


#pragma mark - applicationEnterBackground
- (void)applicationEnterBackground:(NSNotification *)info
{
    [self.player pause];
}

#pragma mark - applicationEnterForeground
- (void)applicationEnterForeground:(NSNotification *)info
{
    [self.player play];
}

#pragma mark - audioSessionRouteChanged
- (void)audioSessionRouteChanged:(NSNotification *)info
{
    NSInteger audioRouteChanedReason = [info.userInfo[@"AVAudioSessionRouteChangeReasonKey"] integerValue];
    
    switch (audioRouteChanedReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            
            // insert headset
            NSLog(@"insert headset");
            
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        
            //output headset
            //default to pause
            NSLog(@"output headset");
            [self play];
            
            break;
        default:
            
            break;
    }
}

#pragma mark - system volume
- (void)configVolume
{
    if (!_volumeSlider) {
        
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        
        _volumeSlider = nil;
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeSlider = (UISlider *)view;
                break;
            }
        }
        
        // play when system volume == 0 (系统静音的时候仍可播放)
        NSError *setCategoryError = nil;
        BOOL success = [[AVAudioSession sharedInstance]
                        setCategory: AVAudioSessionCategoryPlayback
                        error: &setCategoryError];
        
        if (!success) { /* handle the error in setCategoryError */ }
    }
}

#pragma mark - layoutSubviews
- (void)layoutSubviews
{
    //  change frame when fullScreen exchange
    self.playerLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16);
    _replayBtn.frame = CGRectMake(0, 0, 50, 70);
    _replayBtn.center = self.playerBgView.center;
    [ZYAlert share].messageLabel.center = self.playerBgView.center;
}

#pragma mark - configPlayer
- (void)configPlayer
{
    CZYWEAK(self);
    
    [self configVolume];
    
    [self addPlayObserver];
    
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        weakself.currentDuration = CMTimeGetSeconds(time);
        weakself.totalDuration = CMTimeGetSeconds([weakself.player.currentItem duration]);
        
        weakself.timeLab.text = [weakself getTimeWithSecond:weakself.currentDuration];
        
        /**播放时改变进度条*/
        [weakself.slider setValue:self.currentDuration / self.totalDuration animated:NO];
    }];
    
    // play to end
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    /**userInteraction Disabled while full screen*/
    self.playerBgView.userInteractionEnabled = YES;
    self.topBgView.userInteractionEnabled = YES;
    self.bottomBgView.userInteractionEnabled = YES;
    
    [self.playerBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgPlayerView:)]];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.playerBgView addGestureRecognizer:doubleTap];
    
    //slider
    [self.slider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    [self.slider addTarget:self action:@selector(valueChangedBySlide:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    
    _sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTap:)];
    [self.slider addGestureRecognizer:_sliderTap];
    
    //auto hidden control layer
    [self hiddenControlAfterTwoSecond];
}

#pragma mark - play to end  / go many times
- (void)didPlayToEnd:(NSNotification *)info
{
    if (!self.replayBtn) {
        self.replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.replayBtn.frame = CGRectMake(0, 0, 50, 70);
        self.replayBtn.center = self.playerBgView.center;
        [self.replayBtn setImage:[UIImage imageNamed:@"replay"] forState:UIControlStateNormal];
        [self.playerBgView addSubview:self.replayBtn];
    }
    
    [self.replayBtn addTarget:self action:@selector(replay:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)replay:(UIButton *)sender
{
    [self removeReplayBtn];
    
    [self hiddenControlAfterTwoSecond];
    
    [self.player seekToTime:kCMTimeZero];
    
    [self play];
}

#pragma mark - remove replay btn
- (void)removeReplayBtn
{
    if (!self.replayBtn) {
        return;
    }
    
    [self.replayBtn removeFromSuperview];
    self.replayBtn = nil;
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            
            [self hiddenAcyivity];

            [self play];
            
            // add pan gesture
            UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
            [self addGestureRecognizer:panGes];
            
        }else if(playerItem.status == AVPlayerItemStatusUnknown){
            
            NSLog(@"unknown");
            
            [self hiddenAcyivity];
            
            [[ZYAlert share] showMessage:@"播放失败,请重试" inView:self.playerBgView];
            
            // remove original observer
            [self deallocPlayerObserver];

        }else if(playerItem.status == AVPlayerItemStatusFailed){
            
            NSLog(@"failed");
            
            [self hiddenAcyivity];
            
            [[ZYAlert share] showMessage:@"播放失败,请重试" inView:self.playerBgView];
            
            // remove original observer
            [self deallocPlayerObserver];
        }
        
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        
        CGFloat loadedTime = [self availableDuration];
        CGFloat totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
        self.cacheProgressiew.progress = loadedTime/totalTime;
        
        if (self.cacheProgressiew.progress >= 1.0) {
            
            self.cacheProgressiew.hidden = YES;
        }else{
            self.cacheProgressiew.hidden = NO;
        }
        
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        
        NSLog(@"playbackBufferEmpty");
        
        [self showActivity];
        
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        
        NSLog(@"playbackLikelyToKeepUp");
        
        [self hiddenAcyivity];
    }
}

#pragma mark - panGes
- (void)panGes:(UIPanGestureRecognizer *)sender
{
    //delete replay btn if any
    [self removeReplayBtn];
    
    CGPoint point = [sender locationInView:self];
    
    CGPoint velocityPoint = [sender velocityInView:self];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            
            if (x > y) { // horizontal
                
                self.panDirection = ZYPanDirectionHorizontal;
                
                // pause
                [self pause];
                
                // initial sumTime
                CMTime currentTime = self.player.currentTime;
                self.sumTime = currentTime.value/currentTime.timescale;
                
                _zyProgressView = [[ZYProgessView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                _zyProgressView.center = self.center;
                [self addSubview:_zyProgressView];
                
            }else if(x < y){ // vertical
                
                self.panDirection = ZYPanDirectionVetical;
                
                if (point.x > [UIScreen mainScreen].bounds.size.width/2) {
                    _isVolume = YES;
                    
                }else{
                    _isVolume = NO;
                    
                    _brightnessView = [[ZYBrightnessView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
                    _brightnessView.center = [UIApplication sharedApplication].keyWindow.center;
                    [[UIApplication sharedApplication].keyWindow addSubview:_brightnessView];
                }
            }
            
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if (self.panDirection == ZYPanDirectionHorizontal) {
                
                [self horizontalGesChanged:velocityPoint.x];
                
            }else{
                
                [self verticalGesChaned:velocityPoint.y];
            }
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            if (self.panDirection == ZYPanDirectionHorizontal) {
                
                [self.player seekToTime:CMTimeMake(self.sumTime, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                
                // 0
                self.sumTime = 0;
                [_zyProgressView removeFromSuperview];
                _zyProgressView = nil;
                
                // play
                [self play];
                
            }else{
                
                // volume
                self.isVolume = NO;
                
                [_brightnessView removeFromSuperview];
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - horizontalGesChanged
- (void)horizontalGesChanged:(CGFloat)gesPointX
{
    if (self.panDirection == ZYPanDirectionVetical) {
        return;
    }
    
    //delete replay btn if any
    [self removeReplayBtn];
    
    self.sumTime += gesPointX/500;
    
    if (self.sumTime >= self.totalDuration) {
        self.sumTime = self.totalDuration;
    }else if (self.sumTime <= 0){
        self.sumTime = 0;
    }
    
    if (gesPointX <0 ) { // backforwards
        
        [_zyProgressView.arrowImageView setImage:[UIImage imageNamed:@"backforwards"]];
    }else{
        [_zyProgressView.arrowImageView setImage:[UIImage imageNamed:@"forwards"]];
    }
    
    [_zyProgressView.progressView setProgress:self.sumTime/self.totalDuration animated:NO];
    _zyProgressView.timeLab.text = [self getTimeWithSecond:self.sumTime];
    [self.slider setValue:self.sumTime/self.totalDuration animated:NO];
}

#pragma mark - verticle Ges changed
- (void)verticalGesChaned:(CGFloat)gesPointY
{
    if (self.panDirection == ZYPanDirectionHorizontal) {
        return;
    }
    
    if (self.isVolume) {
        
        // volume
        self.volumeSlider.value -= gesPointY/10000;
        
    }else{
        
        // brightness
        [UIScreen mainScreen].brightness -= gesPointY / 10000;
        
        // UI
        if ([UIScreen mainScreen].brightness <= 0.1) {
            
            _brightnessView.value = 0.1;
        }else{
        
            _brightnessView.value = [UIScreen mainScreen].brightness;
        }
    }
}



#pragma mark - control layer
- (void)tapBgPlayerView:(UITapGestureRecognizer *)tapGr
{

    if (self.isControlLayerShow) {
        
        self.topBgView.hidden = NO;
        self.bottomBgView.hidden = NO;
        
    }else{
        
        self.topBgView.hidden = YES;
        self.bottomBgView.hidden = YES;
    }
    
    self.isControlLayerShow = !self.isControlLayerShow;
}

- (void)hiddenControlAfterTwoSecond
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3f animations:^{
            
            self.topBgView.transform = CGAffineTransformMakeTranslation(0, -100);
            self.bottomBgView.transform = CGAffineTransformMakeTranslation(0, 100);
            
        } completion:^(BOOL finished) {
            
            self.topBgView.transform = CGAffineTransformIdentity;
            self.bottomBgView.transform = CGAffineTransformIdentity;
            
            self.topBgView.hidden = YES;
            self.bottomBgView.hidden = YES;
            
            // reset to yes
            self.isControlLayerShow = YES;
        }];
    });
}


#pragma mark - full screen
- (IBAction)clickToFullScreen:(UIButton *)sender {
    
    [self tapToChangeScreenWithSender:self.fullBtn];
}

- (void)doubleTap:(UITapGestureRecognizer *)tap
{
    [self tapToChangeScreenWithSender:self.fullBtn];
}

- (void)tapToChangeScreenWithSender:(UIButton *)sender
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (orientation == UIDeviceOrientationPortrait) {
        
        [self rotateToOritation:UIDeviceOrientationLandscapeLeft];
        
        self.isFullScreen = YES;
    }else{
        
        [self rotateToOritation:UIDeviceOrientationPortrait];
        
        self.isFullScreen = NO;
    }
    
    if (self.isFullScreen) {
        [sender setImage:[UIImage imageNamed:@"btn_zoom_in"] forState:UIControlStateNormal];
    }else{
        [sender setImage:[UIImage imageNamed:@"btn_zoom_out"] forState:UIControlStateNormal];
    }
    
}

- (void)rotateToOritation:(UIDeviceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        
        NSMethodSignature *methodSignature = [[UIDevice currentDevice] methodSignatureForSelector:@selector(setOrientation:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:[UIDevice currentDevice]];
        [invocation setSelector:@selector(setOrientation:)];
        [invocation  setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
    
    [self setNeedsLayout];
}

#pragma mark - seconds transfer
- (NSString *)getTimeWithSecond:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

#pragma mark - available cache
- (NSTimeInterval)availableDuration {
    
    NSArray *loadedTimeRanges = [self.player.currentItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    
    return result;
}

- (void)play
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.player play];
        self.playBtn.selected = NO;
        [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

- (void)pause
{
    [self.player pause];
    self.playBtn.selected = YES;
    [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

#pragma mark - slider action
- (void)valueChangedBySlide:(UISlider *)slider
{
    //delete replay btn if any
    [self removeReplayBtn];
    
    [self pause];
    
    CGFloat totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    
    [self.player.currentItem seekToTime:CMTimeMakeWithSeconds(totalTime * slider.value, NSEC_PER_SEC)];
}

- (void)sliderTouchDown:(UITapGestureRecognizer *)tap
{
    //delete replay btn if any
    [self removeReplayBtn];
    
    _sliderTap.enabled = NO;
    
    [self pause];
    
}

- (void)sliderTouchUp:(UITapGestureRecognizer *)tap
{
    //delete replay btn if any
    [self removeReplayBtn];
    
    _sliderTap.enabled = YES;
    
    [self play];
    
}

- (void)sliderTap:(UITapGestureRecognizer *)sender
{
    //delete replay btn if any
    [self removeReplayBtn];
    
    [self pause];
    
    CGPoint touchPoint = [sender locationInView:self.slider];
    CGFloat value = (self.slider.maximumValue - self.slider.minimumValue) * (touchPoint.x / self.slider.frame.size.width );
    [self.slider setValue:value animated:YES];
    
    CGFloat totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    [self.player.currentItem seekToTime:CMTimeMakeWithSeconds(totalTime * self.slider.value, NSEC_PER_SEC)];
    
    [self play];
}

#pragma mark - playOrPause
- (IBAction)playOrPause:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        [self pause];
    }else{
        
        [self play];
    }
}


#pragma mark - back
- (IBAction)back:(UIButton *)sender {
    
    //reset to portrait
    [self rotateToOritation:UIDeviceOrientationPortrait];
    
    if (self.back) {
        self.back();
    }
}

#pragma mark - show activity
- (void)showActivity
{
    self.activityView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
    self.activityView.color = [UIColor brownColor];

    [self.playerBgView bringSubviewToFront:self.activityView];
    [self.activityView startAnimating];
}

#pragma mark - hidden activity
- (void)hiddenAcyivity
{
    [self.activityView stopAnimating];
    self.activityView.hidesWhenStopped = YES;
}


#pragma mark - addPlayObserver
- (void)addPlayObserver
{
    //status and loadedTimeRanges
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    //buffer
    [self.player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    _isDealloced = NO;
}

#pragma mark - deallocPlayerObserver
- (void)deallocPlayerObserver
{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    _isDealloced = YES;
}


#pragma mark - destory
- (void)deallocPlayer
{
    [self.player pause];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_isDealloced == NO) {
        [self deallocPlayerObserver];
    }
    
    self.player = nil;
    self.playerItem = nil;
    self.playerLayer = nil;
    
    // remove alert if any
    [[ZYAlert share] dismiss];
}


@end

