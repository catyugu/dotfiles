# Stow Configurations

使用 GNU Stow 管理的 dotfiles 仓库，采用**叠加包**模式。

## 目录结构

```
stow_configurations/
├── common/           ← 所有平台共享 (main 分支)
│   ├── git/          # .gitconfig
│   └── nvim/         # Neovim 配置 (.config/nvim/)
│
├── termux/           ← Termux/i3 桌面独有 (termux-arch 分支)
│   ├── xresources/   # .Xresources
│   ├── xprofile/     # .xprofile
│   ├── alacritty/    # 终端配置
│   ├── fcitx5/       # 输入法配置
│   ├── foot/         # 终端配置
│   ├── i3/           # i3 窗口管理器
│   ├── i3status/    # i3status 状态栏
│   ├── kitty/        # Kitty 终端配置
│   └── waybar/       # Waybar 状态栏
│
└── wsl/              ← WSL 独有 (wsl-arch 分支, 当前为空)
```

## 部署方法

### 首次设置

```bash
# 1. Clone 仓库
git clone git@github.com:catyugu/stow_configurations.git ~/dotfiles
cd ~/dotfiles

# 2. 切换到对应分支
# WSL:
git checkout wsl-arch
# Termux:
git checkout termux-arch

# 3. Stow 链接
stow common                       # 所有平台：git + nvim
stow termux                       # Termux 平台：桌面环境配置
```

### 撤销链接

```bash
stow -D <package>
stow -D common termux
```

### 从其他分支获取新包

```bash
git fetch origin
git checkout termux-arch -- termux/alacritty  # 从 termux-arch 获取新包到当前分支
stow alacritty
```

## 分支说明

| 分支 | 内容 | 合并方式 |
|------|------|----------|
| `main` | 平台无关的共享配置 | 永远只添加 shared 配置 |
| `termux-arch` | Termux/i3 桌面环境独有配置 | 在 `main` 基础上追加 termux 独有包 |
| `wsl-arch` | WSL 独有配置 | 在 `main` 基础上追加 wsl 独有包（当前为空）|

## 规则

1. **`main` 永远只包含跨平台共享的配置**
2. **平台分支只在 `main` 基础上追加新的 package**，不修改已在 `main` 中的文件
3. **敏感信息**（API keys, tokens）不进入仓库，使用 `.env.example` 模板
4. 每个 package 目录结构必须与 `$HOME` 路径一致，以便 Stow 正确链接