# VaultOS Internationalization (i18n)

Internationalization support for VaultOS.

## Translation System

VaultOS uses gettext for translations.

## Translation Files

Translation templates and files are in:
```
src/i18n/
├── templates/        # POT files (translation templates)
└── locales/          # PO files (translations by language)
    ├── en/
    ├── es/
    ├── de/
    └── ...
```

## Creating Translations

1. Extract strings: `xgettext` to create POT files
2. Create PO file for language: `msginit`
3. Translate strings in PO file
4. Compile translations: `msgfmt` to create MO files

## Supported Languages

Initial support:
- English (en)
- Spanish (es)
- German (de)
- French (fr)
- Japanese (ja)

## Adding a Language

1. Create locale directory: `src/i18n/locales/xx/`
2. Copy template: `cp template.pot locales/xx/vaultos.po`
3. Translate strings
4. Compile: `msgfmt vaultos.po -o vaultos.mo`
5. Install: Place MO file in `/usr/share/locale/xx/LC_MESSAGES/`

## RTL Support

Right-to-left language support is planned for future releases.

## Tools

- `xgettext` - Extract translatable strings
- `msginit` - Initialize translation file
- `msgfmt` - Compile translation file
- `msgmerge` - Update translation file

