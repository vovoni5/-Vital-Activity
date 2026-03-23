import XCTest
@testable import Recipe

final class UnitConverterTests: XCTestCase {

    func testGramsToTbsp() {
        let grams = 30.0
        let tbsp = UnitConverter.gramsToTbsp(grams)
        XCTAssertEqual(tbsp, 2.0, accuracy: 0.001, "30 грамм должно быть 2 ст. ложки")
    }

    func testTbspToGrams() {
        let tbsp = 2.0
        let grams = UnitConverter.tbspToGrams(tbsp)
        XCTAssertEqual(grams, 30.0, accuracy: 0.001, "2 ст. ложки должно быть 30 грамм")
    }

    func testGramsToPieces() {
        let grams = 100.0
        let pieces = UnitConverter.gramsToPieces(grams)
        XCTAssertEqual(pieces, 2.0, accuracy: 0.001, "100 грамм должно быть 2 штуки")
    }

    func testPiecesToGrams() {
        let pieces = 3.0
        let grams = UnitConverter.piecesToGrams(pieces)
        XCTAssertEqual(grams, 150.0, accuracy: 0.001, "3 штуки должно быть 150 грамм")
    }

    func testFormatQuantity() {
        let value1 = 5.0
        let formatted1 = UnitConverter.formatQuantity(value1)
        XCTAssertEqual(formatted1, "5")

        let value2 = 3.14159
        let formatted2 = UnitConverter.formatQuantity(value2, maxFractionDigits: 2)
        XCTAssertEqual(formatted2, "3.14")

        let value3 = 0.5
        let formatted3 = UnitConverter.formatQuantity(value3)
        XCTAssertEqual(formatted3, "0.5")
    }
}