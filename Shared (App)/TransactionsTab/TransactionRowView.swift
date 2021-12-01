//
//  TransactionRowView.swift
//  Wallet (iOS)
//
//  Created by Stefano on 28.11.21.
//

import SwiftUI

struct TransactionRowView: View {
    
    let txType: TransactionType
    let description: String
    let toAddress: String
    let amount: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: txType.imageName)
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(txType.imageColor)
            VStack(alignment: .leading, spacing: 5) {
                Group {
                    Text(txType.title)
                        .font(.body)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    Text(toAddress)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .truncationMode(Text.TruncationMode.middle)
                }
                .lineLimit(1)
            }
            .frame(maxWidth: 180)
            Spacer()
            VStack(spacing: 5) {
                Group {
                    Text(amount) + Text(" ") + Text("ETH")
                }
                .font(.body)
                .lineLimit(1)
            }
        }
    }
}

struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TransactionRowView(txType: .swap, description: "Swapped 1 weth for 1 fwb", toAddress: "0x1FF1af1934DF4e772F2A8a998FEA635704B77836", amount: "1.123")
            TransactionRowView(txType: .send, description: "1 eth", toAddress: "0x1FF1af1934DF4e772F2A8a998FEA635704B77836", amount: "1")
            TransactionRowView(txType: .receive, description: "1 eth", toAddress: "0x1FF1af1934DF4e772F2A8a998FEA635704B77836", amount: "1")
            TransactionRowView(txType: .contractExecution, description: "1 eth", toAddress: "0x1FF1af1934DF4e772F2A8a998FEA635704B77836", amount: "1")
            TransactionRowView(txType: .stake, description: "1 eth", toAddress: "0x1FF1af1934DF4e772F2A8a998FEA635704B77836", amount: "1")
            TransactionRowView(txType: .unstake, description: "1 eth", toAddress: "0x1FF1af1934DF4e772F2A8a998FEA635704B77836", amount: "1")
        }
        .padding(10)
        .previewLayout(.sizeThatFits)
    }
}

extension TransactionType {
    
    init(_ type: String) {
        switch type {
        case "send":
            self = .send
        case "receive":
            self = .receive
        case "stake":
            self = .stake
        case "unstake":
            self = .unstake
        case "swap":
            self = .swap
        case "mint":
            self = .mint
        case "burn":
            self = .burn
        case "contract_execution":
            self = .contractExecution
        case "approve":
            self = .approve
        default:
            self = .unknown
        }
    }
    
    var imageName: String {
        switch self {
        case .send:
            return "arrow.up.circle"
        case .receive:
            return "arrow.down.circle"
        case .stake:
            return "arrow.uturn.down.circle"
        case .unstake:
            return "arrow.uturn.up.circle"
        case .mint:
            return "link.circle"
        case .burn:
            return "flame"
        case .swap:
            return "arrow.left.arrow.right.circle"
        case .contractExecution:
            return "arrow.triangle.2.circlepath.circle"
        case .approve:
            return "checkmark.circle"
        default:
            return "arrow.triangle.2.circlepath.circle"
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
        case .send:
            return "Send"
        case .receive:
            return "Receive"
        case .stake:
            return "Stake"
        case .unstake:
            return "Unstake"
        case .swap:
            return "Swap"
        case .mint:
            return "Mint"
        case .burn:
            return "Burn"
        case .contractExecution:
            return "Contract Execution"
        case .approve:
            return "Approve"
        case .unknown:
            return "Unknown"
        }
    }
}
