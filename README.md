# Dotfiles

使用 GNU Stow 管理的 dotfiles 仓库，采用**叠加包**模式。

## 目录结构

```
dotfiles/                        ← Stow 从这里运行
├── common/                      ← 所有平台共享
│   ├── .gitconfig               → ~/.gitconfig
│   ├── .zshrc                   → ~/.zshrc
│   ├── .zprofile                → ~/.zprofile
│   ├── .profile.example         → ~/.profile.example
│   ├── .rc.example             → ~/.rc.example
│   └── nvim/.config/nvim/      → ~/.config/nvim/
│
└── termux/                      ← Termux/i3 桌面环境
    ├── xresources/.Xresources   → ~/.Xresources
    ├── xprofile/.xprofile       → ~/.xprofile
    ├── alacritty/               → ~/.config/alacritty/
    ├── fcitx5/                  → ~/.config/fcitx5/
    ├── foot/                    → ~/.config/foot/
    ├── i3/                      → ~/.config/i3/
    ├── i3status/                → ~/.config/i3status/
    ├── kitty/                   → ~/.config/kitty/
    └── waybar/                  → ~/.config/waybar/
```

## 部署方法

### 首次设置

```bash
# Clone 仓库（建议放在 ~/dotfiles）
git clone git@github.com:catyugu/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 通用配置（所有机器）
stow common

# Termux/i3 桌面配置
stow termux
```

### 撤销链接

```bash
stow -D common termux
```

## 从旧仓库迁移（~/.cfg → ~/dotfiles）

```bash
# 1. 备份旧仓库和原配置文件
cp -r ~/.cfg ~/.cfg.bak
cp ~/.zshrc ~/.zshrc.bak
cp ~/.zprofile ~/.zprofile.bak

# 2. 删除旧 bare repo
rm -rf ~/.cfg

# 3. 在新仓库中创建指向旧配置文件的 symlink（如果已有自定义修改）
# 例如：
#   mv ~/.zshrc ~/dotfiles/common/.zshrc
#   然后重新 stow：
#   cd ~/dotfiles && stow common

# 4. 清理旧的 symlink（如果有）
find ~ -maxdepth 1 -type l -name '.gitconfig' -o -name '.zshrc' -o -name '.zprofile' | xargs rm -v

# 5. 重新 stow
cd ~/dotfiles && stow common termux
```

### .profile.example 和 .rc.example 使用说明

这两个模板文件**不被 stow 链接**，需要手动复制后按需修改：

```bash
cp common/.profile.example ~/.profile
cp common/.rc.example ~/.rc
```

编辑 `.profile` 和 `.rc`，其中的环境变量和 alias 会由 `.zshrc` 自动加载。

## Stow 叠加包原则

- 所有包都在同一个 `main` 分支
- `common/`：**跨平台共享**，任何机器都部署
- `termux/`：**Termux/i3 桌面专用**，只在目标机器部署
- 部署时按需选择性 `stow`：不想用的包就不 stow 它
- `.profile.example`、`.rc.example` 等 `.example` 模板文件仅供参考，不自动链接

## 规则

1. **目录结构必须与 $HOME 路径一致**：Stow 从 `~/dotfiles/` 运行，package 内的路径必须能直接链接到 `$HOME` 下对应位置
2. **新增 package**：直接创建新目录（如 `wsl/`），放入对应路径的结构即可
3. **敏感信息**：不提交 API keys、tokens 等，使用 `.env.example` 模板
4. **平台专有配置**：放入对应平台的 package（如 `wsl/`），只在需要的机器上 stow

## 相关链接

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Using GNU Stow to manage your dotfiles](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)