//
//  CastSnipProducts.swift
//  CastSnip
//
//  Created by ewuehler on 3/2/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import Foundation

public class CastSnipProducts {
    
    public static let TestPaymentID = "com.ciretose.mostlysecurity.CastSnip.Test"
    public static let IconPaymentID = "com.ciretose.mostlysecurity.CastSnip.Icon"
//    public static let SubscriptionPaymentID = "com.ciretose.mostlysecurity.CastSnip.Subscription"
    public static let SettingsPaymentID = "com.ciretose.mostlysecurity.CastSnip.Settings"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [CastSnipProducts.TestPaymentID, CastSnipProducts.IconPaymentID, CastSnipProducts.SettingsPaymentID]

    public static let store = CastSnipIAP(productIds: productIdentifiers)

}
