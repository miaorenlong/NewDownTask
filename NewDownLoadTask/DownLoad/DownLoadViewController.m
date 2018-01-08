//
//  DownLoadViewController.m
//  NewDownLoadTask
//
//  Created by 夏财祥 on 2018/1/8.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import "DownLoadViewController.h"
#import "DownloadTableViewCell.h"
#import "Model.h"
@interface DownLoadViewController ()<UITableViewDelegate,UITableViewDataSource,NSURLSessionDownloadDelegate>
@property(nonatomic,strong)NSArray * arrayData;
@property(nonatomic,strong)NSMutableArray * arrayList;
@property(nonatomic,strong)NSDate * lastDate;
@end

@implementation DownLoadViewController

-(void)dealloc
{
    NSLog(@"我去");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"video" ofType:@"json"];
    self.arrayData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
    NSString * stringPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"%@",stringPath);
    [self UPUI];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(touchBack:)];
}
//-(void)touchBack:(UIBarButtonItem *)sender
//{
////    for (Model * model in self.arrayList) {
////        [model.session invalidateAndCancel];
////    }
//    [self.navigationController popViewControllerAnimated:YES];
//}
-(void)UPUI
{
    UITableView * tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.delegate =  self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [tableView registerNib:[UINib nibWithNibName:@"DownloadTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"download"];
}
#pragma mark - tableview datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayData.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"download"];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:weakSelf.arrayData[indexPath.row][@"cover"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.image.image = [UIImage imageWithData:data];
        });
    });
    cell.titleLabel.text = self.arrayData[indexPath.row][@"title"];
    RainbowProgress * progress = [[RainbowProgress alloc]initWithFrame:cell.rainView.bounds];
    [cell.rainView addSubview:progress];
    cell.rainProgress = progress;
    return cell;
}
#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * urlString = self.arrayData[indexPath.row][@"mp4_url"];
    
    for (Model * model in self.arrayList) {
        if ([model.urlString isEqualToString:urlString]) {
            
            if (model.downloadTask.state == NSURLSessionTaskStateRunning) {
                [model.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    model.resumeData = resumeData;
                }];
                return;
            }
            
            if (model.downloadTask.state == NSURLSessionTaskStateCompleted) {
                if (model.resumeData) {
                    model.downloadTask = [model.session downloadTaskWithResumeData:model.resumeData];
                    [model.downloadTask resume];
                }
                return;
            }
            
        }
    }
    
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"dijige%ld",(long)indexPath.row]];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask * downloadTask = [session downloadTaskWithRequest:request];
    [downloadTask resume];
    Model * model = [[Model alloc]initWith:session withIdentifier:[NSString stringWithFormat:@"dijige%ld",(long)indexPath.row] withURL:urlString withIndexPath:indexPath];
    model.downloadTask = downloadTask;
    [self.arrayList addObject:model];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
#pragma mark - nsurlsession download delegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    for (Model * model in self.arrayList) {
        if (model.session == session) {
            DownloadTableViewCell * cell = [self.tableView cellForRowAtIndexPath:model.indexPath];
            cell.totalLabel.text = [NSString stringWithFormat:@"%.1fM",(double)totalBytesExpectedToWrite/(1024 *1024)];
            cell.currentLabel.text = [NSString stringWithFormat:@"%.1fM",(double)totalBytesWritten/(1024 * 1024)];
            cell.rainProgress.progressValue = 1.0 * totalBytesWritten/totalBytesExpectedToWrite;
            NSDate * date = [NSDate date];
            if (self.lastDate == nil) {
                self.lastDate = date;
                return;
            }
            NSTimeInterval timeInter = [date timeIntervalSinceDate:self.lastDate];
            self.lastDate = date;
            cell.speedLabel.text = [NSString stringWithFormat:@"%.3fKB/s",bytesWritten/(1024 * timeInter)];
           
        }
    }
 
    
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSString * str = nil;
    for (Model * model in self.arrayList) {
        str = [NSString stringWithFormat:@"%ld",(long)model.indexPath.row];
    }
    NSString * stringPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingString:[NSString stringWithFormat:@"/%@.mp4",str]];
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:stringPath] error:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSMutableArray *)arrayList
{
    if (_arrayList == nil) {
        _arrayList = [[NSMutableArray alloc]init];
    }
    return _arrayList;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
