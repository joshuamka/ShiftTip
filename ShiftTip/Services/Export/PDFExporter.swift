//
//  PDFExporter.swift
//  ShiftTip
//
//  Created by Joshua Mkaddesh on 9/9/26.
//

import UIKit

nonisolated struct PDFExporter {

    static func createPDF(
        from shifts: [Shift],
        fileName: String
    ) -> URL? {

        let sortedShifts = shifts.sorted {
            $0.date > $1.date
        }

        let summary = EarningsSummary(shifts: sortedShifts)
        let totalHours = summary.hours
        let totalTips = summary.tips
        let hourlyPay = summary.hourlyPay
        let averagePerHour = summary.averageTipsPerHour

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

                beginReportPage(context, bounds: pageRect)

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
                    "Tips and Wages Report",
                    font:
                        .boldSystemFont(
                            ofSize: 20
                        ),
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
                    rect:
                        CGRect(
                            x: leftMargin,
                            y: y,
                            width: contentWidth,
                            height: 20
                        )
                )

                drawText(
                    "Tips paid after each shift. Wages are estimates before payroll deductions, not net checks.",
                    font: .systemFont(ofSize: 9),
                    rect: CGRect(x: leftMargin, y: y + 16, width: contentWidth, height: 18)
                )
                y += 50

                // MARK: Summary

                drawText(
                    "Summary",
                    font:
                        .boldSystemFont(
                            ofSize: 16
                        ),
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
                        "Est. Gross Wages",
                        formatCurrency(hourlyPay)
                    ),
                    (
                        "Tips / Hour",
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

                        beginReportPage(context, bounds: pageRect)

                        y = 40

                        drawText(
                            "ShiftTip Tips and Wages Report",
                            font:
                                .boldSystemFont(
                                    ofSize: 14
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

    /// Report colors are fixed for readability, independent of app appearance.
    private static func beginReportPage(
        _ context: UIGraphicsPDFRendererContext,
        bounds: CGRect
    ) {
        context.beginPage()
        context.cgContext.saveGState()
        context.cgContext.setFillColor(UIColor.white.cgColor)
        context.cgContext.fill(bounds)
        context.cgContext.restoreGState()
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
            rect:
                CGRect(
                    x: 345,
                    y: y,
                    width: 90,
                    height: 20
                )
        )

        drawText(
            "Est. Wages",
            font: font,
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
            rect:
                CGRect(
                    x: 115,
                    y: y,
                    width: 105,
                    height: 20
                )
        )

        drawText(
            shift.shiftTypeName,
            font: font,
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
                shift.hourlyEarnings
            ),
            font: font,
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
        rect: CGRect
    ) {

        let attributes:
            [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black
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
