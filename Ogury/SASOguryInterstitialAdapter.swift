//
//  SASOguryInterstitialAdapter.swift
//  Equativ
//
//  Created by Loic GIRON DIT METAZ on 24/05/2024.
//  Copyright © 2024 Equativ. All rights reserved.
//

import SASDisplayKit
import OguryAds
import OgurySdk

/**
 Ogury interstitial adapter class for Equativ SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Equativ.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Equativ SDK if needed.
 */
@objc(SASOguryInterstitialAdapter)
class SASOguryInterstitialAdapter: SASOguryBaseAdapter, SASMediationInterstitialAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Equativ Display SDK.
    weak var delegate: SASMediationInterstitialAdapterDelegate?
    
    /// The name of the mediated SDK.
    var sdkName: String = "Ogury SDK"
    
    /// The version of the mediated SDK.
    var sdkVersion: String = Ogury.getSdkVersion()
    
    /// The version of the mediation adapter.
    var adapterVersion: String = "1.0.0"
    
    /// The currently loaded Ogury interstitial if any, nil otherwise.
    private var interstitial: OguryInterstitialAd? = nil
    
    func loadAd(withServerSideParameters serverSideParameters: String, clientSideParameters: [String : Any]?) {
        // Ogury configuration
        configureOgurySDK(serverParameterString: serverSideParameters, clientParameters: clientSideParameters) { [self] error in
            if let error = error {
                
                // Configuration can fail if the serverParameterString is invalid or if the Ogury SDK does not initialize properly.
                
                // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
                // waterfall will not work properly and the ad loading will fail with a timeout.
                
                delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError: error, noFill: false)
                
            } else {
                
                // Interstitial instantiation and loading…
                interstitial = OguryInterstitialAd(adUnitId: adUnitId!)
                interstitial?.delegate = self

                interstitial?.load()
                
            }
        }
    }
    
    func show(withModalParentViewController modalParentViewController: UIViewController) {
        // Showing Ogury's interstitial when requested by Equativ SDK
        interstitial?.show(in: modalParentViewController)
    }
}

/**
 Ogury delegate implementation.
 */
extension SASOguryInterstitialAdapter: OguryInterstitialAdDelegate {
    
    func didLoad(_ interstitial: OguryInterstitialAd) {
        // The successful loading of the mediation ad must be reported to the adapter delegate, otherwise the ad
        // will not be displayed and the ad loading will fail with a timeout.
        
        delegate?.mediationInterstitialAdapterDidLoadAd(self)
    }
    
    func didFailOguryInterstitialAdWithError(_ error: OguryError, for interstitial: OguryInterstitialAd) {
        // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
        // waterfall will not work properly and the ad loading will fail with a timeout.
        
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdError,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Interstitial - Ad failed with error: \(error)"]
        )
        delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError: error, noFill: (error.code == ErrorConstants.oguryNoAdErrorCode))
    }
    
    func didDisplay(_ interstitial: OguryInterstitialAd) {
        // The successful show of the interstitial ad must be reported to the adapter delegate:
        // this will ensure proper impression reporting in Equativ Management Platform (EMP).
        
        delegate?.mediationInterstitialAdapterDidShow(self)
    }
    
    func didClose(_ interstitial: OguryInterstitialAd) {
        // The closing of the interstitial ad must be reported to the adapter delegate: this will allow
        // the SASInterstitialManager instance to report the closing of the ad to the app and reset itself for
        // the next ad loading.
        
        delegate?.mediationInterstitialAdapterDidClose(self)
    }
    
    func didClick(_ interstitial: OguryInterstitialAd) {
        // A click on the ad should be reported to the adapter delegate (if permitted by the third party SDK):
        // this will ensure proper click reporting in Equativ Management Platform (EMP).
        
        delegate?.mediationInterstitialAdapterDidReceiveAdClickEvent(self)
    }
    
    func didTriggerImpressionOguryInterstitialAd(_ interstitial: OguryInterstitialAd) { }
}
