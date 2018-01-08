//
//  DownLoadViewController.m
//  NewDownLoadTask
//
//  Created by 夏财祥 on 2018/1/8.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import "DownLoadViewController.h"
#import "DownloadTableViewCell.h"
@interface DownLoadViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSArray * arrayData;
@end

@implementation DownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"video" ofType:@"json"];
    self.arrayData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",self.arrayData);
    [self UPUI];
}
-(void)UPUI
{
    UITableView * tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.delegate =  self;
    tableView.dataSource = self;
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.arrayData[indexPath.row][@"cover"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.image.image = [UIImage imageWithData:data];
        });
    });
    cell.titleLabel.text = self.arrayData[indexPath.row][@"title"];
    return cell;
}
#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
