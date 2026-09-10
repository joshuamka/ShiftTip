//
//  PDFExporter.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import UIKit

struct PDFExporter {

    static func createPDF(
        from shifts: [Shift],
        fileName: String
    ) -> URL? {

        let sortedShifts = shifts.sorted {
            $0.date > $1.date
        }

        let totalHours = sortedShifts.reduce(0) {
            $0 + $1.hoursWorked
        }

        let totalTips = sortedShifts.reduce(0) {
            $0 + $1.totalTips
        }

        let hourlyPay = sortedShifts.reduce(0) {
            $0 + $1.hourlyEarnings
        }

        let totalEarnings = sortedShifts.reduce(0) {
            $0 + $1.totalEarnings
        }

        let averagePerHour =
            totalHours > 0
            ? totalEarnings / totalHours
            : 0

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792

        let pageRect = CGRect(
            x: 0,
            y: 0,
            width: pageWidth,
            height: pageHeight
        )

        let renderer =
            UIGraphicsPDFRenderer(
                bounds: pageRect
            )

        let url =
            FileManager.default
                .temporaryDirectory
                .appendingPathComponent(
                    fileName
                )

        do {

            try renderer.writePDF(
                to: url
            ) { context in

                context.beginPage()

                var y: CGFloat = 40

                let leftMargin: CGFloat = 40
                let contentWidth =
                    pageWidth - 80

                // MARK: Title

                drawText(
                    "ShiftTip",
                    font:
                        .boldSystemFont(
                            ofSize: 28
                        ),
                    color:
                        UIColor(
                            red: 1.0,
                            green: 0.176,
                            blue: 0.333,
                            alpha: 1.0
                        ),
                    rect:
                        CGRect(
                            x: leftMargin,
                            y: y,
                            width: contentWidth,
                            height: 40
                        )
                )

                y += 38

                drawText(
                    "Earnings Report",
                    font:
                        .boldSystemFont(
                            ofSize: 20
                        ),
                    color: .label,
                    rect:
                        CGRect(
                            x: leftMargin,
                            y: y,
                            width: contentWidth,
                            height: 30
                        )
                )

                y += 32

                let generatedDate =
                    Date().formatted(
                        date: .long,
                        time: .shortened
                    )

                drawText(
                    "Generated \(generatedDate)",
                    font:
                        .systemFont(
                            ofSize: 10
                        ),
                    color:
                        .secondaryLabel,
                    rect:
                        CGRect(
                            x: leftMargin,
                            y: y,
                            width: contentWidth,
                            height: 20
                        )
                )

                y += 35

                // MARK: Summary

                drawText(
                    "Summary",
                    font:
                        .boldSystemFont(
                            ofSize: 16
                        ),
                    color: .label,
                    rect:
                        CGRect(
                            x: leftMargin,
                            y: y,
                            width: contentWidth,
                            height: 25
                        )
                )

                y += 28

                let summaryItems = [
                    (
                        "Total Shifts",
                        "\(sortedShifts.count)"
                    ),
                    (
                        "Hours Worked",
                        formatNumber(totalHours)
                    ),
                    (
                        "Total Tips",
                        formatCurrency(totalTips)
                    ),
                    (
                        "Hourly Pay",
                        formatCurrency(hourlyPay)
                    ),
                    (
                        "Total Earnings",
                        formatCurrency(totalEarnings)
                    ),
                    (
                        "Average / Hour",
                        formatCurrency(
                            averagePerHour
                        )
                    )
                ]

                for item in summaryItems {

                    drawText(
                        item.0,
                        font:
                            .systemFont(
                                ofSize: 11
                            ),
                        color:
                            .secondaryLabel,
                        rect:
                            CGRect(
                                x: leftMargin,
                                y: y,
                                width: 180,
                                height: 20
                            )
                    )

                    drawText(
                        item.1,
                        font:
                            .boldSystemFont(
                                ofSize: 11
                            ),
                        color: .label,
                        rect:
                            CGRect(
                                x: 220,
                                y: y,
                                width: 200,
                                height: 20
                            )
                    )

                    y += 21
                }

                y += 20

                // MARK: Shift Table

                drawText(
                    "Shift Details",
                    font:
                        .boldSystemFont(
                            ofSize: 16
                        ),
                    color: .label,
                    rect:
                        CGRect(
                            x: leftMargin,
                            y: y,
                            width: contentWidth,
                            height: 25
                        )
                )

                y += 30

                drawTableHeader(
                    y: y
                )

                y += 25

                for shift in sortedShifts {

                    if y > pageHeight - 70 {

                        context.beginPage()

                        y = 40

                        drawText(
                            "ShiftTip Earnings Report",
                            font:
                                .boldSystemFont(
                                    ofSize: 14
                                ),
                            color:
                                UIColor(
                                    red: 1.0,
                                    green: 0.176,
                                    blue: 0.333,
                                    alpha: 1.0
                                ),
                            rect:
                                CGRect(
                                    x: leftMargin,
                                    y: y,
                                    width:
                                        contentWidth,
                                    height: 25
                                )
                        )

                        y += 35

                        drawTableHeader(
                            y: y
                        )

                        y += 25
                    }

                    drawShiftRow(
                        shift,
                        y: y
                    )

                    y += 24
                }
            }

            return url

        } catch {

            print(
                "PDF Export Error: \(error.localizedDescription)"
            )

            return nil
        }
    }

