#import "AdmobRewarded.h"
#import <GoogleMobileAds/GADRewardBasedVideoAd.h>
#import <GoogleMobileAds/GADAdReward.h>


@implementation AdmobRewarded


- (void)initialize:(BOOL)is_real: (int)instance_id {
    isLoading = false;
    isReal = is_real;
    initialized = true;
    instanceId = instance_id;
    rootController = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    obj = ObjectDB::get_instance(instanceId);
}

- (void) loadRewardedVideo:(NSString*) rewardedId {
    NSLog(@"Calling loadRewardedVideo");
    //init
    if (!initialized || [[GADRewardBasedVideoAd sharedInstance] isReady] || isLoading) {
        return;
    }
    isLoading = true;
    [GADRewardBasedVideoAd sharedInstance].delegate = self;

    if(!isReal) {
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request]
                                               withAdUnitID:@"ca-app-pub-3940256099942544/1712485313"];
    } else {
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:[GADRequest request] withAdUnitID:rewardedId];
    }
}

- (void) showRewardedVideo {
    NSLog(@"Calling showRewardedVideo");
    isLoading = false;
    //init
    if (!initialized) {
        return;
    }
    
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:rootController];
    }
    
}


- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf",
                                reward.type, [reward.amount doubleValue]];
    NSLog(rewardMessage);

    obj->call_deferred("_on_rewarded", [reward.type UTF8String], reward.amount.doubleValue);
                                        
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");
    obj->call_deferred("_on_rewarded_video_ad_loaded");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
    obj->call_deferred("_on_rewarded_video_ad_closed");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load: %@ ", error.localizedDescription);
    isLoading = false;
    obj->call_deferred("_on_rewarded_video_ad_failed_to_load", (int)error.code);
}

@end
