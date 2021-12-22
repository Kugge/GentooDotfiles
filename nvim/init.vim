" Default Gentoo configuration file for neovim
" Based on the default vimrc shipped by Gentoo with app-editors/vim-core

" You can override any of these settings on a global basis via the
" "/etc/vim/nvimrc.local" file, and on a per-user basis via "~/.nvimrc".
" You may need to create these.

" Neovim comes with sensible defaults, see:
" https://github.com/neovim/neovim/issues/2676
" Most of the general settings from Gentoo's vimrc have been dropped here.
" We add only some necessary fixes and a few Gentoo specific settings.

" {{{ Locale settings
" If we have a BOM, always honour that rather than trying to guess.
if &fileencodings !~? "ucs-bom"
  set fileencodings^=ucs-bom
endif

" Always check for UTF-8 when trying to determine encodings.
if &fileencodings !~? "utf-8"
  " If we have to add this, the default encoding is not Unicode.
  let g:added_fenc_utf8 = 1
  set fileencodings+=utf-8
endif
" }}}

" {{{ Fix &shell, see bug #101665.
if "" == &shell
  if executable("/bin/bash")
    set shell=/bin/bash
  elseif executable("/bin/sh")
    set shell=/bin/sh
  endif
endif
"}}}

" {{{ Our default /bin/sh is bash, not ksh, so syntax highlighting for .sh
" files should default to bash. See :help sh-syntax and bug #101819.
if has("eval")
  let is_bash=1
endif
" }}}

" {{{ Autocommands
if has("autocmd")

augroup gentoo
  au!

  " Gentoo-specific settings for ebuilds.  These are the federally-mandated
  " required tab settings.  See the following for more information:
  " http://www.gentoo.org/proj/en/devrel/handbook/handbook.xml
  " Note that the rules below are very minimal and don't cover everything.
  " Better to emerge app-vim/gentoo-syntax, which provides full syntax,
  " filetype and indent settings for all things Gentoo.
  au BufRead,BufNewFile *.e{build,class} set ts=4 sw=4 noexpandtab

  " In text files, limit the width of text to 78 characters, but be careful
  " that we don't override the user's setting.
  autocmd BufNewFile,BufRead *.txt
        \ if &tw == 0 && ! exists("g:leave_my_textwidth_alone") |
        \   setlocal textwidth=78 |
        \ endif

  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
        \ if ! exists("g:leave_my_cursor_position_alone") |
        \   if line("'\"") > 0 && line ("'\"") <= line("$") |
        \     exe "normal g'\"" |
        \   endif |
        \ endif

  " When editing a crontab file, set backupcopy to yes rather than auto. See
  " :help crontab and bug #53437.
  autocmd FileType crontab set backupcopy=yes

  " If we previously detected that the default encoding is not UTF-8
  " (g:added_fenc_utf8), assume that a file with only ASCII characters (or no
  " characters at all) isn't a Unicode file, but is in the default encoding.
  " Except of course if a byte-order mark is in effect.
  autocmd BufReadPost *
        \ if exists("g:added_fenc_utf8") && &fileencoding == "utf-8" &&
        \   ! &bomb && search('[\x80-\xFF]','nw') == 0 && &modifiable |
        \     set fileencoding= |
        \ endif

  " Strip trailing spaces on write
  autocmd BufWritePre *.e{build,class}
        \ if ! exists("g:leave_my_trailing_space_alone") |
        \   :%s/\s\+$//e |
        \ endif

augroup END

endif " has("autocmd")
" }}}

" {{{ nvimrc.local
if filereadable("/etc/vim/nvimrc.local")
  source /etc/vim/nvimrc.local
endif
" }}}

" vim: set tw=80 sw=2 sts=2 et foldmethod=marker :

"
" PLUGINS
"
call plug#begin('~/.local/share/nvim/plugged')
" Initialize plugin system
Plug 'Pocco81/AutoSave.nvim'            " Auto save
Plug 'alaviss/nim.nvim'                 " Nim colors
Plug 'neovimhaskell/haskell-vim'        " Haskell colors
Plug 'rust-lang/rust.vim'               " Rust plugin
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary' }
Plug 'glepnir/dashboard-nvim'           " Dashboard
Plug 'preservim/nerdtree'               " explorer
"Plug 'drewtempelmeyer/palenight.vim'   " theme
Plug 'JuliaEditorSupport/julia-vim'     " Julia plugin
Plug 'joom/latex-unicoder.vim'          " Latex to utf8
Plug 'jbyuki/instant.nvim'              " Collaborative editing
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dracula/vim', { 'as': 'dracula' } " theme
Plug 'tpope/vim-surround'               " parenthesis/quoting
Plug 'tomtom/tcomment_vim'              " comments
call plug#end()

" Plugin init/config
let g:instant_username = "Kugge" " Remote username
" USE F6 for nerdtree
nmap <F6> :NERDTreeToggle<CR>

" Coc CMDs :
" :CocInstall coc-python
" :CocInstall coc-clangd


"
" USER CONFIG
"
syntax enable
filetype plugin indent on

highlight Normal ctermbg=NONE " change background
highlight nonText ctermbg=NONE " change background

set laststatus=0
"set colorcolumn=80
set encoding=utf-8
set relativenumber
set number

" Enter to insert a blank line below, Shift + Enter to insert it above
map <Enter> o<ESC>
map <S-Enter> O<ESC>

" Navigate with jklm (azerty equivalnet of jkl;) instead of hjkl
"noremap m l
"noremap l k
"noremap k j
"noremap j h

" Number colors
highlight LineNr ctermfg=white " num highlight
highlight ColorColumn ctermbg=white

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

" Session save/load
nmap <Leader>ss :<C-u>SessionSave<CR>
nmap <Leader>sl :<C-u>SessionLoad<CR>

" Theme
colorscheme dracula

" Neovide config
set guifont=Cozette:h10 " font
let g:neovide_cursor_vfx_mode = "railgun" " vfx
let g:neovide_refresh_rate=144 " 144 fps monitor

" Background colors
highlight Normal guifg=#e0e0e0 guibg=#242428 gui=NONE ctermfg=254 ctermbg=235 cterm=NONE
highlight NonText guifg=#99968b guibg=#242428 gui=NONE ctermfg=246 ctermbg=235 cterm=NONE

" Copy/paste
" system clipboard
nmap <c-c> "+y
vmap <c-c> "+y
nmap <c-v> "+p
inoremap <c-v> <c-r>+
cnoremap <c-v> <c-r>+
" use <c-r> to insert original character without triggering things like auto-pairs
inoremap <c-r> <c-v>"

" HEADER
let g:dashboard_custom_header = [
    \'',
    \'   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣭⣿⣶⣿⣦⣼⣆         ',
    \'    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ',
    \'          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷⠄⠄⠄⠄⠻⠿⢿⣿⣧⣄     ',
    \'           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ',
    \'          ⢠⣿⣿⣿⠈  ⠡⠌⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ',
    \'   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘⠄ ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ',
    \'  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ',
    \' ⣠⣿⠿⠛⠄⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ',
    \' ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇⠄⠛⠻⢷⣄ ',
    \'      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ',
    \'       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ',
    \'',
    \]
