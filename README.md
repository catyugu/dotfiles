# Dotfiles

用于在新机器上快速接入常用配置。采用 Git 白名单和 GNU Stow 分包管理，按机器需要选择配置。

## 新机操作

### 1. 安装必要软件

部署需要 Bash、GNU Stow 和常规 Unix 工具。Linux 可按发行版安装：

```bash
# Debian / Ubuntu
sudo apt install git stow bash zsh

# Arch Linux
sudo pacman -S git stow bash zsh
```

脚本检查部署依赖，不自动运行系统安装命令或切换默认 Shell。

| 配置包 | 应用依赖 |
| --- | --- |
| common | Git、Bash 或 Zsh；Vim 按需安装 |
| nvim | Neovim、Git；建议安装 ripgrep、fd、编译工具；当前 clangd 配置使用系统 clangd |
| desktop | 按需安装 i3、i3status、Waybar、Kitty、Foot、Alacritty、Fcitx5、rofi、Firefox、Thunar、字体及 X11 工具 |

Zsh 配置可接入已安装的 Oh My Zsh；缺失时基础环境与别名仍可使用。主题使用 `sorin`，两个自定义插件仅在已安装时加载：

```bash
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

仅首次安装时运行；已有对应目录则跳过。安装 Conda、Rust 等工具时允许其正常修改本机启动文件，同一工具只初始化一次。

### 2. 克隆并部署

```bash
git clone https://github.com/catyugu/dotfiles.git ~/dotfiles
cd ~/dotfiles

./install.sh --dry-run             # 先查看计划
./install.sh                       # 默认部署 common，并接入 Bash / Zsh
./install.sh common nvim           # 开发环境
./install.sh common nvim desktop   # 按需加入桌面配置
```

脚本显式指定部署目标为 `$HOME`，仓库可以放在其他位置。只允许 `common`、`nvim`、`desktop`，未知包或失败会返回非零退出状态。重复部署不会重复添加加载块。

部署使用 `--no-folding`，目录保持普通目录、配置文件使用链接，便于应用创建自己的本地文件。仅部署 `nvim` 或 `desktop` 不会修改 Shell 入口。

### 3. 处理已有配置

默认遇到冲突就中止，不修改目标。先查看本机配置与仓库差异，保留需要的修改，再执行：

```bash
./install.sh --dry-run --backup common nvim
./install.sh --backup common nvim
```

`--backup` 将冲突文件或目录移到 `~/.local/state/dotfiles/backups/<时间戳>.<随机后缀>/`，然后部署仓库版本；它不会合并配置。目录符号链接会备份链接本身，避免修改外部目录。

Shell 入口修改前也会备份。入口符号链接默认拒绝修改，使用 `--backup` 后才读取其内容并转换为普通文件。

备份路径由脚本输出。如果部署中途失败，已移走的文件仍在备份中，修复错误后可重试或按下文恢复。`--dry-run --backup` 在存在冲突时报告待备份路径，不执行移走文件后的完整 Stow 校验。

### 4. 填写本机设置

```bash
# 仅首次创建，已有文件时保留原内容
mkdir -p ~/.config/dotfiles
if [ ! -e ~/.config/dotfiles/local.sh ]; then
    (umask 077; touch ~/.config/dotfiles/local.sh)
