# Equativ Mediation Adapters iOS

This repository contains all mediation adapters we officially support.

## Cocoapods installation

You can install the __Equativ Display SDK__, one or several mediation adapters and their related third party SDKs using _Cocoapods_.

For that, simply declare the pod ```Equativ-Display-SDK-With-Mediation``` in your _podfile_ (__instead of the regular Equativ-Display-SDK__) with the appropriate _subspec_. For instance you can import _Ogury_ like so:

```
pod 'Equativ-Display-SDK-With-Mediation/Ogury'
```

Available _subspecs_ are:

| Subspec name | Supported SDK version | Comments |
| ------------ | --------------------- | -------- |
| ```GoogleMobileAds``` | ~> 11.11.0 | _n/a_ |
| ```Ogury``` | ~> 4.2.2 | _n/a_ |

__Note:__ if you install the pod _Equativ-Display-SDK-With-Mediation_ without specifying any _subspec_, only the __Equativ Display SDK__ will be installed.

## Manual installation

You can still install the adapters manually if needed:

1. First make sure you have installed the __Equativ Display SDK__. More information [here](https://documentation.smartadserver.com/DisplaySDK8/ios/gettingstarted.html).

2. Copy and paste the classes of the adapter(s) you need to your project sources. Note that some adapter classes have a base class, do not forget to copy it as well.

3. Make sure to integrate the SDK corresponding to the chosen adapter(s).
