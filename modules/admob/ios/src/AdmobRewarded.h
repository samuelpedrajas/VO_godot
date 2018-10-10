#import "app_delegate.h"
#include "core/reference.h"
#import <GoogleMobileAds/GADRewardBasedVideoAdDelegate.h>


@interface AdmobRewarded: UIViewController <GADRewardBasedVideoAdDelegate> {
	bool isLoading;
    bool initialized;
    bool isReal;
    int instanceId;
    Object *obj;
    ViewController *rootController;
}

- (void)initialize:(BOOL)is_real: (int)instance_id;
- (void)loadRewardedVideo:(NSString*)rewardedId;
- (void)showRewardedVideo;

@end
