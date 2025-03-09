export const mockAlternatives = [
  {
    id: "1",
    title: "Signal",
    replaces: "WhatsApp",
    description: "Signal ist ein sicherer Messenger mit Ende-zu-Ende-Verschlüsselung. Die App bietet alle wichtigen Funktionen wie Gruppenchats, Sprachanrufe und Videotelefonie, ohne dass Ihre Daten für Werbung verwendet werden.",
    reasons: "WhatsApp gehört zu Meta (Facebook) und teilt Metadaten für Werbezwecke. Die Privatsphäre der Nutzer ist nicht der Fokus des Unternehmens.",
    benefits: "Vollständige Ende-zu-Ende-Verschlüsselung, Open-Source, keine Werbung, keine Datensammlung, selbstlöschende Nachrichten und moderne Oberfläche.",
    website: "https://signal.org",
    category: "Kommunikation",
    upvotes: 120,
    approved: true,
    submitterId: "1",
    submitter: { id: "1", username: "datenschutz_fan" },
    createdAt: "2024-10-02T14:35:00Z",
    updatedAt: "2024-10-02T14:35:00Z",
    comments: []
  },
  {
    id: "2",
    title: "ProtonMail",
    replaces: "Gmail",
    description: "ProtonMail ist ein Ende-zu-Ende-verschlüsselter E-Mail-Dienst aus der Schweiz. Ihre E-Mails können auf dem Server nicht gelesen werden, da sie verschlüsselt gespeichert werden.",
    reasons: "Google scannt E-Mails für Werbezwecke und sammelt umfangreiche Nutzerdaten. Die Privatsphäre ist nicht gewährleistet.",
    benefits: "Verschlüsselung, keine Werbung, kein E-Mail-Scanning, Schweizer Datenschutz, freies Basiskonto verfügbar.",
    website: "https://proton.me/mail",
    category: "E-Mail",
    upvotes: 97,
    approved: true,
    submitterId: "2",
    submitter: { id: "2", username: "sicherheit_zuerst" },
    createdAt: "2024-10-01T09:22:00Z",
    updatedAt: "2024-10-01T09:22:00Z",
    comments: []
  },
  {
    id: "3",
    title: "DuckDuckGo",
    replaces: "Google",
    description: "DuckDuckGo ist eine Suchmaschine, die keine Benutzer trackt. Sie speichert Ihre Suchhistorie nicht und erstellt kein Nutzerprofil von Ihnen.",
    reasons: "Google sammelt umfangreiche Daten über Nutzer, um personalisierte Werbung zu schalten und Profile zu erstellen.",
    benefits: "Keine Verfolgung, keine Filterblasen, keine personalisierte Werbung, gleiche Suchergebnisse für alle Nutzer.",
    website: "https://duckduckgo.com",
    category: "Suche",
    upvotes: 145,
    approved: true,
    submitterId: "1",
    submitter: { id: "1", username: "datenschutz_fan" },
    createdAt: "2024-09-22T18:45:00Z",
    updatedAt: "2024-09-22T18:45:00Z",
    comments: []
  },
  {
    id: "4",
    title: "Firefox",
    replaces: "Google Chrome",
    description: "Firefox ist ein Open-Source-Browser, der von der gemeinnützigen Mozilla Foundation entwickelt wird. Er bietet starke Privatsphäre-Einstellungen und Tracking-Schutz.",
    reasons: "Chrome sammelt Nutzerdaten für Google und schränkt mit seiner Marktmacht die Web-Standards ein.",
    benefits: "Open-Source, Privatsphäre-Fokus, unabhängige Entwicklung, große Erweiterungsauswahl, geringerer Ressourcenverbrauch.",
    website: "https://www.mozilla.org/firefox",
    category: "Browser",
    upvotes: 88,
    approved: true,
    submitterId: "3",
    submitter: { id: "3", username: "web_freiheit" },
    createdAt: "2024-09-18T11:20:00Z",
    updatedAt: "2024-09-18T11:20:00Z",
    comments: []
  }
];

export const pendingAlternatives = [
  {
    id: "5",
    title: "Jitsi Meet",
    replaces: "Zoom",
    description: "Jitsi Meet ist eine kostenlose Open-Source-Videokonferenzlösung, die direkt im Browser ohne Installation funktioniert.",
    reasons: "Zoom hatte in der Vergangenheit mehrere Datenschutz- und Sicherheitsprobleme.",
    benefits: "Open-Source, keine Registrierung nötig, Ende-zu-Ende-Verschlüsselung, keine Zeitbegrenzung, hohe Qualität.",
    website: "https://meet.jit.si",
    category: "Kommunikation",
    upvotes: 0,
    approved: false,
    submitterId: "2",
    submitter: { id: "2", username: "sicherheit_zuerst" },
    createdAt: "2024-10-05T16:30:00Z",
    updatedAt: "2024-10-05T16:30:00Z",
    comments: []
  }
];

// Hilfsfunktion zum Abrufen einer Alternative nach ID
export function getAlternativeById(id: string) {
  return mockAlternatives.find(alt => alt.id === id) || 
         pendingAlternatives.find(alt => alt.id === id);
}
