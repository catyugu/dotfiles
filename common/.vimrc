" ==========================================
" 基础设置
" ==========================================
set nocompatible              " 关闭兼容模式（启用Vim专有功能）
filetype plugin indent on     " 开启插件与文件类型智能缩进
syntax on                     " 开启语法高亮
set mouse=a                   " 启用鼠标支持（支持点击和滚动）
set encoding=utf-8            " 设置编码，防止中文乱码
set termencoding=utf-8

" ==========================================
" 外观与界面
" ==========================================
set number                    " 显示绝对行号
set relativenumber            " 显示相对行号（方便跳转指定行）
set showcmd                   " 在底部显示未完成的命令
set ruler                     " 显示光标当前位置
set wrap                      " 自动折行
set scrolloff=5               " 光标移动到顶部/底部时保持5行余量
set noshowmode                " 底部不再显示模式（状态栏有显示）

" ==========================================
" 编辑与缩进
" ==========================================
set tabstop=4                 " Tab 宽度为 4 个空格
set shiftwidth=4              " 自动缩进宽度为 4 个空格
set expandtab                 " 将 Tab 自动转换为空格
set smartindent               " 开启智能缩进
set backspace=indent,eol,start " 允许退格键删除任何字符

" ==========================================
" 搜索与高亮
" ==========================================
set hlsearch                  " 高亮显示搜索匹配项
set incsearch                 " 边输入边搜索（实时高亮）
set ignorecase                " 搜索时忽略大小写
set smartcase                 " 智能大小写（若搜索词包含大写则区分大小写）

" ==========================================
" 实用进阶功能
" ==========================================
set autoread                  " 当文件在外部被修改时自动载入
set noswapfile                " 禁用交换文件（避免烦人的警告）
set nobackup                  " 禁用备份文件
set history=1000              " 增加历史记录条数

" 恢复上次关闭时的光标位置
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   execute "normal! g`\"" |
    \ endif

