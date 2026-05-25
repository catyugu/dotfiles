# Dotfiles

使用 GNU Stow 管理的 dotfiles 仓库，采用**叠加包**模式。

## 目录结构

```
dotfiles/                        ← Stow 从这里运行
├── common/                      ← 所有平台共享
│   ├── .gitconfig               → ~/.gitconfig
│   └── nvim/.config/nvim/       → ~/.config/nvim/
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

## Stow 叠加包原则

- 所有包都在同一个 `main` 分支
- `common/`：**跨平台共享**，任何机器都部署
- `termux/`：**Termux/i3 桌面专用**，只在目标机器部署
- 部署时按需选择性 `stow`：不想用的包就不 stow 它

## 规则

1. **不在仓库中的配置**：`.bashrc`、`.bash_profile`、`.zshrc` 等 shell 配置由各平台自己维护，不进仓库
2. **目录结构必须与 $HOME 路径一致**：Stow 从 `~/dotfiles/` 运行，package 内的路径必须能直接链接到 `$HOME` 下对应位置
3. **新增 package**：直接创建新目录（如 `wsl/`），放入对应路径的结构即可
4. **敏感信息**：不提交 API keys、tokens 等，使用 `.env.example` 模板

## 相关链接

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Using GNU Stow to manage your dotfiles](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)