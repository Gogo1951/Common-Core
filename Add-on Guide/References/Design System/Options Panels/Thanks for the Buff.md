# Thanks for the Buff: Options Panels

**State:** the live reference for on-panel lines and the whisper composer, and home of the emote grid, a pooled-checkbox widget built because about 255 AceConfig toggles froze the UI on every click. No mini-map button. Its feature switches come from `ns.FEATURE_SWITCHES`, close to `ns.FEATURES` but missing fields; sub-panel titles don't name their parent.
**Live code:** [`Options/Options-Utilities.lua`](https://github.com/Gogo1951/Thanks-for-the-Buff/blob/main/Options/Options-Utilities.lua), [`Options/Options.lua`](https://github.com/Gogo1951/Thanks-for-the-Buff/blob/main/Options/Options.lua), [`Options/Options-Emote-Grid.lua`](https://github.com/Gogo1951/Thanks-for-the-Buff/blob/main/Options/Options-Emote-Grid.lua).
**Needs first:** `Options-Kit.md` (in Common-Core).
**Labels:** `Type: Refactor`, `Type: Design`, `Area: Options`.
**Issue:** not filed yet.

## Panel Tree

| # | Tree label | Parent | Proposed page title (Decision 8) |
|---|---|---|---|
| 1 | Thanks for the Buff (TFTB) | root | |
| 2 | Give Thanks | root | |
| 2a | Emotes List | Give Thanks | **Give Thanks > Emotes List** |
| 2b | Ignored Buffs | Give Thanks | **Give Thanks > Ignored Buffs** |
| 3 | Good News | root | |
| 3a | Tracked Abilities | Good News | **Good News > Tracked Abilities** |
| 4 | Thank You Button | root | |
| 5 | Wave to Friends | root | |
| 6–8 | Profiles, Feedback & Support, Diagnostic Tools | root | |

Every panel registers as its builder function through `Kit.RegisterPanel` (Emotes List and Thank You Button are static tables today). The `/tftb` slash command moves out of `ns.RegisterOptionsPanels` to file scope in `Options/Options.lua`, as Slash Commands shows.

## Root Page

Description, Enable Welcome Message, Features, /Commands, then the Good to Go links (README-Notes). No mini-map toggle (no button).

- **Features** draws `Kit.FeatureSwitches(13)`, and **its description line goes** (Decision 5): the section holds only the switches, as in every other add-on.

## Features

`ns.FEATURES` replaces `ns.FEATURE_SWITCHES`, same three records and order, in the kit's shape: `setting = "enabled"` on each feature's own table becomes `store` + a dotted `setting` the kit's `Kit.Get` reads (for example `store = "profile", setting = "strangers.enabled"`; take each path from `ns.GetFeatureSwitch`). `onChange` becomes `apply`.

| feature | caption |
|---|---|
| Give Thanks | `GIVE_THANKS_ENABLE` |
| Good News | `GOOD_NEWS_ENABLE` |
| Wave to Friends | `WAVE_ENABLE` |

`Kit.FeatureSwitch` reads and writes a dotted `setting` the way `Kit.Get` and `Kit.Set` do, so the nested keys need no alias.

## Panels

- **Give Thanks:** the three Praise Limits rows become `Kit.LabelRow`, keeping `DefineSecondsSelect`'s nearest-value snap as their `get`. Praise Delay and Sound become `Kit.ToggleRow`, Sound with `Kit.SoundPreview` (today a literal 0.15 and a default-width toggle). The print Example becomes `Kit.Example`, built through the print helper with `Kit.PrintedLine` (today it joins `GetPrintPrefix()` to the body by hand).
- **Whisper composer** (`ns.DefineWhisperComposer`): stays Thanks for the Buff's. Its rows move onto the grid: Send Messages In becomes `Kit.LabelRow` (today 0.9 + 2.5); the Message row keeps its five cells totalling 3.4; the tokens and Too Long lines keep their indent; Too Long becomes `Kit.WarningLine`; its Reset becomes `Kit.ResetRow` under the box (Decision 10).
- **Emotes List:** unchanged. The emote grid stays: it is the pattern for any checklist past 64 boxes (README → Patterns → Long checklist).
- **Ignored Buffs:** a spell list, not an item list, so it stays its own; `Kit.PrepareTree` sets its 176 sidebar and home. Its row widths move from `OPTIONS_TREE_ROW_WIDTH` (same 2.5) to `Kit.TREE_ROW_WIDTH`.
- **Good News > Tracked Abilities:** classes sort by localized name, not by class token (today `DRUID`, `HUNTER` …, which reads in English order on every client).
- **Wave to Friends:** the Friends tab's file-local `SubRow` becomes `Kit.SubRow`; the Custom List's off line becomes `Kit.StatusLine` (silver; today red, Decision 9). The three tabs stay out of the table while off, as Widget Conventions requires.

## Onto the Kit

- Copy `Options/Options-Kit.lua`; delete the grid from `Data/Data.lua` (`OPTIONS_PROMOTE_WIDTH` stays).
- `Options-Utilities.lua`: delete the standard helpers, `OptionsLinkRow` (becomes `Kit.LabelRow`), `TintText` (`Kit.Tint`), `OptionsExample`, `OptionsFeatureToggle`, `GetFeatureSwitch` / `SetFeatureSwitch`, `OptionsTogglePairs`, `HideAllExcept`, and the `_RowLabel` widget (`Kit.Label`'s `desc` uses the stock InteractiveLabel). Keep the composer, `SampleWhisper`, `MarkerAsTexture` (or `Kit.Markers`), the emote helpers.
- **One Refresh:** delete `NotifyAllPanels` and the single-panel `NotifyChange` calls (`Wave-To-Friends.lua:33`, `Ignored-Buffs.lua:25`, `Emote-Grid.lua:275`).

## Strings

`NOTIFICATIONS_SOUND_PREVIEW_DESCRIPTION` → `OPTIONS_SOUND_PREVIEW_DESCRIPTION`; `OPTIONS_FEATURES_DESCRIPTION` retires; `OPTIONS_RESET` "Reset" joins.

## Keeps

README-Notes: Main panel ends with Good to Go links; In-game name carries the Short Name; Thank You Button whispers skip the composer and go out unbranded; Per-character Ignored Buffs on a shared profile.

## Check in Game

- [ ] Emotes List clicks stay instant (the grid is untouched).
- [ ] Good News > Tracked Abilities lists classes in your client's alphabetical order.
- [ ] A too-long whisper shows the red line; shortening it clears the line.
