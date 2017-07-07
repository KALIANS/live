//
//  LiveListVC.m
//  KLIANSLiveDemo
//
//  Created by KLIANS on 2017/3/23.
//  Copyright © 2017年 KLIAN. All rights reserved.
//

#import "LiveListVC.h"
#import "LivesCell.h"
#import "SYPlayVC.h"
#import "ViewController.h"

/** 热门页接口*/
NSString *const kTJPHotLiveAPI              = @"http://116.211.167.106/api/live/aggregation?uid=133825214&interest=1";

@interface LiveListVC ()<UITableViewDataSource,UITableViewDelegate>

/**UItableview*/
@property (strong, nonatomic) UITableView *mainTableV;
/**数据*/
@property(nonatomic,strong) NSMutableArray *listArr;

@end

@implementation LiveListVC

#pragma mark - ################################# 生命周期 #################################

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化UI
    [self setUI];
    //初始化数据
    [self setData];
    //请求网络数据
    [self requestListData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

#pragma mark - ################################# 网络请求 ################################
-(void)requestListData{
    //初始化管理器
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    //发送GET请求
    [manager GET:kTJPHotLiveAPI parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id responsStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];// 转成json
        NSLog(@"%@",responsStr);
        NSDictionary *dic = [self dictionaryWithJsonString:responsStr];
        self.listArr = dic[@"lives"];
        [self.mainTableV reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

/*!
 
 * @brief 把格式化的JSON格式的字符串转换成字典
 
 * @param jsonString JSON格式的字符串
 
 * @return 返回字典
 
 */

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}

#pragma mark - ################################# 代理方法 ################################
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.listArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size.width*1.2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LivesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LivesCell"];
    [cell fillLivesCellData:self.listArr[indexPath.section]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.listArr[indexPath.section];
    SYPlayVC *vc = [SYPlayVC new];
    vc.url = [NSURL URLWithString:dic[@"stream_addr"]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ################################# 事件处理 ################################
//开播按钮点击事件
-(void)openLive{
    [self.navigationController presentViewController:[ViewController new] animated:YES completion:^{}];
}

//下拉加载最新
-(void)loadNewData{
    //请求网络数据
    [self requestListData];
    [self.mainTableV.mj_header endRefreshing];
}

//上啦加载更多
-(void)loadMoreData{
    [self.mainTableV.mj_footer endRefreshing];
}

#pragma mark - ################################# 声明的成员方法和类方法 #####################

#pragma mark - ################################# 私有方法 ################################

/**
 初始化UI
 */
- (void)setUI{
    self.title = @"热点直播";
    self.view.backgroundColor = [UIColor whiteColor];
    //添加列表
    [self.view addSubview:self.mainTableV];
    
    //开播按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"开播" style:(UIBarButtonItemStyleDone) target:self action:@selector(openLive)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //设置刷新
    [self setUpRefres];
}

/**
 初始化数据
 */
- (void)setData{
    
}

/**
 刷新
 */
-(void)setUpRefres
{
    NSMutableArray *headerImages = [NSMutableArray array];
    for (int i = 1; i <= 8; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"旋转%d",i]];
        [headerImages addObject:image];
    }
    MJRefreshGifHeader *header =[MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"加载更多.." forState:MJRefreshStateRefreshing];
    [header setTitle:@"松手刷新" forState:MJRefreshStatePulling];
    header.lastUpdatedTimeLabel.hidden = YES;
    [header setImages:headerImages forState:MJRefreshStateIdle];
    [header setImages:headerImages forState:MJRefreshStateRefreshing];
    self.mainTableV.mj_header = header;
    
    MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [footer setImages:headerImages forState:MJRefreshStateIdle];
    [footer setImages:headerImages forState:MJRefreshStateRefreshing];
    self.mainTableV.mj_footer = footer;
}

#pragma mark - ################################ 访问器方法 ################################
-(UITableView *)mainTableV{
    if (_mainTableV == nil) {
        _mainTableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:(UITableViewStyleGrouped)];
        _mainTableV.dataSource = self;
        _mainTableV.delegate = self;
        [_mainTableV registerNib:[UINib nibWithNibName:@"LivesCell" bundle:nil] forCellReuseIdentifier:@"LivesCell"];
    }
    return _mainTableV;
}

-(NSMutableArray *)listArr{
    if (_listArr == nil) {
        _listArr = [NSMutableArray array];
    }
    return _listArr;
}

@end