fi
```

在 `local.sh` 中填写代理、额外路径等，使用兼容 POSIX sh 的语法。本机交互覆盖可写入 `local.bash`、`local.zsh`。Miniconda、FNM、Bun、Rust 等工具的路径与初始化属于本机配置，不进入仓库；安装器生成的初始化块保留在本机入口，手写初始化放入 `local.*`，同一工具只保留一个初始化位置。

共享的 `.sh` 文件（如 `profile.sh`、`rc.sh`、`local.sh`）使用 POSIX sh。专用于 Bash / Zsh 的文件（如 `bashrc.bash`、`zshrc.zsh`、`local.bash`、`local.zsh`）可使用各自更简洁的原生语法；工具生成的 hook 也按对应 Shell 加载。部署脚本 `install.sh` 使用 Bash。

凭据放在仓库外的独立文件中，权限设置为 `600`，需要时显式加载。不要把本机文件复制回仓库。Git 身份在 `common/.gitconfig` 中，首次使用前检查是否符合目标机器用途。

打开新 Shell 使用配置。公共环境配置每个 Shell 只加载一次，修改后也应打开新 Shell。

## 配置边界与目录

```text
dotfiles/
├── common/
│   ├── .gitconfig
│   ├── .vimrc
│   ├── .stow-local-ignore
│   └── .config/dotfiles/
│       ├── profile.sh       # 公共环境变量与 local.sh 接入
│       ├── rc.sh            # 公共别名
│       ├── bashrc.bash      # Bash 交互配置
│       └── zshrc.zsh        # Zsh / Oh My Zsh / 插件配置
├── nvim/                   # Neovim / LazyVim 配置
├── desktop/                # 桌面应用配置、.Xresources
├── install.sh
└── README.md
```

`.profile`、`.bashrc`、`.zshrc`、`.bash_profile`（或已有 `.bash_login`）、`.zprofile` 是本机普通文件。安装器可修改它们，脚本只维护下面标记之间的加载语句，保留其他内容：

```sh
# >>> dotfiles >>>
# 公共配置加载语句
# <<< dotfiles <<<
```

加载块放在入口末尾。本机环境初始化通常先执行，公共配置随后执行，`local.bash` / `local.zsh` 最后覆盖。安装器若在末尾追加代码，需要检查顺序；重新运行安装脚本会把加载块调整到末尾。存在重复或未闭合标记时脚本中止。

新建登录入口时会接入 `.profile`，新建 Bash 登录入口还会接入 `.bashrc`；已有入口保留原来的加载逻辑，并补入公共配置入口。`.profile` 保持 POSIX 兼容，工具的 Bash / Zsh 交互 hook 放入各自本机交互入口或 `local.bash` / `local.zsh`。FNM 的环境变量会被子 Shell 继承，不能据此跳过当前 Shell 的初始化。

桌面会话初始化由本机的桌面环境和会话管理器负责。已有本机 `.xprofile` 不受部署脚本影响。

## 白名单规则

- Git 根目录默认忽略，显式放行仓库入口、`common/`、`nvim/` 和 `desktop/`；放行的目录内默认跟踪正常文件。
- 新增包必须同时更新 `.gitignore` 和 `install.sh` 的 `ALLOWED_PACKAGES`，并在 README 记录用途及依赖。
- 包内路径必须对应 `$HOME` 下的实际路径；不同包不能拥有同一目标文件。
- Git 白名单控制提交，包根目录的 `.stow-local-ignore` 控制部署，二者分开维护。Stow 规则使用 Perl 正则表达式。
- 当前忽略说明文件、Git 元数据和临时文件。修改包内忽略规则时，同步更新脚本的 `ignored` 函数，确保备份预检与部署一致。
- 本机补充文件位于仓库外，脚本不把它们加入包；仓库内不得填写真实凭据。

## 更新、撤销与恢复

修改实际配置链接后，修改会直接进入仓库。提交前查看 `git status` 和差异；更新仓库后重新运行对应的安装命令以接入新增文件。

撤销配置链接（从仓库目录运行）：

```bash
stow --no-folding -D -t "$HOME" common nvim desktop
```

入口中的加载块在配置缺失时会跳过，撤销后可保留，也可手动删除整段标记块。恢复旧配置时先撤销对应包的链接，再从脚本输出的备份目录逐项恢复文件；启动入口恢复前删除新入口，再复制备份，避免沿现有链接写入。

参考：[GNU Stow](https://www.gnu.org/software/stow/manual/stow.html)、[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)。
