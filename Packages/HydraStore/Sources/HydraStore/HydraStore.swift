// HydraStore — StoreKit 2, entitlement. See docs/02 §6.
//
// SKELETON. Depends on StoreKit (iOS SDK), does not build on CLT-only host.
// Public contract is authoritative (docs/02 §6).

import Foundation

public enum PurchaseState: Sendable, Equatable {
    case idle
    case loading
    case purchasing
    case pending              // Ask to Buy (family approval pending)
    case purchased
    case failed(String)
}

public enum StoreError: LocalizedError, Sendable {
    case productNotFound
    case unverifiedTransaction
    case purchaseFailed(String)
    case restoreFoundNothing
}

/// Pro gate. Single point of use in the UI.
public enum ProFeature: String, CaseIterable, Sendable {
    case dynamicGoal          // weather + activity + caffeine
    case electrolytes
    case premiumPlants
    case gardenHistory
    case liveActivity
    case csvExport
}

public enum StoreConstants {
    public static let proProductID = "com.hydraplant.pro.lifetime"
}

// EntitlementStore itself wraps StoreKit's Transaction API and is implemented in Xcode.
// Source of truth is always Transaction.currentEntitlements; offline uses the last
// known value (fail-open: the user already paid). Revocation closes Pro but NEVER
// deletes user data. See docs/02 §6.
