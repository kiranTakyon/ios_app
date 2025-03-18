//
//  DashboardGraphCollectionViewCell.swift
//  Ambassador Education
//
//  Created by IE14 on 24/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit
import DGCharts

class DashboardGraphCollectionViewCell: UICollectionViewCell ,ChartViewDelegate{
    
    static var identifier = "DashboardGraphCollectionViewCell"
    var feeSummary:FeeSummary?
    var barChartView: BarChartView!
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupChartView()
        
    }
    
    private func setupChartView() {
           barChartView = BarChartView()
           barChartView.delegate = self
           barChartView.translatesAutoresizingMaskIntoConstraints = false
           containerView.addSubview(barChartView)

           NSLayoutConstraint.activate([
               barChartView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 20),
               barChartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
               barChartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
               barChartView.heightAnchor.constraint(equalToConstant: 300)
           ])
       }


    func updateChart(with data: FeeSummary) {
        
        let totalFee = Double(feeSummary?.totalFee ?? "0") ?? 0
        let totalDue = Double(feeSummary?.totalDue ?? "0") ?? 0
        let currentDue = Double(feeSummary?.currentDue ?? "0") ?? 0
        let totalPaid = Double(feeSummary?.totalPaid ?? "0") ?? 0
        
        let entries: [BarChartDataEntry] = [
            BarChartDataEntry(x: 0, y: totalFee),
            BarChartDataEntry(x: 1, y: totalDue),
            BarChartDataEntry(x: 2, y: currentDue),
            BarChartDataEntry(x: 3, y: totalPaid)
        ]

        let dataSet = BarChartDataSet(entries: entries, label: "  \(data.sName ?? "Unknown")  ")
        dataSet.colors = [NSUIColor(named: "3366CC") ?? NSUIColor.blue]
        
        let chartData = BarChartData(dataSet: dataSet)
        barChartView.data = chartData

        // Configure X-Axis (Hide Vertical Grid Lines)
        let xAxis = barChartView.xAxis
        xAxis.valueFormatter = IndexAxisValueFormatter(values: ["TotalFee", "TotalDue", "CurrentDue", "TotalPaid"])
        xAxis.granularity = 1
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false // Hide vertical grid lines ❌

        // Configure Y-Axis (Show Only Horizontal Grid Lines)
        barChartView.leftAxis.drawGridLinesEnabled = true  // Show horizontal lines ✅
        barChartView.rightAxis.drawGridLinesEnabled = true // Show horizontal lines ✅

        barChartView.leftAxis.axisMinimum = 0
        barChartView.rightAxis.enabled = false
        barChartView.animate(yAxisDuration: 1.5)

        barChartView.legend.verticalAlignment = .top
        barChartView.legend.horizontalAlignment = .left
        barChartView.legend.yOffset = 20
        barChartView.legend.formSize = 12
    }


    
}
