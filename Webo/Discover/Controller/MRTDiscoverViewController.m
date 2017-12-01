//
//  MRTDiscoverViewController.m
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTDiscoverViewController.h"
#import "MRTSearchBar.h"
#import "MRTSearchController.h"

@interface MRTDiscoverViewController () <UISearchResultsUpdating, UISearchControllerDelegate>
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation MRTDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MRTSearchController *searchController = [[MRTSearchController alloc] initWithSearchResultsController:nil];
    // 设置结果更新代理
    searchController.searchResultsUpdater = self;
    // 因为在当前控制器展示结果, 所以不需要这个透明视图
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.delegate = self;
    self.navigationItem.titleView = searchController.searchBar;
    /*
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = searchController;
    } else {
        // Fallback on earlier versions
    }*/
    
    
    
}

//导航栏随tableView上滑
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    CGFloat progress;
    if (offsetY > -76) {
        progress = (offsetY + 76);
    }else{
        progress = 0;
    }
 
    //计算要位移的距离
    CGFloat navOffSetY = -1 * progress;

    self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0,navOffSetY);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 20;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
   
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
    
}

- (void)viewWillLayoutSubviews
{
    NSLog(@"self.navigationbar.frame:(%f, %f, %f, %f)", self.navigationController.navigationBar.x,self.navigationController.navigationBar.y,self.navigationController.navigationBar.width,self.navigationController.navigationBar.height);
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
