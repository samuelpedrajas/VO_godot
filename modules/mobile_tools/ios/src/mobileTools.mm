#include "mobileTools.h"


#import "app_delegate.h"
import StoreKit


MobileTools::MobileTools() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
}

MobileTools::~MobileTools() {
    instance = NULL;
}



void MobileTools::shareText(const String &title, const String &subject, const String &text) {
    
    ViewController *root_controller = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    NSString * message = [NSString stringWithCString:text.utf8().get_data() encoding:NSUTF8StringEncoding];
    
    NSArray * shareItems = @[message];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    
    [root_controller presentViewController:avc animated:YES completion:nil];

}

void MobileTools::sharePic(const String &path, const String &title, const String &subject, const String &text) {
    ViewController *root_controller = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    NSString * message = [NSString stringWithCString:text.utf8().get_data() encoding:NSUTF8StringEncoding];
    NSString * imagePath = [NSString stringWithCString:path.utf8().get_data() encoding:NSUTF8StringEncoding];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    NSArray * shareItems = @[message, image];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    
    [root_controller presentViewController:avc animated:YES completion:nil];
}

bool MobileTools::rateApp() {
    if #available(iOS 10.3, *) {
        SKStoreReviewController.requestReview()
    } else {
        return false
    }
    return true;
}

void MobileTools::_bind_methods() {
#if VERSION_MAJOR == 3
    ClassDB::bind_method(D_METHOD("shareText"), &MobileTools::shareText);
    ClassDB::bind_method(D_METHOD("sharePic"), &MobileTools::sharePic);
    ClassDB::bind_method(D_METHOD("rateApp"), &MobileTools::rateApp);
#else
    ObjectTypeDB::bind_method("shareText", &MobileTools::shareText);
    ObjectTypeDB::bind_method("sharePic", &MobileTools::sharePic);
    ObjectTypeDB::bind_method("rateApp", &MobileTools::rateApp);
#endif
    
}
