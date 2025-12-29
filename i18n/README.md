# VaultOS Internationalization (i18n)

Internationalization and translation support for VaultOS.

## Translation System

VaultOS uses gettext for translations:
- `.po` files - Translation source files
- `.pot` - Template files
- `.mo` - Compiled binary files

## Translation Files

Translations are stored in:
- `i18n/locales/` - Translation files by language
- `/usr/share/locale/` - Installed translations

## Supported Languages

- English (en) - Default
- (Additional languages to be added)

## Translation Tools

### Extract Strings
```bash
xgettext --from-code=UTF-8 -o i18n/vaultos.pot source_files
```

### Update Translations
```bash
msgmerge -U i18n/locales/LANG/vaultos.po i18n/vaultos.pot
```

### Compile Translations
```bash
msgfmt -o i18n/locales/LANG/vaultos.mo i18n/locales/LANG/vaultos.po
```

## Adding a Translation

1. Create language directory:
   ```bash
   mkdir -p i18n/locales/LANG
   ```

2. Initialize translation file:
   ```bash
   msginit -l LANG -i i18n/vaultos.pot -o i18n/locales/LANG/vaultos.po
   ```

3. Translate strings in `.po` file

4. Compile translation:
   ```bash
   msgfmt -o i18n/locales/LANG/vaultos.mo i18n/locales/LANG/vaultos.po
   ```

## Language Codes

Use ISO 639-1 language codes:
- `en` - English
- `es` - Spanish
- `fr` - French
- `de` - German
- `ja` - Japanese
- `zh` - Chinese
- etc.

## Locale Configuration

Set system locale:
```bash
localectl set-locale LANG=lang_COUNTRY.UTF-8
```

## RTL Support

Right-to-left language support is planned for future release.

## Contributing Translations

See [Contributing Guide](../docs/developer.md) for translation contribution guidelines.

