//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"
#import <MBProgressHUD.h>

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) NSDictionary *lastParams;
@property (nonatomic, strong) NSString *lastQuery;
@property (nonatomic, assign) BOOL fetchingData;

-(void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;
-(NSDictionary *)defaultLimitParams;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self fetchBusinessesWithQuery:@"Restaurants" params:[self defaultLimitParams]];
        self.limit = 20;
        self.offset = 0;
        self.lastQuery = @"";
        self.fetchingData = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    self.tableView.estimatedRowHeight = 85;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.title = @"Yelp";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.searchBar = [[UISearchBar alloc] init];
    self.navigationItem.titleView = self.searchBar;
    self.searchBar.delegate = self;
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Filter delegate methods

-(void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    NSMutableDictionary *params = [filters mutableCopy];
    [params addEntriesFromDictionary:[self defaultLimitParams]];
    [self.tableView setContentOffset:CGPointZero animated:YES];
    [self fetchBusinessesWithQuery:[self.searchBar.text isEqualToString:@""] ? @"Restaurants" : self.searchBar.text params:params];
    //fire a new network event.
    NSLog(@"fire new network event: %@", filters);
    
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    if (indexPath.row >= self.businesses.count - 5 && !self.fetchingData) {
        [self fetchMoreData];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select row");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Search bar methods

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.view addGestureRecognizer:self.tapRecognizer];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.view removeGestureRecognizer:self.tapRecognizer];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self fetchBusinessesWithQuery:self.searchBar.text params:[self defaultLimitParams]];
    [self.searchBar endEditing:YES];
    [self.view removeGestureRecognizer:self.tapRecognizer];
}


#pragma mark - Private methods

-(NSDictionary *)defaultLimitParams {
    self.offset = 0;
    NSDictionary *params = @{@"limit" : @(20), @"offset" : @(0)};
    return params;
}

-(void)fetchMoreData {
    if (self.offset + self.limit > 1000) {
        return;
    }
    self.offset = self.offset + self.limit;
    NSMutableDictionary *newParams;
    NSDictionary *limitParams = @{@"limit" : @(self.limit), @"offset" : @(self.offset)};
    if (self.lastParams) {
        newParams = [self.lastParams mutableCopy];
        [newParams addEntriesFromDictionary:limitParams];
    } else {
        newParams = [limitParams mutableCopy];
    }
    self.fetchingData = YES;
    [self.client searchWithTerm:self.lastQuery params:newParams success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", newParams);
        NSArray *businessesDictionary = response[@"businesses"];
        [self.businesses addObjectsFromArray:[Business businessesWithDictionaries:businessesDictionary]];
        self.fetchingData = NO;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
        self.fetchingData = NO;
    }];
}

- (void)onTap {
    [self.searchBar endEditing:YES];
}

-(void)onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBar.translucent = NO;
    nvc.navigationBar.barTintColor = [UIColor redColor];
    nvc.navigationBar.tintColor = [UIColor whiteColor];
    [self presentViewController:nvc animated:YES completion:nil];
}

-(void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"response: %@", response);
        self.lastParams = params;
        NSLog(query);
        self.lastQuery = query;
        NSArray *businessesDictionary = response[@"businesses"];
        self.businesses = [Business businessesWithDictionaries:businessesDictionary];
        [self.tableView reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

@end
