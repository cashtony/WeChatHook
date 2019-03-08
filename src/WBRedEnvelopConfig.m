

#import "WBRedEnvelopConfig.h"
#import "WeChatRedEnvelop.h"

static NSString * const kDelaySecondsKey = @"XGDelaySecondsKey";
static NSString * const kAutoReceiveRedEnvelopKey = @"XGWeChatRedEnvelopSwitchKey";
static NSString * const kReceiveSelfRedEnvelopKey = @"WBReceiveSelfRedEnvelopKey";
static NSString * const kSerialReceiveKey = @"WBSerialReceiveKey";
static NSString * const kBlackListKey = @"WBBlackListKey";
static NSString * const kRevokeEnablekey = @"WBRevokeEnable";
static NSString * const KIsSetSportNumber = @"isSetSportNumber";
static NSString * const KSportNumber = @"sportNumber";

static NSString * const KisOpenDiceTool = @"isOpenDiceTool";
static NSString * const KdiceNum = @"diceNum";
static NSString * const KisOpenJsb = @"isOpenJsb";
static NSString * const KjsbNum = @"jsbNum";
static NSString * const KshortcutTool = @"shortcutTool";
static NSString * const KisMainNum = @"isMainNum";
static NSString * const KisSubNum = @"isSubNum";
static NSString * const KisScanThunder = @"isScanThunder";
static NSString * const KisScanSmallTail = @"isScanSmallTail";
static NSString * const KrefreshFrequency = @"refreshFrequency";
static NSString * const KisScanMantissaCome = @"isScanMantissaCome";
static NSString * const KisDoubleScanThunder = @"isDoubleScanThunder";
static NSString * const KendQuery = @"endDataQuery";
static NSString * const KisMaximum = @"isMaximum";
@interface WBRedEnvelopConfig ()

@end

@implementation WBRedEnvelopConfig

+ (instancetype)sharedConfig {
    static WBRedEnvelopConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [WBRedEnvelopConfig new];
    });
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        _receiveSelfRedEnvelop = [[NSUserDefaults standardUserDefaults] boolForKey:kReceiveSelfRedEnvelopKey];
        _isSetSportNumber  = [[NSUserDefaults standardUserDefaults] boolForKey:KIsSetSportNumber];
        _sportNumber       = [[NSUserDefaults standardUserDefaults] integerForKey:KSportNumber];
        _delaySeconds      = [[NSUserDefaults standardUserDefaults] integerForKey:kDelaySecondsKey];
        _autoReceiveEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoReceiveRedEnvelopKey];
        _serialReceive     = [[NSUserDefaults standardUserDefaults] boolForKey:kSerialReceiveKey];
        _blackList         = [[NSUserDefaults standardUserDefaults] objectForKey:kBlackListKey];
        _revokeEnable      = [[NSUserDefaults standardUserDefaults] boolForKey:kRevokeEnablekey];
        _isOpenDiceTool    = [[NSUserDefaults standardUserDefaults] boolForKey:KisOpenDiceTool];
        _isOpenJsb         = [[NSUserDefaults standardUserDefaults] boolForKey:KisOpenJsb];
        _diceNum           = [[NSUserDefaults standardUserDefaults] integerForKey:KdiceNum];
        _jsbNum            = [[NSUserDefaults standardUserDefaults] integerForKey:KjsbNum];
        _shortcutTool      = [[NSUserDefaults standardUserDefaults] boolForKey:KshortcutTool];
        _isMainNum         = [[NSUserDefaults standardUserDefaults] boolForKey:KisMainNum];
        _isSubNum          = [[NSUserDefaults standardUserDefaults] boolForKey:KisSubNum];
        _isScanThunder     = [[NSUserDefaults standardUserDefaults] boolForKey:KisScanThunder];
        _isScanSmallTail   = [[NSUserDefaults standardUserDefaults] boolForKey:KisScanSmallTail];
        _refreshFrequency  = [[NSUserDefaults standardUserDefaults] floatForKey:KrefreshFrequency];
        _isScanMantissaCome = [[NSUserDefaults standardUserDefaults] floatForKey:KisScanMantissaCome];
        _isDoubleScanThunder = [[NSUserDefaults standardUserDefaults] floatForKey:KisDoubleScanThunder];
        _endQuery = [[NSUserDefaults standardUserDefaults] floatForKey:KendQuery];
        _isMaximum = [[NSUserDefaults standardUserDefaults] floatForKey:KisMaximum];

    }
    return self;
}

