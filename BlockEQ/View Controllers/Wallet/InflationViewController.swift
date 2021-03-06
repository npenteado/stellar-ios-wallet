//
//  InflationViewController.swift
//  BlockEQ
//
//  Created by Satraj Bambra on 2018-04-19.
//  Copyright © 2018 BlockEQ. All rights reserved.
//

import Whisper
import StellarAccountService

protocol InflationViewControllerDelegate: AnyObject {
    func updateAccountInflation(_ viewController: InflationViewController, destination: StellarAddress)
}

final class InflationViewController: UIViewController {
    @IBOutlet var addressHolderView: UIView!
    @IBOutlet var holdingView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var subtitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var destinationAddressTextField: UITextField!

    weak var delegate: InflationViewControllerDelegate?
    var account: StellarAccount
    let lumenautInflationDestination = "GCCD6AJOYZCUAQLX32ZJF2MKFFAUJ53PVCFQI3RHWKL3V47QYE2BNAUT"

    init(account: StellarAccount) {
        self.account = account
        super.init(nibName: String(describing: InflationViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let currentInflationDestination = account.inflationDestination {
            destinationAddressTextField.text = currentInflationDestination
            subtitleLabel.text = ""
            subtitleLabelTopConstraint.constant = 0.0
        } else {
            destinationAddressTextField.text = lumenautInflationDestination
        }
    }

    func setupView() {
        navigationItem.title = "SET_INFLATION".localized()
        tableView.backgroundColor = Colors.lightBackground
        titleLabel.textColor = Colors.darkGrayTransparent
        subtitleLabel.textColor = Colors.darkGray
        destinationAddressTextField.textColor = Colors.darkGray
        addressHolderView.backgroundColor = Colors.lightBackground
        holdingView.backgroundColor = Colors.lightBackground
        view.backgroundColor = Colors.lightBackground
    }
}

// MARK: - Prompts
extension InflationViewController {
    func displayInflationSuccess() {
        self.view.endEditing(true)

        let message = Message(title: "INFLATION_SUCCESSFULLY_UPDATED".localized(), backgroundColor: Colors.green)
        Whisper.show(whisper: message, to: navigationController!, action: .show)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Whisper.hide(whisperFrom: self.navigationController!)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismissView()
            }
        }
    }

    func showHud() {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.label.text = "SETTING_INFLATION_DESTINATION".localized()
        hud.mode = .indeterminate
    }

    func hideHud() {
        MBProgressHUD.hide(for: UIApplication.shared.keyWindow!, animated: true)
    }

    func dismissView() {
        view.endEditing(true)

        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - IBActions
extension InflationViewController {
    @IBAction func scanQRCode() {
        let scanViewController = ScanViewController()
        scanViewController.delegate = self

        let navigationController = AppNavigationController(rootViewController: scanViewController)
        present(navigationController, animated: true, completion: nil)
    }

    @IBAction func addInflationDestination() {
        guard let inflationDestination = StellarAddress(destinationAddressTextField.text) else {
            destinationAddressTextField.shake()
            return
        }

        let inflationString = inflationDestination.string
        guard inflationString != account.accountId, inflationString != account.inflationDestination else {
            UIAlertController.simpleAlert(title: "INVALID_DESTINATION_TITLE".localized(),
                                          message: "INFLATION_DESTINATION_INVALID".localized(),
                                          presentingViewController: self)
            return
        }

        showHud()
        delegate?.updateAccountInflation(self, destination: inflationDestination)
    }
}

// MARK: - ScanViewControllerDelegate
extension InflationViewController: ScanViewControllerDelegate {
    func setQR(value: String) {
        destinationAddressTextField.text = value
    }
}

// MARK: - SetInflationResponseDelegate
extension InflationViewController: SetInflationResponseDelegate {
    func failed(error: FrameworkError) {
        self.hideHud()
        let alert = UIAlertController(title: "INFLATION_ERROR_TITLE".localized(),
                                      message: "INFLATION_ERROR_MESSAGE".localized(),
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "GENERIC_OK_TEXT".localized(), style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func setInflation(destination: StellarAddress) {
        self.hideHud()
        self.displayInflationSuccess()
    }
}
