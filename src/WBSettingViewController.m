

#import "WBSettingViewController.h"
#import "WeChatRedEnvelop.h"
#import "WBRedEnvelopConfig.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "WBMultiSelectGroupsViewController.h"
#import "ZToolView.h"
#import "HBLocalConnection.h"
#import "BKlKeychainManager.h"
#import "WXRegistrationCodeView.h"
#import "WXHongBaoOpeartionMgr.h"

@interface WBSettingViewController () <MultiSelectGroupsViewControllerDelegate>

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation WBSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [ZToolView sharedZToolView].SegmentedEventValueChanged = ^{
        [self reloadTableData];
    };
    
    [self initTitle];
    [self reloadTableData];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
    
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]) {
        WXRegistrationCodeView *wxRview = [[WXRegistrationCodeView alloc]initWithFrame:self.view.frame];
        [self.view addSubview:wxRview];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

- (void)initTitle {
    self.title = @"微信辅助工具";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    //抢红包基本功能
    [self addBasicSettingSection];
    //抢红包高级功能
    [self addAdvanceSettingSection];
    
    [self addDiceJsbSection];
    
    //微信运动
    [self addSportSettingSection];
    //消息防止撤回
    [self addRemokeMessageSection];
    //
    [self addAboutSection];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}
#pragma mark - dice jsb
- (void)addDiceJsbSection{
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"骰子猜拳"];
    [sectionInfo addCell:[self createDiceNumEditCell]];
    [sectionInfo addCell:[self createDiceDelaySettingCell]];
    [sectionInfo addCell:[self createJsbNumEditCell]];
    [sectionInfo addCell:[self createJsbDelaySettingCell]];
    [sectionInfo addCell:[self createDiceJsbToolCell]];
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createDiceNumEditCell{
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchDiceEnvelop:) target:self title:@"骰子" on:[WBRedEnvelopConfig sharedConfig].isOpenDiceTool];
}

- (MMTableViewCellInfo *)createDiceDelaySettingCell {
    NSString *delaySeconds = [NSString stringWithFormat:@"%ld点", (long)[WBRedEnvelopConfig sharedConfig].diceNum];
    MMTableViewCellInfo *cellInfo;
    if ([WBRedEnvelopConfig sharedConfig].isOpenDiceTool) {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingDice) target:self title:@"点数" rightValue:delaySeconds  accessoryType:1];
    } else {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"点数" rightValue: @"关闭"];
    }
    return cellInfo;
}

- (void)settingDice{
    UIAlertView *alert = [UIAlertView new];
    alert.tag = 3333;
    alert.title = @"点数设置";
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].placeholder = @"设置点数 1 - 6";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (void)switchDiceEnvelop:(UISwitch *)envelopSwitch {
    [WBRedEnvelopConfig sharedConfig].isOpenDiceTool = envelopSwitch.on;
    [self reloadTableData];
}


- (MMTableViewCellInfo *)createJsbNumEditCell{
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchJsbEnvelop:) target:self title:@"猜拳" on:[WBRedEnvelopConfig sharedConfig].isOpenJsb];
}

- (MMTableViewCellInfo *)createJsbDelaySettingCell {
    
    NSString *delaySeconds;
    switch ([WBRedEnvelopConfig sharedConfig].jsbNum) {
        case 1:
            delaySeconds = @"剪刀";
            break;
        case 2:
            delaySeconds = @"石头";
            break;
        case 3:
            delaySeconds = @"布";
            break;
            
        default:
            break;
    }
    MMTableViewCellInfo *cellInfo;
    if ([WBRedEnvelopConfig sharedConfig].isOpenJsb) {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingJsb) target:self title:@"状态" rightValue:delaySeconds  accessoryType:1];
    } else {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"状态" rightValue: @"关闭"];
    }
    return cellInfo;
}

- (void)switchJsbEnvelop:(UISwitch *)envelopSwitch {
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].isOpenJsb = envelopSwitch.on;
    [self reloadTableData];
}

