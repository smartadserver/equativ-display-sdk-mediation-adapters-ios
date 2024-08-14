//
//  SASOguryBannerAdapter.swift
//  Equativ
//
//  Created by Loic GIRON DIT METAZ on 24/05/2024.
//  Copyright © 2024 Equativ. All rights reserved.
//

import SASDisplayKit
import OguryAds
import OgurySdk

/**
 Ogury banner adapter class for Equativ SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Equativ.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Equativ SDK if needed.
 */
@objc(SASOguryBannerAdapter)
class SASOguryBannerAdapter: SASOguryBaseAdapter, SASMediationBannerAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Equativ Display SDK.
    weak var delegate: SASMediationBannerAdapterDelegate?
    
    /// The name of the mediated SDK.
    var sdkName: String = "Ogury SDK"
    
    /// The version of the mediated SDK.
    var sdkVersion: String = Ogury.getSdkVersion()
    
    /// The version of the mediation adapter.
    var adapterVersion: String = "1.0.0"
    
    /// The currently loaded Ogury banner if any, nil otherwise.
    private var oguryBannerView: OguryBannerAd? = nil
    
    func loadAd(withServerSideParameters serverSideParameters: String, clientSideParameters: [String : Any]?) {
        // Ogury configuration
        configureOgurySDK(serverParameterString: serverSideParameters, clientParameters: clientSideParameters) { [self] error in
            if let error = error {
                
                // Configuration can fail if the serverParameterString is invalid or if the Ogury SDK does not initialize properly.
                
                // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
                // waterfall will not work properly and the ad loading will fail with a timeout.
                
                delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
                
            } else {
                
                // Checking the bannerSize parameter
                guard let bannerSize = bannerSize else {
                    // Configuration can fail if the serverParameterString does not contains a valid banner size.
                    
                    // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
                    // waterfall will not work properly and the ad loading will fail with a timeout.
                    
                    let error = NSError(
                        domain: ErrorConstants.errorDomain,
                        code: ErrorConstants.errorCodeInvalidParameterString,
                        userInfo: [NSLocalizedDescriptionKey: "Ogury Banner - Invalid server parameter string: \(serverSideParameters)"]
                    )
                    delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
                    
                    return
                }
                
                // Banner loading…
                oguryBannerView = OguryBannerAd(adUnitId: adUnitId!)
                oguryBannerView?.delegate = self
                oguryBannerView?.load(with: bannerSize)
            }
        }
    }
    
}

/**
 Ogury delegate implementation.
 */
extension SASOguryBannerAdapter : OguryBannerAdDelegate {
    func didLoad(_ banner: OguryBannerAd) {
        // The successful loading of the mediation ad must be reported to the adapter delegate, otherwise the ad
        // will not be displayed and the ad loading will fail with a timeout.
        
        delegate?.mediationBannerAdapter(self, didLoadAdWithMediatedView: banner, width: nil, height: nil)
    }
    
    func didFailOguryBannerAdWithError(_ error: OguryError, for banner: OguryBannerAd) {
        // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
        // waterfall will not work properly and the ad loading will fail with a timeout.
        
        let error = NSError(
            domain: ErrorConstants.errorDomain,
            code: ErrorConstants.errorCodeAdError,
            userInfo: [NSLocalizedDescriptionKey: "Ogury Banner - Ad failed with error: \(error)"]
        )
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: (error.code == ErrorConstants.oguryNoAdErrorCode))
    }
    
    func didDisplay(_ banner: OguryBannerAd) { }
    
    func didClick(_ banner: OguryBannerAd) {
        // A click on the ad should be reported to the adapter delegate (if permitted by the third party SDK):
        // this will ensure proper click reporting in Equativ Management Platform (EMP).
        
        delegate?.mediationBannerAdapterDidReceiveAdClickEvent(self)
    }
    
    func didClose(_ banner: OguryBannerAd) { }
    
    func didTriggerImpressionOguryBannerAd(_ banner: OguryBannerAd) { }
    
    func presentingViewController(forOguryAdsBannerAd banner: OguryBannerAd) -> UIViewController {
        // You can retrieve the parent view controller of the SASBannerView instance loading the mediation ad
        // if required by the third party SDK.
        // Note: avoid caching the value because it can change during the banner view lifecycle.
        
        return delegate?.modalParentViewController ?? UIViewController()
    }
}
