//
//  SASGMAInterstitialAdapter.swift
//  Equativ
//
//  Created by Loïc GIRON DIT METAZ on 10/06/2024.
//  Copyright © 2024 Equativ. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SASDisplayKit

/**
 Google Mobile Ads interstitial adapter class for Equativ SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Equativ.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Equativ SDK if needed.
 */
@objc(SASGMAInterstitialAdapter)
class SASGMAInterstitialAdapter : SASGMABaseAdapter, SASMediationInterstitialAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Equativ SDK.
    weak var delegate: (any SASMediationInterstitialAdapterDelegate)?
    
    /// The name of the mediated SDK.
    var sdkName: String = "Google Mobile Ads"
    
    /// The version of the mediated SDK.
    var sdkVersion: String = GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber)
    
    /// The version of the mediation adapter.
    var adapterVersion: String = "1.0.0"
    
    /// The currently loaded Google Mobile Ads interstitial if any, nil otherwise.
    private var interstitial: GADInterstitialAd? = nil
    
    func loadAd(withServerSideParameters serverSideParameters: String, clientSideParameters: [String : Any]?) {
        // Parameter retrieval and validation
        do {
            let (gmaType, adUnitID) = try configureGoogleMobileAds(serverParameterString: serverSideParameters)
            
            switch (gmaType) {
            case .adManager:
                // Create Google Ad Request
                let request = request(clientSideParameters: clientSideParameters) as GAMRequest
                
                // Perform ad request
                GAMInterstitialAd.load(withAdManagerAdUnitID: adUnitID, request: request) { [self] interstitialAd, error in
                    if let error = error as NSError? {
                        // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
                        // waterfall will not work properly and the ad loading will fail with a timeout.
                        
                        delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError:error, noFill:(error.code == GADErrorCode.noFill.rawValue))
                    } else {
                        interstitial = interstitialAd
                        interstitial?.fullScreenContentDelegate = self
                        
                        // The successful loading of the mediation ad must be reported to the adapter delegate, otherwise the ad
                        // will not be displayed and the ad loading will fail with a timeout.

                        delegate?.mediationInterstitialAdapterDidLoadAd(self)
                    }
                }
                
            default:
                // Create Google Ad Request
                let request = request(clientSideParameters: clientSideParameters)
                
                // Perform ad request
                GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [self] interstitialAd, error in
                    if let error = error as NSError? {
                        // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
                        // waterfall will not work properly and the ad loading will fail with a timeout.
                        
                        delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError:error, noFill:(error.code == GADErrorCode.noFill.rawValue))
                    } else {
                        interstitial = interstitialAd
                        interstitial?.fullScreenContentDelegate = self
                        
                        // The successful loading of the mediation ad must be reported to the adapter delegate, otherwise the ad
                        // will not be displayed and the ad loading will fail with a timeout.
                        
                        delegate?.mediationInterstitialAdapterDidLoadAd(self)
                    }
                }
            }
        } catch {
            // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
            // waterfall will not work properly and the ad loading will fail with a timeout.
            
            delegate?.mediationInterstitialAdapter(self, didFailToLoadWithError: error, noFill: false)
            return
        }
    }
    
    func show(withModalParentViewController modalParentViewController: UIViewController) {
        interstitial?.present(fromRootViewController: modalParentViewController)
    }
}

/**
 Google Mobile Ads delegate implementation.
 */
extension SASGMAInterstitialAdapter : GADFullScreenContentDelegate {
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) { }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // The successful show of the interstitial ad must be reported to the adapter delegate:
        // this will ensure proper impression reporting in Equativ Management Platform (EMP).
        
        delegate?.mediationInterstitialAdapterDidShow(self)
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        // Failure to show the interstitial ad must be reported to the adapter delegate:
        // this will ensure that the interstitial manager API is properly reset and that the proper
        // delegates are called, so the app can try to load another ad for instance…
        
        delegate?.mediationInterstitialAdapter(self, didFailToShowWithError: error)
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // The closing of the interstitial ad must be reported to the adapter delegate: this will allow
        // the SASInterstitialManager instance to report the closing of the ad to the app and reset itself for
        // the next ad loading.
        
        delegate?.mediationInterstitialAdapterDidClose(self)
    }
    
    func adDidRecordClick(_ ad: any GADFullScreenPresentingAd) {
        // A click on the ad should be reported to the adapter delegate (if permitted by the third party SDK):
        // this will ensure proper click reporting in Equativ Management Platform (EMP).

        delegate?.mediationInterstitialAdapterDidReceiveAdClickEvent(self)
    }
    
}