    private static func drawTableHeader(
        y: CGFloat
    ) {

        let font =
            UIFont.boldSystemFont(
                ofSize: 9
            )

        drawText(
            "Date",
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 40,
                    y: y,
                    width: 75,
                    height: 20
                )
        )

        drawText(
            "Workplace",
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 115,
                    y: y,
                    width: 110,
                    height: 20
                )
        )

        drawText(
            "Type",
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 225,
                    y: y,
                    width: 65,
                    height: 20
                )
        )

        drawText(
            "Hours",
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 290,
                    y: y,
                    width: 55,
                    height: 20
                )
        )

        drawText(
            "Tips",
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 345,
                    y: y,
                    width: 90,
                    height: 20
                )
        )

        drawText(
            "Earnings",
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 435,
                    y: y,
                    width: 125,
                    height: 20
                )
        )
    }

    private static func drawShiftRow(
        _ shift: Shift,
        y: CGFloat
    ) {

        let font =
            UIFont.systemFont(
                ofSize: 8
            )

        let date =
            shift.date.formatted(
                .dateTime
                    .month(.twoDigits)
                    .day(.twoDigits)
                    .year()
            )

        let workplace =
            shift.workplace.isEmpty
            ? "Not Specified"
            : shift.workplace

        drawText(
            date,
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 40,
                    y: y,
                    width: 75,
                    height: 20
                )
        )

        drawText(
            workplace,
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 115,
                    y: y,
                    width: 105,
                    height: 20
                )
        )

        drawText(
            shift.shiftType.rawValue,
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 225,
                    y: y,
                    width: 60,
                    height: 20
                )
        )

        drawText(
            formatNumber(
                shift.hoursWorked
            ),
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 290,
                    y: y,
                    width: 50,
                    height: 20
                )
        )

        drawText(
            formatCurrency(
                shift.totalTips
            ),
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 345,
                    y: y,
                    width: 85,
                    height: 20
                )
        )

        drawText(
            formatCurrency(
                shift.totalEarnings
            ),
            font: font,
            color: .label,
            rect:
                CGRect(
                    x: 435,
                    y: y,
                    width: 120,
                    height: 20
                )
        )
    }

    private static func drawText(
        _ text: String,
        font: UIFont,
        color: UIColor,
        rect: CGRect
    ) {

        let attributes:
            [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: color
            ]

        text.draw(
            in: rect,
            withAttributes: attributes
        )
    }

    private static func formatCurrency(
        _ value: Double
    ) -> String {

        value.formatted(
            .currency(
                code: "USD"
            )
        )
    }

    private static func formatNumber(
        _ value: Double
    ) -> String {

        value.formatted(
            .number.precision(
                .fractionLength(1)
            )
        )
    }
}