- (void)settingJsb{
    UIAlertView *alert = [UIAlertView new];
    alert.tag = 4444;
    alert.title = @"数猜拳设置";
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].placeholder = @"1-剪刀  2-石头  3-布";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (MMTableViewCellInfo *)createDiceJsbToolCell{
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchToolEnvelop:) target:self title:@"快捷更改菜单" on:[WBRedEnvelopConfig sharedConfig].shortcutTool];
}

- (void)switchToolEnvelop:(UISwitch *)envelopSwitch {
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [WBRedEnvelopConfig sharedConfig].shortcutTool = envelopSwitch.on;
    if (envelopSwitch.on) {
        [[ZToolView sharedZToolView]show];
    }else{
        [[ZToolView sharedZToolView]hide];
    }
    [self reloadTableData];
}


#pragma mark - WeChatSport
- (void)addSportSettingSection{
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"微信运动步数修改"];
    
    [sectionInfo addCell:[self createSportNumEditCell]];
    [sectionInfo addCell:[self createSportDelaySettingCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createSportNumEditCell{
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchSportEnvelop:) target:self title:@"微信运动修改" on:[WBRedEnvelopConfig sharedConfig].isSetSportNumber];
}

- (void)switchSportEnvelop:(UISwitch *)envelopSwitch {
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].isSetSportNumber = envelopSwitch.on;
    [self reloadTableData];
}

- (MMTableViewCellInfo *)createSportDelaySettingCell {
    NSString *delaySeconds = [NSString stringWithFormat:@"%ld步", (long)[WBRedEnvelopConfig sharedConfig].sportNumber];
    MMTableViewCellInfo *cellInfo;
    if ([WBRedEnvelopConfig sharedConfig].isSetSportNumber) {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingSportDelay) target:self title:@"微信运动步数" rightValue:delaySeconds  accessoryType:1];
    } else {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"微信运动步数" rightValue: @"关闭"];
    }
    return cellInfo;
}

- (void)settingSportDelay {
    UIAlertView *alert = [UIAlertView new];
    alert.tag = 1111;
    alert.title = @"微信运动（步）";
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].placeholder = @"运动步数";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}



#pragma mark - BasicSetting

- (void)addBasicSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"抢红包设置"];
    
    [sectionInfo addCell:[self createAutoReceiveRedEnvelopCell]];
    [sectionInfo addCell:[self createDelaySettingCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}


- (MMTableViewCellInfo *)createAutoReceiveRedEnvelopCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"自动抢红包" on:[WBRedEnvelopConfig sharedConfig].autoReceiveEnable];
}

- (MMTableViewCellInfo *)createDelaySettingCell {
    NSInteger delaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;
    NSString *delayString = delaySeconds == 0 ? @"不延迟" : [NSString stringWithFormat:@"%ld 秒", (long)delaySeconds];
    
    MMTableViewCellInfo *cellInfo;
    if ([WBRedEnvelopConfig sharedConfig].autoReceiveEnable) {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue: delayString accessoryType:1];
    } else {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"延迟抢红包" rightValue: @"抢红包已关闭"];
    }
    return cellInfo;
}

- (void)switchRedEnvelop:(UISwitch *)envelopSwitch {
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].autoReceiveEnable = envelopSwitch.on;
    
    [self reloadTableData];
}

