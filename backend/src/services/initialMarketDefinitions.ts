export type InitialMarket = {
  question: string;
  outcomes: string[];
  eventTag: string;
  familySide: string;
  customTags?: string[];
};

export const BABY_HASAN_MARKETS: InitialMarket[] = [
  {
    question: "Gender?",
    outcomes: ["Boy", "Girl"],
    eventTag: "Reveal",
    familySide: "Baby Hasan",
    customTags: ["headline"],
  },
  {
    question: "Will Alif cry at the gender reveal?",
    outcomes: ["Yes", "No"],
    eventTag: "Family",
    familySide: "Alif",
    customTags: ["emotional"],
  },
  {
    question: "Will Anusha cry at the gender reveal?",
    outcomes: ["Yes", "No"],
    eventTag: "Family",
    familySide: "Anusha",
    customTags: ["emotional"],
  },
  {
    question: "What color will Alif wear?",
    outcomes: ["Pink", "Blue", "Yellow", "White/Beige"],
    eventTag: "Outfits",
    familySide: "Alif",
    customTags: ["fashion"],
  },
  {
    question: "What color will Anusha wear?",
    outcomes: ["Pink", "Blue", "Yellow", "White/Beige"],
    eventTag: "Outfits",
    familySide: "Anusha",
    customTags: ["fashion"],
  },
  {
    question: "Will Anusha start showing by gender reveal day?",
    outcomes: ["Yes", "No"],
    eventTag: "Family",
    familySide: "Anusha",
    customTags: ["baby"],
  },
  {
    question: "Will the cake be vanilla or chocolate?",
    outcomes: ["Vanilla", "Chocolate", "Both", "Neither"],
    eventTag: "Food",
    familySide: "Both",
    customTags: ["cake"],
  },
  {
    question: "Will Anusha's dad cry at the gender reveal?",
    outcomes: ["Yes", "No"],
    eventTag: "Family",
    familySide: "Anusha",
    customTags: ["emotional"],
  },
  {
    question: "What time will the gender reveal happen?",
    outcomes: ["1pm", "2pm", "3pm", "4pm"],
    eventTag: "Reveal",
    familySide: "Both",
    customTags: ["timing"],
  },
  {
    question: "What shoes will Anusha be wearing?",
    outcomes: ["Sandals", "Heels", "Flats", "Sneakers"],
    eventTag: "Outfits",
    familySide: "Anusha",
    customTags: ["fashion"],
  },
  {
    question: "Will there be a malfunction during the reveal?",
    outcomes: ["Yes", "No"],
    eventTag: "Reveal",
    familySide: "Both",
    customTags: ["chaos"],
  },
  {
    question: "Over/under 80 guests",
    outcomes: ["Over", "Under"],
    eventTag: "Guests",
    familySide: "Both",
    customTags: ["attendance"],
  },
];