- (void)setIsMaximum:(BOOL)isMaximum{
    _isMaximum = isMaximum;
    [[NSUserDefaults standardUserDefaults] setFloat:_isMaximum forKey:KisMaximum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)setEndQuery:(BOOL)endQuery{
    _endQuery = endQuery;
    [[NSUserDefaults standardUserDefaults] setFloat:endQuery forKey:KendQuery];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsDoubleScanThunder:(BOOL)isDoubleScanThunder{
    _isDoubleScanThunder = isDoubleScanThunder;
    [[NSUserDefaults standardUserDefaults] setFloat:_isDoubleScanThunder forKey:KisDoubleScanThunder];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsScanMantissaCome:(BOOL)isScanMantissaCome{
    _isScanMantissaCome = isScanMantissaCome;
    [[NSUserDefaults standardUserDefaults] setFloat:_isScanMantissaCome forKey:KisScanMantissaCome];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)setRefreshFrequency:(float)refreshFrequency{
    _refreshFrequency = refreshFrequency;
    [[NSUserDefaults standardUserDefaults] setFloat:refreshFrequency forKey:KrefreshFrequency];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsScanSmallTail:(BOOL)isScanSmallTail{
    _isScanSmallTail = isScanSmallTail;
    [[NSUserDefaults standardUserDefaults] setBool:isScanSmallTail forKey:KisScanSmallTail];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsScanThunder:(BOOL)isScanThunder{
    _isScanThunder = isScanThunder;
    [[NSUserDefaults standardUserDefaults] setBool:isScanThunder forKey:KisScanThunder];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)setIsSubNum:(BOOL)isSubNum{
    _isSubNum = isSubNum;
    [[NSUserDefaults standardUserDefaults] setBool:isSubNum forKey:KisSubNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsMainNum:(BOOL)isMainNum{
    _isMainNum = isMainNum;
    [[NSUserDefaults standardUserDefaults] setBool:isMainNum forKey:KisMainNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setShortcutTool:(BOOL)shortcutTool{
    _shortcutTool = shortcutTool;
    [[NSUserDefaults standardUserDefaults] setBool:shortcutTool forKey:KshortcutTool];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsOpenDiceTool:(BOOL)isOpenDiceTool{
    _isOpenDiceTool = isOpenDiceTool;
    [[NSUserDefaults standardUserDefaults] setBool:isOpenDiceTool forKey:KisOpenDiceTool];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsOpenJsb:(BOOL)isOpenJsb{
    _isOpenJsb = isOpenJsb;
    [[NSUserDefaults standardUserDefaults] setBool:isOpenJsb forKey:KisOpenJsb];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDiceNum:(NSInteger)diceNum{
    _diceNum = diceNum;
    [[NSUserDefaults standardUserDefaults] setInteger:diceNum forKey:KdiceNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setJsbNum:(NSInteger)jsbNum{
    _jsbNum = jsbNum;
    [[NSUserDefaults standardUserDefaults] setInteger:jsbNum forKey:KjsbNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsSetSportNumber:(BOOL)isSetSportNumber{
    _isSetSportNumber = isSetSportNumber;
    [[NSUserDefaults standardUserDefaults] setBool:isSetSportNumber forKey:KIsSetSportNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSportNumber:(NSInteger)sportNumber{
    _sportNumber = sportNumber;
    [[NSUserDefaults standardUserDefaults] setInteger:sportNumber forKey:KSportNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDelaySeconds:(NSInteger)delaySeconds {
    _delaySeconds = delaySeconds;
    
    [[NSUserDefaults standardUserDefaults] setInteger:delaySeconds forKey:kDelaySecondsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReceiveEnable:(BOOL)autoReceiveEnable {
    _autoReceiveEnable = autoReceiveEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:autoReceiveEnable forKey:kAutoReceiveRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setReceiveSelfRedEnvelop:(BOOL)receiveSelfRedEnvelop {
    _receiveSelfRedEnvelop = receiveSelfRedEnvelop;
    
    [[NSUserDefaults standardUserDefaults] setBool:receiveSelfRedEnvelop forKey:kReceiveSelfRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setSerialReceive:(BOOL)serialReceive {
    _serialReceive = serialReceive;
    
    [[NSUserDefaults standardUserDefaults] setBool:serialReceive forKey:kSerialReceiveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBlackList:(NSArray *)blackList {
    _blackList = blackList;
    
    [[NSUserDefaults standardUserDefaults] setObject:blackList forKey:kBlackListKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setRevokeEnable:(BOOL)revokeEnable {
    _revokeEnable = revokeEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:revokeEnable forKey:kRevokeEnablekey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
