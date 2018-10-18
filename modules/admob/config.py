def can_build(env, plat):
	return plat=="android" or plat=="iphone"


def configure(env):
	if (env['platform'] == 'android'):
		env.android_add_default_config("applicationId 'com.vegames.veganodyssey'")
		env.android_add_dependency("compile 'com.google.android.gms:play-services-ads:+'")
		env.android_add_dependency("compile 'com.unity3d.ads:unity-ads:2.3.0'")
		env.android_add_dependency("compile 'com.google.ads.mediation:unity:2.3.0.0'")
		env.android_add_dependency("compile 'com.google.code.gson:gson:2.8.4'")
		env.android_add_dependency("compile (name:'consent-library-release', ext:'aar')")

		env.android_add_java_dir("android")
		env.android_add_to_manifest("android/AndroidManifestChunk.xml")
		env.disable_module()
            
	if env['platform'] == "iphone":
		env.Append(FRAMEWORKPATH=['modules/admob/ios/lib'])
		env.Append(LINKFLAGS=['-ObjC', '-framework','AdSupport', '-framework','CoreTelephony', '-framework','EventKit', '-framework','EventKitUI', '-framework','MessageUI', '-framework','StoreKit', '-framework','SafariServices', '-framework','CoreBluetooth', '-framework','AssetsLibrary', '-framework','CoreData', '-framework','CoreLocation', '-framework','CoreText', '-framework','ImageIO', '-framework', 'GLKit', '-framework','CoreVideo', '-framework', 'CFNetwork', '-framework', 'MobileCoreServices', '-framework', 'GoogleMobileAds', '-framework', 'UnityAds'])
