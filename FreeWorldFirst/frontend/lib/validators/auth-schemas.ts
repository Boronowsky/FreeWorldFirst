import * as z from "zod";

export const loginSchema = z.object({
  email: z.string().email("Bitte geben Sie eine gültige E-Mail-Adresse ein"),
  password: z.string().min(8, "Das Passwort muss mindestens 8 Zeichen lang sein"),
});

export const registerSchema = z.object({
  username: z
    .string()
    .min(3, "Der Benutzername muss mindestens 3 Zeichen lang sein")
    .regex(/^[a-zA-Z0-9_-]+$/, "Der Benutzername darf nur Buchstaben, Zahlen, Unterstriche und Bindestriche enthalten"),
  email: z.string().email("Bitte geben Sie eine gültige E-Mail-Adresse ein"),
  password: z.string().min(8, "Das Passwort muss mindestens 8 Zeichen lang sein"),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Die Passwörter stimmen nicht überein",
  path: ["confirmPassword"],
});

export type LoginFormValues = z.infer<typeof loginSchema>;
export type RegisterFormValues = z.infer<typeof registerSchema>;
