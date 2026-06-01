import { prisma } from "../db.js";
import { createMarket } from "./marketService.js";
import {
  DEFAULT_SEED_CENTS,
  getOrCreateHouseUser,
  seedMarket,
} from "./houseSeeding.js";
import { BABY_HASAN_MARKETS } from "./initialMarketDefinitions.js";

/**
 * Idempotently creates the default Baby Hasan markets for a fresh deployment.
 * Existing markets are matched by exact question text and are not duplicated.
 */
export async function seedInitialBabyHasanMarkets(): Promise<void> {
  const adminId = await getOrCreateHouseUser();
  let createdCount = 0;
  let seededExistingCount = 0;

  for (const marketDef of BABY_HASAN_MARKETS) {
    const existing = await prisma.market.findFirst({
      where: { question: marketDef.question },
      include: {
        outcomes: { orderBy: { position: "asc" } },
        purchases: { select: { id: true }, take: 1 },
      },
    });

    if (existing) {
      if (existing.purchases.length === 0) {
        await seedMarket(
          existing.id,
          existing.outcomes.map((outcome: { id: string }) => outcome.id),
          DEFAULT_SEED_CENTS
        );
        seededExistingCount++;
      }
      continue;
    }

    const marketId = await createMarket(
      adminId,
      marketDef.question,
      marketDef.outcomes,
      {
        eventTag: marketDef.eventTag,
        familySide: marketDef.familySide,
        customTags: marketDef.customTags ?? [],
      }
    );

    const outcomes = await prisma.outcome.findMany({
      where: { marketId },
      orderBy: { position: "asc" },
      select: { id: true },
    });

    await seedMarket(
      marketId,
      outcomes.map((outcome: { id: string }) => outcome.id),
      DEFAULT_SEED_CENTS
    );
    createdCount++;
  }

  console.log(
    `[initialMarkets] Baby Hasan seed complete: ${createdCount} created, ` +
      `${seededExistingCount} existing unseeded market(s) seeded`
  );
}
