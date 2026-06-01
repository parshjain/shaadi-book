import { describe, expect, it } from "vitest";
import { BABY_HASAN_MARKETS } from "../initialMarketDefinitions.js";

describe("BABY_HASAN_MARKETS", () => {
  it("contains the requested gender reveal markets and outcomes", () => {
    expect(BABY_HASAN_MARKETS).toHaveLength(12);
    expect(BABY_HASAN_MARKETS.map((market) => market.question)).toEqual([
      "Gender?",
      "Will Alif cry at the gender reveal?",
      "Will Anusha cry at the gender reveal?",
      "What color will Alif wear?",
      "What color will Anusha wear?",
      "Will Anusha start showing by gender reveal day?",
      "Will the cake be vanilla or chocolate?",
      "Will Anusha's dad cry at the gender reveal?",
      "What time will the gender reveal happen?",
      "What shoes will Anusha be wearing?",
      "Will there be a malfunction during the reveal?",
      "Over/under 80 guests",
    ]);

    expect(BABY_HASAN_MARKETS[0]?.outcomes).toEqual(["Boy", "Girl"]);
    expect(BABY_HASAN_MARKETS[3]?.outcomes).toEqual([
      "Pink",
      "Blue",
      "Yellow",
      "White/Beige",
    ]);
    expect(BABY_HASAN_MARKETS[6]?.outcomes).toEqual([
      "Vanilla",
      "Chocolate",
      "Both",
      "Neither",
    ]);
    expect(BABY_HASAN_MARKETS[8]?.outcomes).toEqual([
      "1pm",
      "2pm",
      "3pm",
      "4pm",
    ]);
    expect(BABY_HASAN_MARKETS[9]?.outcomes).toEqual([
      "Sandals",
      "Heels",
      "Flats",
      "Sneakers",
    ]);
    expect(BABY_HASAN_MARKETS[11]?.outcomes).toEqual(["Over", "Under"]);
  });
});
