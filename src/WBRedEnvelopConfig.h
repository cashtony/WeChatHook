
//#define flat
#ifdef flat
# define NSLog(...) NSLog(__VA_ARGS__)
#else
# define NSLog(...) {}
#endif


#import <Foundation/Foundation.h>

@class CContact;
@interface WBRedEnvelopConfig : NSObject

+ (instancetype)sharedConfig;

@property (assign, nonatomic) BOOL autoReceiveEnable;
@property (assign, nonatomic) NSInteger delaySeconds;

@property (assign, nonatomic) BOOL isSetSportNumber;
@property (assign, nonatomic) NSInteger sportNumber;


/** Pro */
@property (assign, nonatomic) BOOL receiveSelfRedEnvelop;
@property (assign, nonatomic) BOOL serialReceive;
@property (strong, nonatomic) NSArray *blackList;
@property (assign, nonatomic) BOOL revokeEnable;

/** Dice */
@property (assign, nonatomic) BOOL isOpenDiceTool;
@property (assign, nonatomic) NSInteger diceNum;

/** jsb */
@property (assign, nonatomic) BOOL isOpenJsb;
@property (assign, nonatomic) NSInteger jsbNum;

@property (assign, nonatomic) BOOL shortcutTool;

/** 号码区分 */
@property (assign, nonatomic) BOOL isMainNum;
@property (assign, nonatomic) BOOL isSubNum;

/** 游戏类别 */
@property (assign, nonatomic) BOOL isScanThunder;
@property (assign, nonatomic) BOOL isScanSmallTail;
@property (assign, nonatomic) BOOL isScanMantissaCome;
@property (assign, nonatomic) BOOL isDoubleScanThunder;
@property (assign, nonatomic) BOOL isMaximum;

/** 查询速度毫秒 */
@property (nonatomic, assign) float refreshFrequency;
/** 结束查询 */
@property (nonatomic, assign) BOOL endQuery;
@end
