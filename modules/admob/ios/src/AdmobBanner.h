#import <GoogleMobileAds/GADBannerView.h>
#import <sys/utsname.h>
#import "app_delegate.h"

@interface AdmobBanner: UIViewController <GADBannerViewDelegate> {
    GADBannerView *bannerView;
    bool initialized;
    bool isReal;
    bool isOnTop;
    int instanceId;
    ViewController *rootController;
}

- (void)initialize:(BOOL)is_real: (int)instance_id;
- (void)loadBanner:(NSString*)bannerId :(BOOL)is_on_top;
- (void)showBanner;
- (void)hideBanner;
- (void)resize;
- (CGFloat)pointsToPixels:(int)points:(int)screenHeight;
- (int)getBannerHeight:(int)screenHeight;

@end
