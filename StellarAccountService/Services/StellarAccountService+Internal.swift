//
//  StellarAccountService+Internal.swift
//  StellarAccountService
//
//  Created by Nick DiZazzo on 2018-10-22.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import stellarsdk

extension StellarAccountService {
    internal func startup(address: StellarAddress) {
        let stubAccount = StellarAccount(accountId: address.string)
        self.account = stubAccount

        let secretManager = SecretManager(for: address.string)
        self.secretManager = secretManager

        state = .active
    }

    internal func startup(keyPair: KeyPair) {
        let stubAccount = StellarAccount(accountId: keyPair.accountId)
        self.account = stubAccount

        let secretManager = SecretManager(for: stubAccount.accountId)
        secretManager.store(keyPair: keyPair)
        self.secretManager = secretManager

        state = .active
    }

    internal func startPeriodicTimer() {
        guard self.timer == nil else { return }

        let interval = StellarAccountService.accountUpdateInterval
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            self.update()
        })
    }

    internal func startPaymentStream() {
        guard self.paymentStreamItem == nil, let accountId = account?.accountId else { return }

        let accountStream = PaymentsChange.paymentsForAccount(account: accountId, cursor: "now")
        let streamItem = core.sdk.payments.stream(for: accountStream)
        self.paymentStreamItem = streamItem

        streamItem.onReceive { [unowned self] response -> Void in
            switch response {
            case .open: break
            case .response(_, let operationResponse):
                if operationResponse is PaymentOperationResponse {
                    let operation = StellarOperation(operationResponse)
                    DispatchQueue.main.async {
                        self.subscribers.invoke(invocation: { $0.paymentUpdate(self, operation: operation) })
                    }
                }
            case .error(let error):
                if let horizonRequestError = error as? HorizonRequestError {
                    StellarSDKLog.printHorizonRequestErrorMessage(tag: "Receive payment",
                                                                  horizonRequestError: horizonRequestError)
                }
            }
        }
    }
}
