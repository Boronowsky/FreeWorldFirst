import * as z from "zod";

export const createAlternativeSchema = z.object({
  title: z
    .string()
    .min(3, "Der Titel muss mindestens 3 Zeichen lang sein")
    .max(100, "Der Titel darf maximal 100 Zeichen lang sein"),
  replaces: z
    .string()
    .min(3, "Der zu ersetzende Dienst muss mindestens 3 Zeichen lang sein")
    .max(100, "Der zu ersetzende Dienst darf maximal 100 Zeichen lang sein"),
  description: z
    .string()
    .min(20, "Die Beschreibung muss mindestens 20 Zeichen lang sein")
    .max(2000, "Die Beschreibung darf maximal 2000 Zeichen lang sein"),
  reasons: z
    .string()
    .min(20, "Die Gründe müssen mindestens 20 Zeichen lang sein")
    .max(1000, "Die Gründe dürfen maximal 1000 Zeichen lang sein"),
  benefits: z
    .string()
    .min(20, "Die Vorteile müssen mindestens 20 Zeichen lang sein")
    .max(1000, "Die Vorteile dürfen maximal 1000 Zeichen lang sein"),
  website: z
    .string()
    .url("Bitte geben Sie eine gültige URL ein")
    .optional()
    .or(z.literal("")),
  category: z
    .string()
    .min(1, "Bitte wählen Sie eine Kategorie aus"),
});

export type CreateAlternativeFormValues = z.infer<typeof createAlternativeSchema>;
