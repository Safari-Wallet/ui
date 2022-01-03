//
//  TransactionRowView.swift
//  Wallet (iOS)
//
//  Created by Stefano on 28.11.21.
//

import SwiftUI

struct TransactionRowView: View {
    
    let txType: TransactionType
    let toAddress: String
    let token: String?
    let fiat: String?
    let nameTag: String?
    let description: String?
    let date: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: txType.imageName)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(txType.imageColor)
            VStack(alignment: .leading, spacing: 8) {
                if let token = token, let fiat = fiat {
                    HStack {
                        Text(token)
                            .font(.system(.callout, design: .monospaced))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(fiat)
                            .font(.system(.callout, design: .monospaced))
                            .lineLimit(1)
                    }
                }
                
                Text(description ?? txType.title)
                    .font(.system(.caption2, design: .monospaced))
                    .lineLimit(2)
                HStack {
                    Text(nameTag ?? toAddress)
                        .font(.system(.caption2, design: .monospaced))
                        .truncationMode(.middle)
                        .lineLimit(1)
                    Spacer()
                    Text(date)
                        .font(.system(.caption2, design: .monospaced))
                        .truncationMode(.middle)
                        .lineLimit(1)
                    
                }
            }
        }
    }
}

struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TransactionRowView(
                txType: .trade,
                toAddress: "0x1FF1af1934DF4e772F2A8a998FEA635704B77836",
                token: "1 ETH",
                fiat: "USD 4000",
                nameTag: "Uniswap",
                description: "Swapped 1 weth for 1 fwb",
                date: "Yesterday"
            )
            
            TransactionRowView(
                txType: .trade,
                toAddress: "0x1FF1af1934DF4e772F2A8a998FEA635704B77836",
                token: nil,
                fiat: nil,
                nameTag: nil,
                description: nil,
                date: "Yesterday"
            )
        }
        .padding(10)
        .previewLayout(.sizeThatFits)
    }
}

extension TransactionType {
    
    init(_ type: String) {
        self = TransactionType(rawValue: type) ?? .unknown
    }
    
    var imageName: String {
        switch self {
        case .send:
            return "arrow.up.square"
        case .receive:
            return "arrow.down.square"
        case .stake:
            return "arrow.uturn.down.square"
        case .unstake:
            return "arrow.uturn.up.square"
        case .trade:
            return "arrow.left.arrow.right.square"
        case .execution:
            return "curlybraces.square"
        case .authorize:
            return "checkmark.square"
        default:
            return "curlybraces.square"
        }
    }
    
    var imageColor: Color {
        switch self {
        case .send:
            return .green
        case .receive:
            return .blue
        default:
            return .black
        }
    }
    
    var title: String {
        switch self {
        case .execution:
            return "Contract Execution"
        case .unknown:
            return "Unknown"
        default:
            return self.rawValue.capitalized
        }
    }
}
