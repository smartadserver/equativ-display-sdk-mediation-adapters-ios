//
//  SASGMABannerAdapter.swift
//  Equativ
//
//  Created by Loïc GIRON DIT METAZ on 10/06/2024.
//  Copyright © 2024 Equativ. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SASDisplayKit

/**
 Google Mobile Ads banner adapter class for Equativ SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Equativ.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Smart SDK if needed.
 */
@objc(SASGMABannerAdapter)
class SASGMABannerAdapter : SASGMABaseAdapter, SASMediationBannerAdapter {
    
    /// A delegate that this adapter must call to provide information about the ad loading status or events to the Equativ SDK.
    weak var delegate: (any SASMediationBannerAdapterDelegate)?
    
    /// The name of the mediated SDK.
    var sdkName: String = "Google Mobile Ads"
    
    /// The version of the mediated SDK.
    var sdkVersion: String = GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber)
    
    /// The version of the mediation adapter.
    var adapterVersion: String = "1.0.0"

    /// The currently loaded Google Mobile Ads banner if any, nil otherwise
    private var bannerView: GADBannerView? = nil
    
    func loadAd(withServerSideParameters serverSideParameters: String, clientSideParameters: [String : Any]?) {
        // Parameter retrieval and validation
        do {
            let (gmaType, adUnitID) = try configureGoogleMobileAds(serverParameterString: serverSideParameters)
            
            let adSize = bannerSize(serverParameterString: serverSideParameters)
            switch (gmaType) {
                case .adManager:
                    bannerView = GAMBannerView(adSize: adSize)
                default:
                    bannerView = GADBannerView(adSize: adSize)
            }
            
            // Banner configuration
            bannerView?.delegate = self
            bannerView?.adUnitID = adUnitID
            bannerView?.rootViewController = delegate?.modalParentViewController
            
            // Create Google Ad Request
            let request = request(clientSideParameters: clientSideParameters)
            
            // Perform ad request
            bannerView?.load(request)
        } catch {
            // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
            // waterfall will not work properly and the ad loading will fail with a timeout.
            
            delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: false)
        }
    }
    
    private func bannerSize(serverParameterString: String) -> GADAdSize {
        // IDs are sent as a slash separated string
        let serverParameters = serverParameterString.split(separator: "|")
        
        // Extracting banner size
        guard serverParameters.count > 2, let bannerSizeInt = Int(serverParameters[2]) else {
            return GADAdSizeBanner
        }
        
        switch (bannerSizeInt) {
        case 1:
            return GADAdSizeMediumRectangle
        case 2:
            return GADAdSizeLeaderboard
        case 3:
            return GADAdSizeLargeBanner
        default:
            return GADAdSizeBanner
        }
        
    }
    
}

/**
 Google Mobile Ads delegate implementation.
 */
extension SASGMABannerAdapter : GADBannerViewDelegate {
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        // The successful loading of the mediation ad must be reported to the adapter delegate, otherwise the ad
        // will not be displayed and the ad loading will fail with a timeout.

        delegate?.mediationBannerAdapter(self, didLoadAdWithMediatedView: bannerView, width: nil, height: nil)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        // The loading failure of the mediation ad must be reported to the adapter delegate, otherwise the mediation
        // waterfall will not work properly and the ad loading will fail with a timeout.
        
        let noFill = ((error as NSError).code == GADErrorCode.noFill.rawValue)
        delegate?.mediationBannerAdapter(self, didFailToLoadWithError: error, noFill: noFill)
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        // A click on the ad should be reported to the adapter delegate (if permitted by the third party SDK):
        // this will ensure proper click reporting in Equativ Management Platform (EMP).
        
        delegate?.mediationBannerAdapterDidReceiveAdClickEvent(self)
    }
    
}
