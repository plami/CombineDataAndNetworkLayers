//
//  Decimal+Extensions.swift
//  MusicAppLocalDataArchitecture
//
//  Created by Plamena Nikolova on 22.05.24.
//

import Foundation

extension Decimal.FormatStyle {

    struct CompactCurrency: FormatStyle {
        let code: String
        var locale: Locale = .autoupdatingCurrent

        func format(_ value: Decimal) -> String {
            let currencyFormatStyle = Decimal.FormatStyle.Currency(code: code, locale: locale).presentation(.narrow)
            let currencyFormatted = value.formatted(currencyFormatStyle)
            return currencyFormatted
        }

        func locale(_ locale: Locale) -> Decimal.FormatStyle.CompactCurrency {
            var formatStyle = self
            formatStyle.locale = locale
            return formatStyle
        }
    }

}