- (void)settingDelay {
    UIAlertView *alert = [UIAlertView new];
    alert.title = @"延迟抢红包(秒)";
    alert.tag = 2222;
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].placeholder = @"延迟时长";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    switch (alertView.tag) {
        case 2222:
        {
            if (buttonIndex == 1) {
                NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
                NSInteger delaySeconds = [delaySecondsString integerValue];
                [WBRedEnvelopConfig sharedConfig].delaySeconds = delaySeconds;
            }
        }
            break;
        case 1111:
        {
            if (buttonIndex == 1) {
                NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
                NSInteger delaySeconds = [delaySecondsString integerValue];
                [WBRedEnvelopConfig sharedConfig].sportNumber = delaySeconds;
            }
        }
            break;
        case 3333:
        {
            if (buttonIndex == 1) {
                NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
                NSInteger delaySeconds = [delaySecondsString integerValue];
                [WBRedEnvelopConfig sharedConfig].diceNum = delaySeconds;
            }
        }
            break;
        case 4444:
        {
            if (buttonIndex == 1) {
                NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
                NSInteger delaySeconds = [delaySecondsString integerValue];
                [WBRedEnvelopConfig sharedConfig].jsbNum = delaySeconds;
            }
        }
            break;
        case 5555:
        {
            if (buttonIndex == 1) {
                NSString *delaySecondsString = [alertView textFieldAtIndex:0].text;
                NSInteger delaySeconds = [delaySecondsString floatValue];
                [WBRedEnvelopConfig sharedConfig].refreshFrequency = delaySeconds;
            }
        }
            break;
            
        default:
            break;
    }
    [self reloadTableData];
}

#pragma mark - ProSetting
- (void)addAdvanceSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"抢红包高级功能"];
    
    [sectionInfo addCell:[self createReceiveSelfRedEnvelopCell]];
    [sectionInfo addCell:[self createQueueCell]];
    [sectionInfo addCell:[self createBlackListCell]];
    [sectionInfo addCell:[self createIsMianNumCell]];
    [sectionInfo addCell:[self createNoMianNumCell]];
    [sectionInfo addCell:[self createScanThunderCell]];
    [sectionInfo addCell:[self createDoubleScanThunderCell]];
    [sectionInfo addCell:[self createScanSmallTailCell]];
    [sectionInfo addCell:[self createMantissaComeCell]];
    [sectionInfo addCell:[self createMaximumCell]];
    [sectionInfo addCell:[self createRefreshFrequencyCell]];
    [sectionInfo addCell:[self createEndQueryCell]];
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createReceiveSelfRedEnvelopCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingReceiveSelfRedEnvelop:) target:self title:@"抢自己发的红包" on:[WBRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop];
}

- (MMTableViewCellInfo *)createIsMianNumCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingIsMianNum:) target:self title:@"设置为主号" on:[WBRedEnvelopConfig sharedConfig].isMainNum];
}

- (MMTableViewCellInfo *)createNoMianNumCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingNoMianNum:) target:self title:@"设置为辅号" on:[WBRedEnvelopConfig sharedConfig].isSubNum];
}

- (MMTableViewCellInfo *)createScanThunderCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingScanThunderNum:) target:self title:@"尾包扫雷（单）" on:[WBRedEnvelopConfig sharedConfig].isScanThunder];
}

- (MMTableViewCellInfo *)createDoubleScanThunderCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingDoubleScanThunderNum:) target:self title:@"尾包扫雷（双）" on:[WBRedEnvelopConfig sharedConfig].isDoubleScanThunder];
}

- (MMTableViewCellInfo *)createScanSmallTailCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingScanSmallTaiNum:) target:self title:@"最小红包接龙" on:[WBRedEnvelopConfig sharedConfig].isScanSmallTail];
}

- (MMTableViewCellInfo *)createMantissaComeCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingScanMantissaComeNum:) target:self title:@"最小尾数红包接龙" on:[WBRedEnvelopConfig sharedConfig].isScanMantissaCome];
}

- (MMTableViewCellInfo *)createMaximumCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingMaximum:) target:self title:@"手气最佳接龙" on:[WBRedEnvelopConfig sharedConfig].isMaximum];
}

- (MMTableViewCellInfo *)createRefreshFrequencyCell{
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(RefreshFrequency) target:self title:@"查询详情间隔(毫秒)" rightValue:[NSString stringWithFormat:@"%.2f",[WBRedEnvelopConfig sharedConfig].refreshFrequency] accessoryType:1];
}

- (MMTableViewCellInfo *)createEndQueryCell{
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingIsEndQuery:) target:self title:@"收到新包结束之前查询" on:[WBRedEnvelopConfig sharedConfig].endQuery];
    
}

