# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Please keep this human readable! Omit classnames and technical details where possible.

## [2.4.1] - 2018-12-05
### Changed
- Fixed an issue relating to displaying incorrect effects in the wallet across different asset types

## [2.4.0] - 2018-11-30
### Added
- Ability to debug the wallet using a public Stellar address in view-only mode
- New transaction details view controller
- Advanced mnemonic password support
- New framework to fetch data from Horizon / BlockEQ API
- Test coverage for the new framework
- New diagnostic reporting tool for users to send anonymized wallet information to help during support
- Better prompting when updating the inflation destination
- Ability for the address resolver to fetch the exchange list from the BlockEQ API
- New network reachability wrapper class
- Periodic updating for the orderbook
- New issue templates

### Changed
- Updated Soneso SDK version to use `master` from their GitHub repository
- Updated debug build API endpoints to staging + correct wallet filtering
- Moved Stellar SDK integration from the iOS target to a new StellarAccountService
- Refactored the structure of the Wallet view
- Refactored the structure of the Inflation destination view
- Corrected issues during presentation of inflation view controller 
- Corrected Xcode warnings relating to the status bar
- Fixed a crash when removing an asset from the users wallet
- Fixed a crash when selecting an asset before the account had fully updated
- Fixed trade view controller segmented colours
- Fixed copy button image after setting copy as a template image 
- Fixed an issue where the "send payment" button would become unresponsive on the contact tab
- Fixed incorrect back navigation behavior when creating a new wallet
- Reduced vertical height of the cells in the main wallet view to fit more on the screen
- Corrected issue causing limit order text to be overwritten due to periodic updates
- Corrected available balance display to show untruncated amounts - Also converts usage of lower-precision Double to Decimal 
- Corrected tab bar visual issue for new Apple device models (iPhone Xr, iPhone Xs, iPhone Xs Max)
- Using a new decimal format for trades in the order book with more precision
- Displays '< 0.0001' instead of '0.00' for small amounts of assets 
- Trade selectors no longer reset the user's selection when using the opposite picker

### Removed
- The success prompt when saving a mnemonic or secret to the iOS keychain 
- Lazy properties for view controllers we know always should be loaded 
- The cap of 100,000,000 for the trust limit when sending a "change trust" operation
- The ability to select the 'Account Created' effect due to missing transaction data for it