//
//  ZYPlayViewController.m
//  ZYPlayer
//
//  Created by macOfEthan on 17/11/21.
//  Copyright © 2017年 macOfEthan. All rights reserved.
//

#import "ZYPlayViewController.h"
#import "ZYPlayerView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NextViewController.h"
#import "ZYModel.h"

@interface ZYPlayViewController ()<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ZYPlayerView *playerView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) UIImagePickerController *picker;

@property (nonatomic, strong) ZYModel *model;

@end

@implementation ZYPlayViewController

- (ZYModel *)model
{
    if (!_model) {
        self.model = [ZYModel new];
        self.model.playTitle = @"小蛮在客厅里看见姐姐在吃巧克力，瞬间泪崩，为啥我没有";
        self.model.playMaskViewNetUrl = @"http://dingyue.nosdn.127.net/sNqj813Bqk4cswe1IstpJasWiBVeRRopANffSFCRoph=p1491819943273.jpg";
        self.model.playUrl = @"http://flv3.bn.netease.com/videolib3/1711/21/ckDVJ2598/SD/ckDVJ2598-mobile.mp4";
    }
    return _model;
}

- (UIImagePickerController *)picker
{
    if (!_picker) {
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.mediaTypes = @[(NSString *)(kUTTypeImage), (NSString *)(kUTTypeMovie), (NSString *)(kUTTypeVideo)];
        self.picker.delegate = self;
    }
    return _picker;
}

- (NSArray *)urls
{
    if (!_urls) {
        self.urls = [[NSMutableArray alloc] initWithObjects:
                     @"http://flv3.bn.netease.com/videolib3/1711/20/HXjCO5688/SD/HXjCO5688-mobile.mp41",
                     @"http://flv3.bn.netease.com/videolib3/1711/19/KfBZt3301/HD/KfBZt3301-mobile.mp4",
                     @"http://flv3.bn.netease.com/videolib3/1711/19/cAJFK5983/SD/cAJFK5983-mobile.mp4",
                     @"http://flv3.bn.netease.com/videolib3/1711/19/tjeMW1137/SD/tjeMW1137-mobile.mp4",
                     nil];
    }
    return _urls;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.width*9/16+20, [UIScreen mainScreen].bounds.size.width, 300) style:UITableViewStylePlain];
        [self.view addSubview:self.tableView];
    }
    return _tableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    if (self.navigationController.viewControllers.count == 2 && self.playerView) {
        
        [self.playerView play];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.navigationController.viewControllers.count == 3 && self.playerView) {
        
        [self.playerView pause];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    
    NSArray *contents = [[NSBundle mainBundle] loadNibNamed:@"ZYPlayerView" owner:nil options:nil];
    
    self.playerView = contents.lastObject;
    
    self.playerView.playUrl = self.urls.firstObject;
    
    self.playerView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16);
    
    [self.view addSubview:self.playerView];
    
    self.playerView.back = ^(){
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

#pragma mark - orientationDidChange
- (void)orientationDidChange:(NSNotification *)noti
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (orientation == UIDeviceOrientationPortrait) {
        self.playerView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16);
        self.tableView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width*9/16+20, [UIScreen mainScreen].bounds.size.width, 300);
        
    }else{
        self.playerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16);
        self.tableView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width, 300);
    }
    
    [self.playerView setNeedsLayout];
}

#pragma mark - preferredInterfaceOrientationForPresentation
// default is UIInterfaceOrientationPortrait while presentation
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.urls.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reusedId = @"id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = self.urls[indexPath.row];
    }else if(indexPath.section == 1){
        cell.textLabel.text = @"小蛮在客厅里看见姐姐在吃巧克力...";
    }else if(indexPath.section == 2){
        cell.textLabel.text = @"从相册中导入视频";
    }else{
        cell.textLabel.text = @"下个界面";
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"url播放";
    }else if(section == 1){
        return @"model播放";
    }else if(section == 2){
        return @"本地视屏";
    }else{
        return @"push";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        self.playerView.playUrl = self.urls[indexPath.row];

    }else if(indexPath.section == 1){
        
        self.playerView.model = self.model;
        
    }else if(indexPath.section == 2){
        
        [self.playerView pause];
        
        [self presentViewController:self.picker animated:YES completion:nil];
    }else{
        
        [self.navigationController pushViewController:[NextViewController new] animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)dealloc
{
    NSLog(@"释放了");
    
    [self.playerView deallocPlayer];
    
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIImagePickerControllerDelegate, UINavigationControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    
    /**UIImagePickerControllerImageURL ===图片url*/
    /**UIImagePickerControllerMediaURL ===视频url*/
    self.playerView.playUrl = [info[@"UIImagePickerControllerMediaURL"] absoluteString];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.picker dismissViewControllerAnimated:YES completion:^(){
        
        [self.playerView play];
    }];
}


@end