- (void)RefreshFrequency{
    UIAlertView *alert = [UIAlertView new];
    alert.tag = 5555;
    alert.title = @"查询详情间隔";
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.delegate = self;
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    
    [alert textFieldAtIndex:0].placeholder = @"输入毫秒 1秒=1000毫秒";
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
    
}

- (void)settingMaximum:(UISwitch *)receiveSwitch{
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].isMaximum = receiveSwitch.on;
    if ([WBRedEnvelopConfig sharedConfig].isMaximum) {
        [WBRedEnvelopConfig sharedConfig].isScanThunder = NO;
        [WBRedEnvelopConfig sharedConfig].isScanSmallTail = NO;
        [WBRedEnvelopConfig sharedConfig].isDoubleScanThunder = NO;
        [WBRedEnvelopConfig sharedConfig].isScanMantissaCome = NO;
    }
    [self reloadTableData];
}

- (void)settingIsEndQuery:(UISwitch *)receiveSwitch{
    [WBRedEnvelopConfig sharedConfig].endQuery = receiveSwitch.on;
}

- (void)settingDoubleScanThunderNum:(UISwitch *)receiveSwitch{
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].isDoubleScanThunder = receiveSwitch.on;
    if ([WBRedEnvelopConfig sharedConfig].isDoubleScanThunder) {
        [WBRedEnvelopConfig sharedConfig].isScanSmallTail = NO;
        [WBRedEnvelopConfig sharedConfig].isScanMantissaCome = NO;
        [WBRedEnvelopConfig sharedConfig].isScanThunder = NO;
        [WBRedEnvelopConfig sharedConfig].isMaximum = NO;
        
    }
    [self reloadTableData];
}


- (void)settingScanThunderNum:(UISwitch *)receiveSwitch{
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].isScanThunder = receiveSwitch.on;
    if ([WBRedEnvelopConfig sharedConfig].isScanThunder) {
        [WBRedEnvelopConfig sharedConfig].isScanSmallTail = NO;
        [WBRedEnvelopConfig sharedConfig].isScanMantissaCome = NO;
        [WBRedEnvelopConfig sharedConfig].isDoubleScanThunder = NO;
        [WBRedEnvelopConfig sharedConfig].isMaximum = NO;
    }
    [self reloadTableData];
}

- (void)settingScanSmallTaiNum:(UISwitch *)receiveSwitch{
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].isScanSmallTail = receiveSwitch.on;
    if ([WBRedEnvelopConfig sharedConfig].isScanSmallTail) {
        [WBRedEnvelopConfig sharedConfig].isScanThunder = NO;
        [WBRedEnvelopConfig sharedConfig].isScanMantissaCome = NO;
        [WBRedEnvelopConfig sharedConfig].isDoubleScanThunder = NO;
        [WBRedEnvelopConfig sharedConfig].isMaximum = NO;
    }
    [self reloadTableData];
}

- (void)settingScanMantissaComeNum:(UISwitch *)receiveSwitch{
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].isScanMantissaCome = receiveSwitch.on;
    if ([WBRedEnvelopConfig sharedConfig].isScanMantissaCome) {
        [WBRedEnvelopConfig sharedConfig].isScanThunder = NO;
        [WBRedEnvelopConfig sharedConfig].isScanSmallTail = NO;
        [WBRedEnvelopConfig sharedConfig].isDoubleScanThunder = NO;
        [WBRedEnvelopConfig sharedConfig].isMaximum = NO;
    }
    [self reloadTableData];
}


- (void)settingIsMianNum:(UISwitch *)receiveSwitch{
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].isMainNum = receiveSwitch.on;
    if ([WBRedEnvelopConfig sharedConfig].isMainNum) {
        [[HBLocalConnection sharedLocalConnection] serverStart];
    }else{
        [[HBLocalConnection sharedLocalConnection] serverStop];
    }
    
}

