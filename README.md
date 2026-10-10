# 虐杀原形 / PROTOTYPE 汉化 · Codex Skill

把 2009 年的 **PROTOTYPE**（Radical Entertainment，Steam AppID 10150，中文名《虐杀原形》）装成**简体中文**的 Codex skill。

汉化内容来自社区项目 **《Prototype® 新版 100% 汉化重译（第二版）》**（源太子 / zxl5016 团队，18401 条 UI/CG/字幕文本，工期 2024.07–2025.05）。

> 不是 JavaScript 的 `prototype` 对象，也不是《虐杀原形 2》。

---

## 为什么值得做成 skill

这个汉化**不是替换一个文本文件**。游戏文本封在 Radical 的 `ATG CORE CEMENT LIBRARY` `.rcf` 包里，用 Scaleform GFx 位图字体渲染（`art\hud\fonts_latin.gfx`），没有系统字体回退，字体超过 1 MB 还会闪退——所以自己翻译根本走不通，必须用社区方案。

而社区方案的安装过程有四个阶段，每一步都有会让游戏起不来的坑：

1. **优化层（必需）**：替换 `binkw32.dll` 为 ASI 加载器、加 `prototype_fix.asi/.ini`、替换能接受中文大字体的 `prototypeenginef.dll`，并用 xdelta3 给 `prototypef.exe` 打补丁。
2. **解包**：把 8 个 `.rcf` 解成松散文件（`art\ audio\ movies\`，约 7.3 GB），原包改名为 `.rcf.备份`。
3. **覆盖**：14511 个同名汉化文件合并进去。
4. **清理**：8 个 `.rcf.备份` + 3 个工具文件必须移出，否则游戏起不来。

这个 skill 把这些判断固化了：什么时候该拒绝、哪些文件必须删、怎么回退。

## 安装

Windows（PowerShell）：

```powershell
git clone https://github.com/zhyaqi/prototype-zh-cn.git "$env:USERPROFILE\.codex\skills\prototype-zh-cn"
```

macOS / Linux：

```bash
git clone https://github.com/zhyaqi/prototype-zh-cn.git ~/.codex/skills/prototype-zh-cn
```

也可以直接把仓库目录复制到 `~/.codex/skills/` 下。

## 使用

在 Codex 里说「帮我汉化一下本机的虐杀原形」即可自动触发；也可以显式调用：

```text
$prototype-zh-cn 把本机安装的《虐杀原形》汉化成简体中文
```

脚本本身默认是**预演（dry-run）**，只有显式加 `-Apply` 才会真正改动游戏目录：

```powershell
# 只打印将要做什么
pwsh -File scripts/install-prototype-zh.ps1 -PatchRoot 'D:\PrototypePatch\Prototype®：第二版补丁'

# 真正执行
pwsh -File scripts/install-prototype-zh.ps1 -PatchRoot 'D:\PrototypePatch\Prototype®：第二版补丁' -Apply
```

脚本会在动手前拦截这些情况：游戏目录缺失原版 `.rcf`、已经存在 `art\ audio\ movies\`（即已汉化过）、没检测到启动过英文版的痕迹。

## 补丁下载

**阿里云盘（主链接）**：https://www.alipan.com/s/cnwDSb9BBNy

分享名 `Prototype®`，内含同名的 `Prototype®` 文件夹。补丁本体是 `Prototype®：第二版补丁.7z`（约 912.9 MB），另有一个可选的高清材质纹理包（约 2.6 GB）。

123 云盘、天翼、百度、夸克、迅雷、115、微云等 9 个镜像，以及包内容清单与 SHA256 见 [references/patch-sources.md](references/patch-sources.md)。

注意：这些网盘对约 1 GB 的文件**都要求登录**才能下载，没有可行的匿名直连接口。

## 前置条件

- Steam 正版 PROTOTYPE（AppID 10150），且是**纯净英文原版**。若装过别的汉化，先删除游戏目录、Steam 卸载后重装。
- **先启动一次英文版游戏再退出**。Steam 首次运行会装 .NET 3.5 / DirectX / VC++ 运行库，跳过这步是「打完补丁进不去游戏」最常见的原因。
- 游戏路径保持纯英文（Steam 默认路径即可）。
- 游戏所在盘预留约 10 GB：解包会先多出约 7.3 GB 松散文件。

## 仓库结构

| 路径 | 说明 |
| --- | --- |
| `SKILL.md` | skill 入口：目标、机制说明、硬性前置条件 |
| `references/patch-sources.md` | 下载地址与镜像、包内容、SHA256、网盘下载阻碍的实测证据 |
| `references/install-procedure.md` | 实测逐步安装步骤、验证方法、完整回退方案、可选组件 |
| `scripts/install-prototype-zh.ps1` | 一键安装脚本（默认 dry-run，带备份与前置校验） |
| `agents/openai.yaml` | 界面元数据 |

## 免责声明

本仓库**不包含**游戏本体，也**不包含**任何汉化文件或补丁内容，只提供安装说明与自动化脚本。

汉化文件版权归《Prototype® 新版 100% 汉化重译》制作组所有，仅供学习交流，禁止商用。请支持正版。
