# 补丁来源与包内容

## 目标补丁

**Prototype® 新版 100% 汉化重译（第二版）**

| 项 | 值 |
| --- | --- |
| 汉化组 | 统筹 zxl5016（源太子）；技术 luna、Shimon、marvolo666；美工 手柄、谦逊、西部苦力怕；翻译 Major、下沉星球、Rico.Se7en、Pasta Anchovy、战地记者柳托夫 |
| 文本量 | 18401 条（UI + CG + 字幕） |
| 工期 | 2024.07.30 – 2025.05.23 |
| 发布 | 2025-10，2026-07 与 2026-10 仍有更新 |
| 前置优化 | emoose PrototypeFix — https://www.nexusmods.com/prototype/mods/52 |

它修掉了旧版 3DM 汉化的历史问题：后期按 ESC 跳菜单闪退、字体超 1MB 闪退、人名地名未汉化、阴谋之网未汉化、大部分字幕缺失。

## 下载

阿里云盘（主链接）：https://www.alipan.com/s/cnwDSb9BBNy

分享名 `Prototype®`，内含 `Prototype®` 文件夹（2026-10-10 更新）。

其他镜像（内容一致，任选其一；括号内为提取码）：

| 网盘 | 链接 |
| --- | --- |
| 123 云盘 | https://www.123865.com/s/0n8tjv-e1KEd |
| 天翼云盘 | https://cloud.189.cn/t/AfAZf2Iniqyi （s8ll） |
| 百度网盘 | https://pan.baidu.com/s/1-A1R0houwn_ofrZZeCwITQ?pwd=2km9 （2km9） |
| 夸克网盘 | https://pan.quark.cn/s/45e1fe149c88 |
| 微云 | https://share.weiyun.com/i174lkS3 |
| 迅雷云盘 | https://pan.xunlei.com/s/VObcQhpx_hA7XUk2Wn4rWewgA1?pwd=4ukv （4ukv） |
| UC 网盘 | https://drive.uc.cn/s/026e05f9e9be4 |
| 115 | https://115cdn.com/s/sww9man3w51?password=q8e4 （q8e4） |
| MEGA（国外） | https://mega.nz/folder/j8gyCRCD#hJ7t1V1gA1gRkydAl1oZoa |
| Google Drive（国外） | https://drive.google.com/drive/folders/16bogRsSv5sNTAsnLzRUkNj_TRkJxigXy |

还有一个 2.4 K 的链接汇总文本放在蓝奏云：https://wwkb.lanzouw.com/iWe9m38ikflg
（访问该链接需要先解 `acw_sc__v2` 的 JS 挑战，再向 `ajax.php` POST 一次验证；顺着 `el=2` 分支能拿到真实文件地址。）

图文教程与视频：B 站 opus `1124922015837323282`，安装视频合集 `BV1dTxozNEhC`，汉化历程 `BV1NPMGzmEyM`（UP 主「え源太子の」）。

## 已知的下载阻碍（重要）

这些网盘对约 1 GB 的补丁文件**都必须登录**才能下载，不要在这上面硬爬接口：

- 123 云盘返回 `{"code":5112,"message":"您需要注册登录或付费后下载"}`。
- 天翼云盘：`getShareInfoByCodeV2` 匿名能拿到 fileVO，但不返回 `shareId`，`listShareDir` 走不通。
- 阿里云盘：`adrive/v3/share_link/get_share_by_anonymous` 可匿名拿到 share_name 与顶层 file_id，但 `share_token` / 列目录需要登录态。

可行做法：让用户在自己已登录的浏览器或客户端里下载，然后把 `.7z` 路径给出来；或使用本机已安装的阿里云盘 / 迅雷客户端。Google Drive 与 MEGA 在中国大陆网络不可达。

## 包内容（解压后约 1.25 GB，14538 个文件、289 个目录）

| 目录 | 内容 |
| --- | --- |
| `Prototype®：优化文件` | `binkw32.dll`(2,248,704B，ASI 加载器)、`binkw32Hooked.dll`(171,008B，原 bink)、`prototype_fix.asi`、`prototype_fix.ini`、`prototypeenginef.dll`(20,205,568B)、`ApplyGameLaunchFix.bat`、`prototypef.vcdiff`、`xdelta3-3.1.0-i686.exe` |
| `Prototype®：汉化文件\汉化文件` | `art\`(48 个)、`audio\`(14319 个)、`movies\`(143 个)，加根级 `scripts.rcf`、`prototypeenginef.dll`，共 14512 个 |
| `Prototype®：汉化文件\解包rcf工具` | `ScarfaceExtractor.exe`(42,904B)、`解包rcf.bat` |
| `Prototype®：Dev Menu` | 可选。额外的 `prototypeenginef.dll` + `UnlockDevMenu = true` 的 ini |
| `Prototype®：音频修复` | 可选。雷蛇 7.1 虚拟环绕安装包，激活码需另购 |
| `Prototype®：修改器` | 可选。`Prototype®：Trainer.exe` |
| `Prototype®：必备运行库组件` | DirectX / PhysX / VC++ 合集，按需安装 |

## 校验

实测下载到的补丁包（2026-10-07 从镜像下载，1026 MB）：

文件：`Prototype®：第二版补丁.7z`
大小：`1076162829` 字节
SHA256：`9A6E8B444A9D4052CF6734D314E84C679AA177816C03202BA369DAF7D70FA7D0`

注意它是 **RAR5**，只是扩展名写成了 `.7z`。7-Zip 列表会提示 `Cannot open the file as [7z] archive` / `Type = Rar5` / `Offset = 313344`，属正常现象。

解压后未压缩体积 `1,248,513,869` 字节。7-Zip 解压结束应显示 `Everything is Ok`。
