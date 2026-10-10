---
name: prototype-zh-cn
description: Localize the 2009 game PROTOTYPE (虐杀原形, Steam AppID 10150) to Simplified Chinese using the community 100% retranslation patch and its mod layer. Use when asked to 汉化/汉化补丁/中文化 this game or to repair such an install. Not for the JavaScript `prototype` object, and not for PROTOTYPE 2.
metadata:
  short-description: 汉化《虐杀原形》(PROTOTYPE 2009)
---

# PROTOTYPE (2009) 汉化

Goal: make `PROTOTYPE` (Radical Entertainment 2009, Steam AppID 10150, 中文名《虐杀原形》) display Simplified Chinese.

Use the community patch **Prototype® 新版 100% 汉化重译（第二版）** (源太子 / zxl5016 团队, 18401 条文本, 2025-10 发布). Do not attempt to translate the game yourself — see below.

## Why a hand-rolled translation is the wrong path

The UI text lives inside Radical's `ATG CORE CEMENT LIBRARY` `.rcf` archives and is rendered by Scaleform GFx bitmap font atlases (`art\hud\fonts_latin.gfx`). The game has no system-font fallback and hardcoded limits that crash when the font exceeds ~1 MB, so a custom translation would also require rebuilding the font atlas and patching the engine. The community patch already solved all of that.

## What the patch actually does

It does **not** swap a text file. It converts the game from packed archives to loose files, in four phases:

1. **Optimization layer (required).** emoose's PrototypeFix: replace `binkw32.dll` with an ASI loader, add `prototype_fix.asi` / `prototype_fix.ini`, replace `prototypeenginef.dll` with a build that accepts the large CJK font, and xdelta-patch `prototypef.exe` (`2,462,200` → `2,275,824` bytes) via the bundled `ApplyGameLaunchFix.bat`.
2. **Unpack.** `ScarfaceExtractor.exe` + `解包rcf.bat` extract 8 `.rcf` archives into `art\`, `audio\`, `movies\` (~7.3 GB) and rename each archive to `*.rcf.备份`.
3. **Overwrite.** Copy 14511 same-named Chinese files over the unpacked tree, plus a replacement `scripts.rcf` and `prototypeenginef.dll`.
4. **Clean up.** The 8 `*.rcf.备份` files plus `解包rcf.bat`, `extraction_log.txt`, `ScarfaceExtractor.exe` must be removed, or the game will not start.

`cells.rcf` and `shaders.rcf` stay packed and untouched.

## Preconditions — do not skip these

- **Clean English install.** If any prior 汉化/优化 was applied, delete the game folder, uninstall in Steam, reinstall, then re-apply.
- **Launch the English game once and exit before patching.** Steam installs .NET 3.5 / DirectX / VC++ runtimes on that first run. Skipping it is the most common cause of "game won't start" afterwards.
- Keep the game path ASCII-only (the default `...\steamapps\common\Prototype` is fine).
- Budget ~10 GB free on the game drive: unpacking adds ~7.3 GB before the archives are removed.
- The patch archive is a **RAR5 file named `.7z`** with a 313,344-byte prefix; 7-Zip reads it normally, but an extension check will mislead you. Verify the SHA-256 in [references/patch-sources.md](references/patch-sources.md).

## Doing the work

Read [references/install-procedure.md](references/install-procedure.md) before touching someone's install — it has the verified step-by-step and the rollback plan.

`scripts/install-prototype-zh.ps1` automates the whole sequence. It is dry-run by default and only mutates with `-Apply`:

```powershell
pwsh -File scripts/install-prototype-zh.ps1 -PatchRoot 'D:\PrototypePatch\Prototype®：第二版补丁'
pwsh -File scripts/install-prototype-zh.ps1 -PatchRoot 'D:\PrototypePatch\Prototype®：第二版补丁' -Apply
```

Where to get the patch, plus mirrors and package contents: [references/patch-sources.md](references/patch-sources.md).

## Verify the result

Launch through Steam and check the main menu reads 主菜单 / 新游戏 /【继续游戏】 / 选项 / 额外 / 退出. Then tell the user the one thing the patch cannot do for them: **subtitles are off by default** and must be enabled in Options, with the subtitle delay set to `32M`.
