#ifndef GODOT_ADMOB_H
#define GODOT_ADMOB_H

#include <core/version_generated.gen.h>

#include "core/reference.h"


#ifdef __OBJC__
// @class AdmobBanner;
// typedef AdmobBanner *bannerPtr;
@class AdmobRewarded;
typedef AdmobRewarded *rewardedPtr;
@class PACConsentForm;
typedef PACConsentForm *formPtr;
#else
typedef void *bannerPtr;
typedef void *rewardedPtr;
typedef void *formPtr;
#endif



class GodotAdmob : public Reference {
    
#if VERSION_MAJOR == 3
    GDCLASS(GodotAdmob, Reference);
#else
    OBJ_TYPE(GodotAdmob, Reference);
#endif

    bool initialized;
    GodotAdmob *instance;
    
    // bannerPtr banner;
    rewardedPtr rewarded;
    formPtr form;
    Object *obj;

protected:
    static void _bind_methods();

public:

    void init(bool isReal, int instanceId);
    // void loadBanner(const String &bannerId, bool isOnTop);
    // void showBanner();
    // void hideBanner();
    // void resize();
    // int getBannerWidth();
    // int getBannerHeight();
    bool isRequestLocationInEeaOrUnknown();
    void setConsent(bool personalized_ads);
    void loadRewardedVideo(const String &rewardedId, bool personalized_ads);
    void showRewardedVideo();
    void requestConsent();
    void loadConsentForm(String _lang);
    void showConsentForm();

    GodotAdmob();
    ~GodotAdmob();
};

#endif