- (void)settingNoMianNum:(UISwitch *)receiveSwitch{
    if (![[BKlKeychainManager valueForKey:MACHINEKey]isEqualToString:@"1"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现异常" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [WBRedEnvelopConfig sharedConfig].isSubNum = receiveSwitch.on;
    [HBLocalConnection sharedLocalConnection];
    if ([WBRedEnvelopConfig sharedConfig].isSubNum ) {
        [[HBLocalConnection sharedLocalConnection] clientStart];
    }else{
        [[HBLocalConnection sharedLocalConnection] clientStop];
    }
}



- (MMTableViewCellInfo *)createQueueCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingReceiveByQueue:) target:self title:@"防止同时抢多个红包" on:[WBRedEnvelopConfig sharedConfig].serialReceive];
}

- (MMTableViewCellInfo *)createBlackListCell {
    
    if ([WBRedEnvelopConfig sharedConfig].blackList.count == 0) {
        return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showBlackList) target:self title:@"黑名单" rightValue:@"已关闭" accessoryType:1];
    } else {
        NSString *blackListCountStr = [NSString stringWithFormat:@"已选 %lu 个群", (unsigned long)[WBRedEnvelopConfig sharedConfig].blackList.count];
        return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showBlackList) target:self title:@"黑名单" rightValue:blackListCountStr accessoryType:1];
    }
    
}

#pragma mark - 消息防止撤销
- (void)addRemokeMessageSection{
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"撤回拦截"];
    [sectionInfo addCell:[self createAbortRemokeMessageCell]];
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewSectionInfo *)createAbortRemokeMessageCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingMessageRevoke:) target:self title:@"拦截消息撤回" on:[WBRedEnvelopConfig sharedConfig].revokeEnable];
}

- (void)settingReceiveSelfRedEnvelop:(UISwitch *)receiveSwitch {
    [WBRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop = receiveSwitch.on;
}

- (void)settingReceiveByQueue:(UISwitch *)queueSwitch {
    [WBRedEnvelopConfig sharedConfig].serialReceive = queueSwitch.on;
}

- (void)showBlackList {
    WBMultiSelectGroupsViewController *contactsViewController = [[WBMultiSelectGroupsViewController alloc] initWithBlackList:[WBRedEnvelopConfig sharedConfig].blackList];
    contactsViewController.delegate = self;
    
    MMUINavigationController *navigationController = [[objc_getClass("MMUINavigationController") alloc] initWithRootViewController:contactsViewController];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)settingMessageRevoke:(UISwitch *)revokeSwitch {
    [WBRedEnvelopConfig sharedConfig].revokeEnable = revokeSwitch.on;
}


#pragma mark - About
- (void)addAboutSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    [sectionInfo addCell:[self createStopCell]];
    [sectionInfo addCell:[self createAboutCell]];
    [self.tableViewInfo addSection:sectionInfo];
}

- (MMTableViewCellInfo *)createAboutCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showAbout) target:self title:@"关于" rightValue: @"version 1.0" accessoryType:1];
}

- (MMTableViewCellInfo *)createStopCell {
    
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(stopStopTask) target:self title:@"点击停止当前后台所有红包监听" accessoryType:1];
}

- (void)stopStopTask{
    if ([WXHongBaoOpeartionMgr shareInstance].taskList.count > 0) {
        NSArray *array = [[WXHongBaoOpeartionMgr shareInstance].messageList mutableCopy];
        for (int i = 0; i < array.count; i++) {
            [[WXHongBaoOpeartionMgr shareInstance].messageList removeObject:array[i]];
            [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:array[i]];
        }
        
    }
}

- (void)showAbout{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"关于" message:[NSString stringWithFormat:@"仅供学习交流，切勿用于非法用途\n%@-%@\nE-mail:zhangfeng0080@126.com",@"反检查成功", [NSBundle mainBundle].bundleIdentifier] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
}



#pragma mark - MultiSelectGroupsViewControllerDelegate
- (void)onMultiSelectGroupCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)onMultiSelectGroupReturn:(NSArray *)arg1 {
    [WBRedEnvelopConfig sharedConfig].blackList = arg1;
    
    [self reloadTableData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
