# Carbon: dark phpBB 3.3 theme for TechAddict.Ro

A dark, tech-oriented style for the forum at https://techaddict.ro/forum/.
It is a child of prosilver (phpBB 3.3.19) and keeps prosilver's templates,
markup and behaviour. Only the colours, layout chrome, brand header and page
icons change.

Live: style name `Carbon`, style id `2`, board default style since 2026-11-21.

## Layout of this repository

```
styles/techaddict/
  style.cfg                     style metadata, parent = prosilver
  theme/colours.css             dark palette and colour rules (rewritten)
  theme/techaddict.css          modern layout, typography, components
  theme/stylesheet.css          import list, ends with techaddict.css
  theme/*.css, theme/images     unmodified prosilver 3.3.19 theme files
  template/overall_header.html  brand block, SVG favicon, theme-color
  template/navbar_header.html   adds the ta-topnav class
  template/*.html               unmodified prosilver 3.3.19 templates
ext/techaddict/acpstyle/        dark ACP extension (CSS injected after admin.css)
tools/                          deploy, screenshots, and server cleanup scripts
INCIDENT-2026-11-21.md          WordPress compromise cleanup record
```

The child style ships the whole prosilver theme and template set on purpose:
phpBB does not fall back to the parent for template and theme files, so a
self-contained directory is what makes a child style installable.

## Design

- Palette: near-black `#0a0e13` page, `#111821` cards, `#24313f` borders,
  cyan `#22d3ee` accent, violet `#8b7cff` secondary, `#dfe7f0` text.
- Type: system UI stack (Segoe UI, Roboto, Inter when installed), monospace
  stack for code. No web fonts and no JavaScript.
- Chrome: rounded cards, sticky top navigation with blur, pill search field,
  icon tiles drawn with the Font Awesome font already shipped by phpBB.
- Brand: inline SVG prompt mark and an SVG favicon in `overall_header.html`,
  so no image upload is needed.
- Read/unread, locked, sticky, announcement and moved icons are all recoloured
  icon-font glyphs; no bitmap folder icons remain.

## Install on another phpBB 3.3 board

1. Copy `styles/techaddict` into the board's `styles/` directory.
2. ACP > Customise > Styles > Install styles, install `Carbon`.
3. ACP > General > Board settings > Default style: `Carbon`.
   Users with `user_style` set to prosilver keep their choice; set
   `override_user_style` or update `phpbb_users.user_style` if everyone should
   switch immediately.
4. Purge the board cache: ACP > General > Purge the cache, or
   `php -d memory_limit=-1 bin/phpbbcli.php cache:purge`.

### Dark ACP

`ext/techaddict/acpstyle` is a small phpBB extension. It injects
`styles/all/theme/acp.css` after the admin stylesheet. Copy the extension into
`ext/techaddict/acpstyle`, then enable it with
`bin/phpbbcli.php extension:enable techaddict/acpstyle` and purge the cache.
Disabling it returns the ACP to the stock light styling.

The database rows created on techaddict.ro:

```sql
INSERT INTO phpbb_styles
  (style_name, style_copyright, style_active, style_path, bbcode_bitfield, style_parent_id, style_parent_tree)
VALUES
  ('Carbon', '(c) TechAddict.Ro', 1, 'techaddict', '//g=', 1, '');
```

`style_parent_id` must be the installed prosilver style id (1 on a stock board).

## Rollback

```
UPDATE phpbb_config SET config_value = '1' WHERE config_name = 'default_style';
UPDATE phpbb_users SET user_style = 1 WHERE user_style = 2;
```

Then purge the board cache. The style row and files can stay installed while
the board runs on prosilver.

## Known limits

- Template overrides are pinned to prosilver 3.3.19. After a phpBB update,
  diff `overall_header.html` and `navbar_header.html` against the new prosilver
  copies before switching the default style.
- Dark only. There is no light variant.
- Category descriptions are stored in `forum_desc` but phpBB 3.3 does not
  output them on the index, so the style cannot show them without an extension.
- The control panel sidebar is pinned to two columns at 901px and wider. That
  also removes a headless-Chrome quirk where `max-device-width` is reported as
  800px.

## Licence

Derived from prosilver, (c) phpBB Limited, GPL-2.0. The style keeps that
licence; phpBB and Font Awesome notices are unchanged.
