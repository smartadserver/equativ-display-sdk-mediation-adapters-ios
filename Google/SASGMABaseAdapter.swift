//
//  SASGMABaseAdapter.swift
//  Equativ
//
//  Created by Loïc GIRON DIT METAZ on 10/06/2024.
//  Copyright © 2024 Equativ. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SASDisplayKit

/**
 Google Mobile Ads base adapter class for Equativ SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Equativ.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Equativ SDK if needed.
 */
@objc(SASGMABaseAdapter)
class SASGMABaseAdapter : NSObject {
    
    /**
     Constants used to report errors.
     */
    class ErrorConstants {
        static let errorDomain = "SASGoogleMobileAdsAdapter"
        
        static let errorCodeInvalidParameterString = 1
        static let rewardedVideoExpiredOrAlreadyDisplayedErrorCode = 2
    }
    
    /// Enum that defines all the possible Google Mobile Ads type at initialization.
    enum GoogleMobileAdsType: Int {
        case notInitialized = 0
        case adMob = 1
        case adManager = 2
    }
    
    /// The key used by GMA creatives.
    static let adManagerKey = "admanager"
    
    /// Google Mobile Ads init status.
    var googleMobileAdsInitStatus: GoogleMobileAdsType = .notInitialized
    
    /// Google Mobile Ads Application ID.
    var applicationID: String? = nil
    
    /**
     Method called to configure Google Mobile Ads IDs from the server parameter string provided by Equativ.
     
     This method can fail and return GoogleMobileAdsTypeNotInitialized and an error, in this case no ad
     call should be performed.
     
     @param serverParameterString The server parameter string provided by Equativ.
     @return A tuple containing the Google Mobile Ads type after configuration and the adUnitID.
     @throws An Error if the method fails (and returns GoogleMobileAdsTypeNotInitialized).
     */
    func configureGoogleMobileAds(serverParameterString: String) throws -> (GoogleMobileAdsType, String) {
        // IDs are sent as a slash separated string
        let serverParameters = serverParameterString.split(separator: "|")
        
        // Invalid parameter string, the loading will be cancelled with an error
        guard serverParameters.count == 2 || serverParameters.count == 3 else {
            throw NSError(
                domain: ErrorConstants.errorDomain,
                code: ErrorConstants.errorCodeInvalidParameterString,
                userInfo: [NSLocalizedDescriptionKey: "Invalid server parameter string: \(serverParameters)"]
            )
        }
        
        // Extracting and converting parameters
        let appID = String(serverParameters[0])
        let adUnitID = String(serverParameters[1])
        
        if appID == SASGMABaseAdapter.adManagerKey {
            googleMobileAdsInitStatus = .adManager
        } else {
            googleMobileAdsInitStatus = .adMob
        }
        
        return (googleMobileAdsInitStatus, adUnitID)
    }
    
    /**
     Method called to initialize Google Mobile Ads request from the client parameters provided by Equativ.
     
     @param clientSideParameters The client parameters string provided by Equativ.
     */
    func request<T: GADRequest>(clientSideParameters: [AnyHashable : Any]?) -> T {
        let request = T()
        request.requestAgent = "Equativ"
        return request
    }
    
}
