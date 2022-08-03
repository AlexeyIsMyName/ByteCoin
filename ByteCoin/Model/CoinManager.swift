//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateRateFor(_ fiat: String, rate: Double)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "82F3230A-3F3F-45CF-8B5F-2222CFE5B1B4"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    private func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    delegate?.didFailWithError(error: error)
                    return
                }
                
                if let safeData = data {
                    if let (fiat, rate) = parseJSON(safeData) {
                        delegate?.didUpdateRateFor(fiat, rate: rate)
                    }
                }
            }
            task.resume()
        }
    }
    
    private func parseJSON(_ data: Data) -> (String, Double)? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let rate = decodedData.rate
            let fiat = decodedData.asset_id_quote
            return (fiat, rate)
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

struct CoinData: Codable {
    let asset_id_quote: String
    let rate: Double
}
