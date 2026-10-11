# OpenACT

开源 ACT 游戏（lua）——**Unity 2019.2.0f1 + [xLua](https://github.com/Tencent/xLua)** 的玩法原型工程。设计思路：**C# 只做薄薄一层胶水**（加载 lua、注入物体、转发生命周期和物理回调），游戏逻辑全部写在 lua 里。

依赖：

- [xLua](https://github.com/Tencent/xLua)（已内置，含生成代码与 WebGL 版 Lua 源码）
- [castleDB](http://castledb.org)：编辑 `.cdb` 数据文件（角色表、地图数据等，在 `Assets/StreamingAssets/1/Resource/` 下）

## 四个工具场景

| 场景 | 内容 |
| --- | --- |
| `Assets/1/Scenes/tool1.unity` | 角色编辑器：拼装角色、部件、GUI 框架、调动画与碰撞 |
| `Assets/1/Scenes/tool2.unity` | 随机地图生成器：castleDB 数据 → tile 房间拼接 |
| `Assets/1/Scenes/tool3.unity` | 战斗玩法测试：LObject / LPlayer / LCollider / LAI 玩法骨架 |
| `Assets/1/Scenes/tool4.unity` | 精灵图集生成器：读 castleDB 角色表，用 pngLua 拼图集 |

（`Assets/0/` 下是 xLua 官方教程示例，与本项目逻辑无关。）

## 架构

```
GameLoader（场景配置 scripts 列表 + folder）
   │  UnityWebRequest 把每个 lua 源文件读进来
   ▼
LuaManager（单例缓存：text + 原始字节）
   │  全部就绪后 SetActive(init)
   ▼
LuaBehaviour（挂在需要 lua 驱动的物体上，物体名 = lua 文件名）
   · 每个物体独立 scriptEnv（元表指向 Global，防脚本间全局变量冲突）
   · injections 注入物体，self 指向自身 MonoBehaviour
   · 转发 start/update/fixedupdate/ondestroy/ongui/onDrawGizmos
     与 2D/3D 的 trigger/collision 回调
   · 每秒 luaEnv.Tick() 一次，回收 lua 侧引用
```

- **脚本查找**：`LuaBehaviour` 用「物体名（小写）」去 `LuaManager` 里找同名的 lua 文件，所以 prefab/物体名必须和 lua 文件名一致；`Instantiate` 出来的 " (Clone)" 后缀会自动剥掉
- **CustomLoader**（require 的解析）：先查 GameLoader 预载的**原始字节**缓存（WebGL 下唯一来源），桌面端再落盘读文件；子目录库走 `package.path`（tool4 的 pngLua 就是这么挂的）
- **编码**：脚本缓存按原始字节存取，GBK 编码的 lua 不会被 UTF-8 解码弄坏

## Lua 模块

| 模块 | 职责 |
| --- | --- |
| `tool1_utils.lua` | 公共工具：资源路径、按 id 的对象管理、HP/MP 绘制、字符串/帧号解析等 |
| `tool1_LGUIBox/LGUIWindow/LGUIPart` | 角色编辑器的 GUI 框架 |
| `tool1_character*` / `tool1_display` | 角色装配、显示、2D 合成、BoxCast 等试验分支 |
| `tool2_castleDB.lua` | 读 `.cdb`（castleDB 导出的 json） |
| `tool2_tileRoom.lua` / `tool2_main.lua` | tile 房间与随机地图生成 |
| `LObject / LPlayer / LCollider / LAI / LGlobal` | tool3 的玩法骨架（对象/玩家/碰撞/AI） |
| `tool4_main.lua` | 图集生成（`package.path` 挂 `utils/pngLua-master`） |
| `json.lua` / `cs_coroutine.lua` | JSON 解析、lua 协程 → Unity 协程桥 |

## 目录

```
Assets/
├─ 1/
│  ├─ Scenes/            # tool1 ~ tool4 + test
│  ├─ Script/            # C# 胶水层（GameLoader / LuaBehaviour / WAV / …）
│  └─ ExampleGenConfig.cs
├─ StreamingAssets/
│  ├─ 0/Lua/             # xLua 官方示例
│  └─ 1/Lua/             # 本项目全部 lua 逻辑
│     └─ Resource/       # .cdb 数据、素材
├─ XLua/                 # xLua 全量（Src / Gen / Editor）
└─ WebGLPlugins/         # xLua 的 WebGL 版原生 Lua 源码
Tools/                   # xLua 代码生成 / 热修复注入工具
```

## 注意

- 用 **Unity 2019.2.0f1** 打开（其余版本未验证）；xLua 的 Wrap 是按当时的 API 生成的，换版本后要重新 Generate Code
- 源码编码混杂：部分 lua / C# 文件是 GBK，部分是 UTF-8，改文件时保持原编码
- WebGL 支持是半成品（`try to fix webgl` 那几个提交）：加载链已按「预载缓存 → CustomLoader」走通，未做完整验证

## 更新（2026-10）

修了一批实打实的 bug：

**C# 胶水层**
- `LuaBehaviour`：`onCollisionStay2D` / `onCollisionStay` 两处复制粘贴错误绑成了 `onCollisionEnter(2D)`——碰撞停留帧会重复触发进入逻辑，而 Stay 回调永远收不到；FPS 统计把 `Time.realtimeSinceStartup` 赋给了 `UpdateInterval`（间隔字段被写成了开机以来的秒数，FPS 显示恒为垃圾值）；`AddLoader` 每个 Awake 都加一次导致 require 越走越慢，改为只加一次；找不到脚本的物体现在报错并跳过，而不是把 null 塞进 `DoString` 炸栈；`OnDestroy` 补齐全部 lua 委托置空
- `GameLoader`：UnityWebRequest 失败原来静默注册空字符串，现在报错并继续（不再无声卡死后续加载）；删掉 2 万多字符注释掉的 Base64 测试代码；`Tools.PhysicsBoxCastG` 去掉调试 Log
- `CustomLoader`：非 Windows 分支原来是 `WWW` 同步忙等——主线程被堵住 `isDone` 永远不会变 true，任何非 Windows 平台第一次 require 就死循环；改为「预载字节缓存 → 桌面端读文件 → WebGL 报错」，且缓存存原始字节避免 GBK 文件被 UTF-8 解码损坏

**音频**
- `WAV`：立体声采样数被多除了一个 2（`blockAlign` 本来就含声道数），立体声文件只能播一半；8-bit PCM 转换公式上下反相，改标准 `(b-128)/128`
- `AudioTest`：立体声 `SetData` 原来只填左声道（后半段静音），改为左右交错

**Lua**
- `tool2_main.lua` 的 `require "tool2_utils"`：文件根本不存在，tool2 场景一启动就 module not found；公共工具本体是 `tool1_utils.lua`（tool1/3/4 都用它），已改
- 仓库里误提交的 `Logs/Packages-Update.log` 移出并加入 `.gitignore`
