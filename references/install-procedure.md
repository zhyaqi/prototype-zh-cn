# 汉化安装步骤（已在 Steam 版实测走通）

基准环境：Steam AppID 10150，游戏目录 `...\steamapps\common\Prototype`，Windows 简体中文系统。2026-10-07 完整执行过一次并验证主菜单为中文。

## 0. 前置检查

1. 游戏目录必须是**纯净英文原版**：存在 `00audio.rcf`、`01audio.rcf`、`00woi.rcf`、`01woi.rcf`、`02woi.rcf`、`03woi.rcf`、`art.rcf`、`movies.rcf` 这 8 个包，且**没有** `art\`、`audio\`、`movies\` 文件夹。
2. **先启动一次英文版游戏再退出**。Steam 首次运行会装 .NET 3.5 / DirectX / VC++；首次运行后 `Documents\Prototype\profile.bin` 出现，可作为已启动过的标志。
3. 用 7-Zip 解压补丁包，得到 `Prototype®：第二版补丁` 目录（下面称作 PATCH）。

## 1. 备份（可回退的关键）

把游戏目录里会被覆盖的小文件复制到备份目录（示例用 `D:\PrototypeBackup`）：

`prototypef.exe`、`prototypeenginef.dll`、`binkw32.dll`、`cementfiles.p3d`、`skuinfo.p3d`、`proto_uv.dat`、`10150_install.vdf`

再记录 11 个 `.rcf` 的名称与大小（`.rcf` 合计约 7.74 GB，不必整份复制，Steam 的「验证游戏文件完整性」也能还原）。

## 2. 优化文件

1. 把 `PATCH\Prototype®：优化文件\` 里的**全部文件**复制到游戏目录（`binkw32.dll`、`binkw32Hooked.dll`、`prototype_fix.asi`、`prototype_fix.ini`、`prototypeenginef.dll`、`ApplyGameLaunchFix.bat`、`prototypef.vcdiff`、`xdelta3-3.1.0-i686.exe`）。
2. 在游戏目录执行 `ApplyGameLaunchFix.bat`。它会 `ren prototypef.exe prototypef.exe.bak`，再用 xdelta3 生成打过补丁的 `prototypef.exe`。成功输出：

   `xdelta3: finished in ...ms; input 5338 output 2275824 bytes (42634.39%)` 与 `Patch applied successfully.`

   该 bat 末尾有 `pause`，用 `cmd /c "... && ApplyGameLaunchFix.bat < nul"` 可以非交互执行。
3. 删除这 4 个：`ApplyGameLaunchFix.bat`、`prototypef.vcdiff`、`xdelta3-3.1.0-i686.exe`、`prototypef.exe.bak`。

## 3. 解包 rcf

1. 把 `PATCH\Prototype®：汉化文件\解包rcf工具\` 里的 `ScarfaceExtractor.exe` 和 `解包rcf.bat` 复制到游戏目录。
2. 在游戏目录运行 `解包rcf.bat`，提示时输入 `1` 回车（`'1' | cmd.exe /c "... && 解包rcf.bat"`）。**不要**用管理员身份运行。
3. 它会依次解包 8 个 rcf（实测 30 秒左右），解出 `art\`(2602 个/573 MB)、`audio\`(14614 个/1951 MB)、`movies\`(301 个/4744 MB)，并把每个包改名为 `<名字>.rcf.备份`（注意 `%%~nf` 对 `art.rcf` 得到 `art`，所以是 `art.rcf.备份`）。
4. 检查 `extraction_log.txt` 里每个包都出现「RCF文件提取完成」。

`cells.rcf` 和 `shaders.rcf` 不在解包清单里，保持原样。

## 4. 覆盖汉化文件

把 `PATCH\Prototype®：汉化文件\汉化文件\` 的**内容**合并复制进游戏目录（不是把 `汉化文件` 这层目录本身塞进去）。

实测共 **14512 个文件**，其中 **14511 个与游戏内同名**（会被替换），1 个新增。用 robocopy 约 12 秒：`robocopy <源> <游戏目录> /E /NFL /NDL /NJH /NP /R:1 /W:1`，退出码 3 属正常。

复制后抽查哈希，`prototypeenginef.dll`、`scripts.rcf`、`art\hud\fonts_latin.gfx` 应与汉化源一致。

## 5. 清理（不做游戏起不来）

把下面 11 个文件移出游戏目录（删除也可以，但移到备份目录可保留回退能力）：

`00audio.rcf.备份`、`00woi.rcf.备份`、`01audio.rcf.备份`、`01woi.rcf.备份`、`02woi.rcf.备份`、`03woi.rcf.备份`、`art.rcf.备份`、`movies.rcf.备份`、`解包rcf.bat`、`extraction_log.txt`、`ScarfaceExtractor.exe`

完成后游戏目录应只剩 `cells.rcf`、`scripts.rcf`、`shaders.rcf` 三个 rcf，加上 `art\ audio\ movies\` 三个文件夹。

## 6. 验证

Steam 启动游戏。主菜单应为：主菜单 / 新游戏 /【继续游戏】/ 选项 / 额外 / 退出。

截屏核对时注意：菜单右侧那列很暗的「数字 + 小方块」是原版背景装饰，不是乱码或缺字。

## 7. 交给玩家的收尾设置

- **字幕默认关闭**，需要在选项里手动开启；字幕延迟设 `32M`，越低越好。
- 视频设置：分辨率自适应不可改，其余调到最高。
- 鼠标灵敏度「中等 12 以上」；支持 XBOX 手柄与震动。
- Steam 设置 → 游戏中 → 打开「显示帧数等详情」。
- 作弊码 `→→←↓↑↑↑↓` 解锁「人体冲浪」（空中长按鼠标左键）。

## 回退到英文原版

1. 删除游戏目录下的 `art\`、`audio\`、`movies\`。
2. 删除 `binkw32Hooked.dll`、`prototype_fix.asi`、`prototype_fix.ini`。
3. 把第 5 步移出的 8 个 `.rcf.备份` 放回并去掉 `.备份` 后缀。
4. 用第 1 步备份的原始 `prototypef.exe` / `prototypeenginef.dll` / `binkw32.dll` 覆盖回去。
5. 更省事：Steam → 游戏属性 → 已安装文件 → **验证游戏文件完整性**，让它自动还原（会重新下载约 7.7 GB）。

## 可选组件（默认不装）

- **高清材质纹理**（另一个约 2.6 GB 的包）：画质提升，但启动前黑屏 30 秒到 1 分钟、可能闪退、掉 10–20 帧。
- **Dev Menu**：替换成 `UnlockDevMenu = true` 的 `prototype_fix.ini` + 对应 `prototypeenginef.dll`，主页可开调试菜单，进存档后 `ESC` 再按 `~` 调出。
- **音频修复**：装雷蛇 7.1 虚拟环绕（激活码需另购），把系统扬声器切到 7.1；若出现无声/声音小/游戏无响应，把音频采样率改成 48000 Hz。
- **修改器**：`Prototype®：Trainer.exe`，游戏内按 `F1` 呼出。
