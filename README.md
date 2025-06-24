# 📸 Google Photos Date Sync Script 

*Of hoe je Google's "geweldige" metadata export weer een beetje bruikbaar maakt* 🙄

## 🤔 Wat is dit eigenlijk?

Ooit geprobeerd om je Google Photos te exporteren via Google Takeout? Gefeliciteerd! Je hebt nu duizenden foto's met compleet verkeerde datums en een berg JSON bestanden die eruitzien alsof een robot ze heeft uitgekotst. 

Google heeft namelijk besloten dat het veel te makkelijk zou zijn om gewoon de originele datums op je foto's te bewaren. Nee, in plaats daarvan krijg je:
- 📷 Foto's met de export datum (super handig!)
- 📄 JSON bestanden met de *echte* datum verstopt erin
- 😵‍💫 Een migraine van het proberen om deze twee aan elkaar te koppelen

**Maar geen paniek!** Dit script redt je van Google's "minimalistische" aanpak en zorgt ervoor dat je foto's eindelijk weer de juiste datum hebben.

## ✨ Wat doet dit magische scriptje?

- 🔍 Vindt al je foto's (JPG, PNG, HEIC, etc.)
- 🕵️ Speurt naar de bijbehorende JSON metadata bestanden
- 📅 Haalt de *echte* datum eruit (photoTakenTime of creationTime)
- 🪄 Past deze datum toe op je foto bestand
- 🎉 Maakt je foto collectie weer bruikbaar!

## 🚀 Installatie

### Vereisten
Je hebt `jq` nodig (de JSON parser die Google vergeten is mee te leveren):

```bash
# Ubuntu/Debian (zoals een normale persoon)
sudo apt-get install jq

# macOS (voor de hipsters)
brew install jq

# CentOS/RHEL (voor de masochisten)
sudo yum install jq
```

### Script installeren
```bash
# Download het script
git clone https://github.com/jouw-username/google-photos-sync.git
cd google-photos-sync

# Maak het uitvoerbaar
chmod +x sync_photo_dates.sh

# Optioneel: Maak het globaal beschikbaar
sudo cp sync_photo_dates.sh /usr/local/bin/sync-google-photos
```

## 🎮 Gebruik

### Basis gebruik
```bash
# In de directory met je foto's en JSON bestanden
./sync_photo_dates.sh

# Of als je het globaal geïnstalleerd hebt
sync-google-photos
```

### Voor de voorzichtigen onder ons
```bash
# Dry-run (kijken wat er zou gebeuren zonder iets kapot te maken)
./sync_photo_dates.sh -n -v

# Recursief door alle subdirectories
./sync_photo_dates.sh -r

# Specifieke directory
./sync_photo_dates.sh -d ~/Downloads/Google-Photos-Export-Van-De-Hel
```

### Alle opties
```bash
-d, --directory DIR    # Specifieke directory (standaard: huidige directory)
-r, --recursive        # Ook subdirectories verwerken
-n, --dry-run         # Test mode (geen wijzigingen)
-v, --verbose         # Uitgebreide output (voor de nieuwsgierigen)
-h, --help            # Help (voor als je dit vergeet)
```

## 📁 Bestandsnamen die het script begrijpt

Google gebruikt verschillende naamconventies omdat consistentie blijkbaar geen prioriteit was:

- `vakantie.jpg` → `vakantie.jpg.json`
- `hond.jpeg` → `hond.jpeg.suppl.json` 
- `baby.png` → `baby.png.supplemental-metadata.json`

Het script is slim genoeg om al deze varianten te vinden (in tegenstelling tot Google's export functie).

## 🤓 Hoe werkt het?

1. **Foto's vinden**: Zoekt naar alle foto bestanden
2. **JSON detective werk**: Voor elke foto zoekt het naar bijbehorende metadata
3. **Datum extractie**: Haalt `photoTakenTime` of `creationTime` uit de JSON
4. **Tijdmachine**: Past de echte datum toe op het foto bestand
5. **Feest!**: Je foto's hebben eindelijk weer de juiste datum

## ⚠️ Waarschuwingen

- **Maak een backup!** (Serieus, doe dit. Google heeft al genoeg schade aangericht)
- Test eerst met `-n` (dry-run) om te zien wat er gebeurt
- Het script overschrijft de bestaande datums op je bestanden
- Werkt alleen met foto's die bijbehorende JSON metadata hebben

## 🐛 Problemen oplossen

### "jq: command not found"
Je hebt jq niet geïnstalleerd. Zie installatie instructies hierboven.

### "Geen JSON metadata gevonden"
Google heeft niet voor alle foto's metadata meegeleverd. Typisch Google. 🤷‍♂️

### "Permission denied"
Maak het script uitvoerbaar: `chmod +x sync_photo_dates.sh`

## 🎭 Voorbeelden

```bash
# Gewoon doen
./sync_photo_dates.sh

# Output:
# ✓ vakantie001.jpg -> 15-08-2023 14:30:25
# ✓ hond_speelt.png -> 03-09-2023 16:45:12
# ✓ baby_eerste_stap.heic -> 12-10-2023 09:15:33
# 
# === SAMENVATTING ===
# Verwerkte bestanden: 847
# Succesvol: 847
# Fouten: 0
```

## 🤝 Bijdragen

Heb je verbeteringen? Pull requests zijn welkom! Vooral als je een manier vindt om Google's export proces minder pijnlijk te maken.

## 📜 Licentie

MIT License - Gebruik het, verbeter het, deel het. Alles is beter dan Google's standaard export.

## 🙏 Dankwoord

- **Niet aan Google** - voor het maken van deze situatie noodzakelijk
- **Aan jq** - voor het redden van onze sanity
- **Aan bash** - voor het bestaan
- **Aan koffie** - voor het mogelijk maken van dit script

---

*"In een wereld waar Google je foto datums verneukt, is één script de held die we nodig hebben maar niet verdienen."* 🦸‍♂️

---

### 💡 Pro Tips

- Gebruik altijd `-v` voor de eerste keer, het is bevredigend om te zien hoe veel foto's hun juiste datum terugkrijgen
- Combineer met `-r` als Google je foto's in een miljoen subdirectories heeft gestopt
- Het script werkt ook met andere foto formaten dan JPG (PNG, HEIC, TIFF, etc.)

**Happy photo organizing!** 📸✨
