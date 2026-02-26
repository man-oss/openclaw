package ai.openclaw.android

import io.kotest.core.spec.style.DescribeSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.collections.shouldContainExactlyInAnyOrder

class LocationModeTest : DescribeSpec({

    describe("LocationMode enum values") {

        it("should have exactly three entries") {
            LocationMode.entries.size shouldBe 3
        }

        it("should have Off with rawValue 'off'") {
            LocationMode.Off.rawValue shouldBe "off"
        }

        it("should have WhileUsing with rawValue 'whileUsing'") {
            LocationMode.WhileUsing.rawValue shouldBe "whileUsing"
        }

        it("should have Always with rawValue 'always'") {
            LocationMode.Always.rawValue shouldBe "always"
        }

        it("should contain Off, WhileUsing, and Always entries") {
            LocationMode.entries.map { it.name } shouldContainExactlyInAnyOrder
                listOf("Off", "WhileUsing", "Always")
        }
    }

    describe("LocationMode.fromRawValue") {

        describe("exact matches") {

            it("should return Off for raw value 'off'") {
                LocationMode.fromRawValue("off") shouldBe LocationMode.Off
            }

            it("should return WhileUsing for raw value 'whileUsing'") {
                LocationMode.fromRawValue("whileUsing") shouldBe LocationMode.WhileUsing
            }

            it("should return Always for raw value 'always'") {
                LocationMode.fromRawValue("always") shouldBe LocationMode.Always
            }
        }

        describe("case-insensitive matching") {

            it("should return Off for uppercase 'OFF'") {
                LocationMode.fromRawValue("OFF") shouldBe LocationMode.Off
            }

            it("should return Off for mixed case 'Off'") {
                LocationMode.fromRawValue("Off") shouldBe LocationMode.Off
            }

            it("should return WhileUsing for uppercase 'WHILEUSING'") {
                LocationMode.fromRawValue("WHILEUSING") shouldBe LocationMode.WhileUsing
            }

            it("should return WhileUsing for mixed case 'WhileUsing'") {
                LocationMode.fromRawValue("WhileUsing") shouldBe LocationMode.WhileUsing
            }

            it("should return WhileUsing for all-caps 'WHILEUSING'") {
                LocationMode.fromRawValue("whileusing") shouldBe LocationMode.WhileUsing
            }

            it("should return Always for uppercase 'ALWAYS'") {
                LocationMode.fromRawValue("ALWAYS") shouldBe LocationMode.Always
            }

            it("should return Always for mixed case 'Always'") {
                LocationMode.fromRawValue("Always") shouldBe LocationMode.Always
            }
        }

        describe("whitespace trimming") {

            it("should return Off when raw value has leading spaces") {
                LocationMode.fromRawValue("  off") shouldBe LocationMode.Off
            }

            it("should return Off when raw value has trailing spaces") {
                LocationMode.fromRawValue("off  ") shouldBe LocationMode.Off
            }

            it("should return Off when raw value has surrounding spaces") {
                LocationMode.fromRawValue("  off  ") shouldBe LocationMode.Off
            }

            it("should return WhileUsing when raw value has surrounding spaces") {
                LocationMode.fromRawValue("  whileUsing  ") shouldBe LocationMode.WhileUsing
            }

            it("should return Always when raw value has surrounding spaces") {
                LocationMode.fromRawValue("  always  ") shouldBe LocationMode.Always
            }
        }

        describe("null and unknown inputs (fallback to Off)") {

            it("should return Off for null input") {
                LocationMode.fromRawValue(null) shouldBe LocationMode.Off
            }

            it("should return Off for empty string") {
                LocationMode.fromRawValue("") shouldBe LocationMode.Off
            }

            it("should return Off for blank string of spaces") {
                LocationMode.fromRawValue("   ") shouldBe LocationMode.Off
            }

            it("should return Off for unrecognised value 'unknown'") {
                LocationMode.fromRawValue("unknown") shouldBe LocationMode.Off
            }

            it("should return Off for unrecognised value 'enabled'") {
                LocationMode.fromRawValue("enabled") shouldBe LocationMode.Off
            }

            it("should return Off for unrecognised numeric string '1'") {
                LocationMode.fromRawValue("1") shouldBe LocationMode.Off
            }

            it("should return Off for a completely random string") {
                LocationMode.fromRawValue("randomGibberish") shouldBe LocationMode.Off
            }

            it("should return Off for tab-only whitespace") {
                LocationMode.fromRawValue("\t") shouldBe LocationMode.Off
            }
        }

        describe("combined whitespace and case edge cases") {

            it("should return Always for '  ALWAYS  '") {
                LocationMode.fromRawValue("  ALWAYS  ") shouldBe LocationMode.Always
            }

            it("should return WhileUsing for '  WHILEUSING  '") {
                LocationMode.fromRawValue("  WHILEUSING  ") shouldBe LocationMode.WhileUsing
            }
        }
    }

    describe("LocationMode ordinal ordering") {

        it("should have Off at ordinal 0") {
            LocationMode.Off.ordinal shouldBe 0
        }

        it("should have WhileUsing at ordinal 1") {
            LocationMode.WhileUsing.ordinal shouldBe 1
        }

        it("should have Always at ordinal 2") {
            LocationMode.Always.ordinal shouldBe 2
        }
    }

    describe("LocationMode.valueOf") {

        it("should return Off via valueOf") {
            LocationMode.valueOf("Off") shouldBe LocationMode.Off
        }

        it("should return WhileUsing via valueOf") {
            LocationMode.valueOf("WhileUsing") shouldBe LocationMode.WhileUsing
        }

        it("should return Always via valueOf") {
            LocationMode.valueOf("Always") shouldBe LocationMode.Always
        }
    }
})