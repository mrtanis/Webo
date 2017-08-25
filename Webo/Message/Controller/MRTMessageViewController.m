//
//  MRTMessageViewController.m
//  Webo
//
//  Created by mrtanis on 2017/5/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTMessageViewController.h"
#import "MRTMessageSwitchView.h"

@interface MRTMessageViewController () <MRTMessageSwitchViewDelegate>

@end

@implementation MRTMessageViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *chat = [[UIBarButtonItem alloc] initWithTitle:@"发起聊天" style:UIBarButtonItemStylePlain target:self action:@selector(chat)];
    
    self.navigationItem.rightBarButtonItem = chat;
    
    //重要！！！否则自己添加的tableView上面会留出导航栏高度的空白
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    MRTMessageSwitchView *switchView = [[MRTMessageSwitchView alloc] initWithFrame:CGRectMake(0, 64, MRTScreen_Width, self.view.height - 64)];
    switchView.delegate = self;
    
    [self.view addSubview:switchView];
}

//点击发起聊天调用
- (void)chat
{
    NSLog(@"%s", __func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)messageSwitchViewDidSendVC:(UIViewController *)VC present:(BOOL)present
{
    if (present) {
        [self presentViewController:VC animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:VC animated:YES];
    }
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
    
