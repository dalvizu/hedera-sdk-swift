/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2023 Hedera Hashgraph, LLC
 * ​
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ‍
 */

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class TokenRevokeKycTransactionTests: XCTestCase {
    internal static let testAccountId: AccountId = "6.9.0"

    internal static let testTokenId: TokenId = "4.2.0"

    internal static let testTxId: TransactionId = TransactionId(
        accountId: 5006,
        validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0),
        scheduled: false
    )

    internal static let unusedPrivateKey: PrivateKey =
        "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"

    private static func makeTransaction() throws -> TokenRevokeKycTransaction {
        try TokenRevokeKycTransaction()
            .nodeAccountIds([AccountId("0.0.5005"), AccountId("0.0.5006")])
            .transactionId(testTxId)
            .tokenId(testTokenId)
            .accountId(testAccountId)
            .freeze()
            .sign(unusedPrivateKey)
    }

    internal func testSerialize() throws {
        let tx = try Self.makeTransaction().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytes() throws {
        let tx = try Self.makeTransaction()

        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testFromProtoBody() throws {
        let protoData = Proto_TokenRevokeKycTransactionBody.with { proto in
            proto.account = Self.testAccountId.toProtobuf()
            proto.token = Self.testTokenId.toProtobuf()
        }

        let protoBody = Proto_TransactionBody.with { proto in
            proto.tokenRevokeKyc = protoData
            proto.transactionID = Self.testTxId.toProtobuf()
        }

        let tx = try TokenRevokeKycTransaction(protobuf: protoBody, protoData)

        XCTAssertEqual(tx.accountId, Self.testAccountId)
        XCTAssertEqual(tx.tokenId, Self.testTokenId)
    }

    internal func testGetSetAccountId() {
        let tx = TokenRevokeKycTransaction()
        tx.accountId(Self.testAccountId)

        XCTAssertEqual(tx.accountId, Self.testAccountId)
    }

    internal func testGetSetTokenId() {
        let tx = TokenRevokeKycTransaction()
        tx.tokenId(Self.testTokenId)

        XCTAssertEqual(tx.tokenId, Self.testTokenId)
    }
}
