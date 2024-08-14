//
//  SASOguryBannerAdapter.swift
//  Equativ
//
//  Created by Loic GIRON DIT METAZ on 24/05/2024.
//  Copyright © 2024 Equativ. All rights reserved.
//

import SASDisplayKit

import UIKit
import SASDisplayKit
import OguryAds
import OgurySdk

/**
 Ogury base adapter class for Equativ SDK mediation.
 
 Mediation adapter classes can be used to display an ad using a third party SDK directly from
 an insertion handled by Equativ.
 
 To use an adapter class, you simply have to add them to your Xcode project and they will
 be automatically instantiated by the Equativ SDK if needed.
 */
class SASOguryBaseAdapter: NSObject {
    
    /**
     Constants used to produce errors.
     */
    class ErrorConstants {
        static let errorDomain = "SASOguryAdapter"
        
        static let errorCodeInvalidParameterString = 1
        static let errorCodeAdNotAvailable = 2
        static let errorCodeAdNotLoaded = 3
        static let errorCodeAdError = 4
        static let errorCodeCannotInitializeOgurySDK = 5
        
        static let oguryNoAdErrorCode = 2008
    }
    
    /**
     Hold the different sizes needed to display an Ogury Thumbnail.
     */
    struct ThumbnailSize {
        let maxWidth: Int
        let maxHeight: Int
        let leftMargin: Int
        let topMargin: Int
    }
    
    /// Ogury Ad Unit ID.
    var adUnitId: String? = nil
    
    /// Ogury Thumbnail sizes.
    var thumbnailSize: ThumbnailSize? = nil
    
    /// Ogury Banner size.
    var bannerSize: OguryAdsBannerSize? = nil
    
    /**
     Configure the Asset Key and the Ad Unit Id used by Ogury from the server parameter string provided
     by the Equativ SDK.
     
     @param serverParameterString The server parameter string provided by Equativ.
     @param clientParameters      The client parameters dictionary provided by Equativ.
     @param completion            Handler called when the Equativ SDK setup is finished (it will return an error in case of failure, nil if successful).
     */
    func configureOgurySDK(serverParameterString: String, clientParameters: [AnyHashable: Any]?, completion: @escaping (Error?) -> ()) {
        // Retrieve the asset key and the ad unit id
        let serverParameters = serverParameterString.split(separator: "|")
        
        // Invalid parameter string, the loading will be cancelled with an error
        guard serverParameters.count == 2 || serverParameters.count == 3 || serverParameters.count == 6 else {
            completion(NSError(
                domain: ErrorConstants.errorDomain,
                code: ErrorConstants.errorCodeInvalidParameterString,
                userInfo: [NSLocalizedDescriptionKey: "Invalid server parameter string: \(serverParameters)"]
            ))
            return
        }
        
        // Parsing generic parameters
        let assetKey = String(serverParameters[0])
        adUnitId = String(serverParameters[1])
        
        // Banner parameters
        if serverParameters.count == 3 {
            // Invalid parameter string, the loading will be cancelled with an error
            guard let bannerSize = Int(serverParameters[2]) else {
                completion(NSError(
                    domain: ErrorConstants.errorDomain,
                    code: ErrorConstants.errorCodeInvalidParameterString,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid server parameter string: \(serverParameters)"]
                ))
                return
            }
            
            // Setting banner size
            if bannerSize == 0 {
                self.bannerSize = OguryAdsBannerSize.small_banner_320x50()
            } else if bannerSize == 1 {
                self.bannerSize = OguryAdsBannerSize.mpu_300x250()
            }
        }
        
        // Thumbnail parameters
        if serverParameters.count == 6 {
            // Invalid parameter string, the loading will be cancelled with an error
            guard let maxWidth = Int(serverParameters[2]),
                  let maxHeight = Int(serverParameters[3]),
                  let leftMargin = Int(serverParameters[4]),
                  let topMargin = Int(serverParameters[5]) else {
                      
                completion(NSError(
                    domain: ErrorConstants.errorDomain,
                    code: ErrorConstants.errorCodeInvalidParameterString,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid server parameter string: \(serverParameters)"]
                ))
                return
            }
            
            // Setting Thumbnail size
            thumbnailSize = ThumbnailSize(maxWidth: maxWidth, maxHeight: maxHeight, leftMargin: leftMargin, topMargin: topMargin)
        }
        
        // Initializing Ogury SDK
        let oguryConfiguration = OguryConfigurationBuilder(assetKey: assetKey).build()
        Ogury.start(with: oguryConfiguration)
        
        // Ogury has been successfully initialized
        completion(nil)
    }
    
}
