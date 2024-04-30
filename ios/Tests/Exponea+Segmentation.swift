//
//  Exponea+Segmentation.swift
//  Tests
//
//  Created by Adam Mihalik on 29/04/2024.
//  Copyright © 2024 Facebook. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Exponea

class ExponeaSegmentationSpec: QuickSpec {
    override func spec() {
        var mockExponea: MockExponea!
        var exponea: Exponea!
        beforeEach {
            mockExponea = MockExponea()
            Exponea.exponeaInstance = mockExponea
            exponea = Exponea()
        }
        context("Segmentation callbacks registration") {
            it("should register segmentation callback") {
                waitUntil { done in
                    let exposingCategory = "discovery"
                    let includeFirstLoad = false
                    exponea.registerSegmentationDataCallback(
                        exposingCategory: exposingCategory,
                        includeFirstLoad: includeFirstLoad,
                        resolve: { result in
                            expect(result as? String).toNot(beEmpty())
                            expect(exponea.segmentationDataCallbacks.count).to(equal(1))
                            expect(exponea.segmentationDataCallbacks.first).notTo(beNil())
                            expect(exponea.segmentationDataCallbacks.first?.exposingCategory).to(equal(.discovery()))
                            expect(exponea.segmentationDataCallbacks.first?.includeFirstLoad).to(
                                equal(includeFirstLoad)
                            )
                            done()
                        },
                        reject: {_, _, _ in }
                    )
                }
            }
            it("should unregister segmentation callback successfully") {
                let exposingCategory = "discovery"
                let includeFirstLoad = false
                var callbackInstanceId: String?
                waitUntil { done in
                    exponea.registerSegmentationDataCallback(
                        exposingCategory: exposingCategory,
                        includeFirstLoad: includeFirstLoad,
                        resolve: { result in
                            callbackInstanceId = result as? String
                            done()
                        },
                        reject: {_, _, _ in }
                    )
                }
                expect(callbackInstanceId).toNot(beNil())
                guard let callbackInstanceId else {
                    return
                }
                waitUntil { done in
                    exponea.unregisterSegmentationDataCallback(
                        callbackInstanceId: callbackInstanceId,
                        resolve: { _ in
                            // just be here is fine
                            done()
                        },
                        reject: {_, _, _ in }
                    )
                }
            }
            it("should failed while unregistering of non-existing segmentation callback") {
                waitUntil { done in
                    exponea.unregisterSegmentationDataCallback(
                        callbackInstanceId: "non-existing-id",
                        resolve: { _ in },
                        reject: { _, _, _ in
                            // just be here is fine
                            done()
                        }
                    )
                }
            }
        }
    }
}
