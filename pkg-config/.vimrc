" Enable modern Vim features not compatible with Vi spec.
set nocompatible

"==============="
" Basic options "
"==============="

set tabpagemax=300
set nohlsearch
"set splitbelow
"set splitright
set clipboard=unnamedplus
set linebreak
set showtabline=1
set mouse=a
"set ttymouse=xterm2
"set nonumber
"set norelativenumber
set noshowmode
"set noshowcmd
set nowrap
"set expandtab

let $PAGER=''

" For some reason, for Go formatting I need to copy these lines into
" ~/.vim/after/ftplugin/go.vim
set tabstop=2
set shiftwidth=2

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" Automatically change the working path to the path of the current file.
" Really only want this for working in very large directory structure where you
" might have multiple 'homes'.
augroup setpath
  autocmd BufNewFile,BufEnter * silent! lcd %:p:h
augroup END
let g:netrw_keepdir=0
let g:netrw_banner=0

"autocmd FileType qf wincmd J
"augroup quickfixw
"    autocmd!
"    autocmd FileType qf set buftype=quickfixw
"    autocmd FileType qf set filetype=quickfixw
"augroup END

" Interesting to try out:
"let g:netrw_altv          = 1
"let g:netrw_fastbrowse    = 2
"let g:netrw_keepdir       = 0
"let g:netrw_liststyle     = 2
"let g:netrw_retmap        = 1
"let g:netrw_silent        = 1
"let g:netrw_special_syntax= 1

"let g:netrw_keepj=""

" Don't let netrw screw up line numbering
"let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'
let g:netrw_bufsettings = 'noma nomod nobl nowrap ro'

" Tree view in netrw
let g:netrw_liststyle=3

" Remove trailing whitespace on save
function! RemoveWhitespace()
  "if &ft =~ 'ruby\|javascript\|perl'
  if &ft =~ 'vim'
        return
  endif

  let save_pos = getpos(".")
  execute "normal! :%s/\\s\\+$//e\<cr>"
  call setpos('.', save_pos)
endfunction
augroup whitespace
  autocmd BufWritePre * call RemoveWhitespace()
augroup END

" Make it so that autoread triggers when the cursor is still and when changing
" buffers (autoread is added by vim-sensible).
augroup autoread
  au CursorHold,CursorHoldI * checktime
  au FocusGained,BufEnter * checktime
augroup END

" Automatically toggle 'set paste' when pasting.
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif
  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"
  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction
let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

"" Rename tabs to show tab number.
"" (Based on http://stackoverflow.com/questions/5927952
""       /whats-implementation-of-vims-default-tabline-function)
"if exists("+showtabline")
"  function! MyTabLine()
"    let s = ''
"    let wn = ''
"    let t = tabpagenr()
"    let i = 1
"    while i <= tabpagenr('$')
"      let buflist = tabpagebuflist(i)
"      let winnr = tabpagewinnr(i)
"      let s .= '%' . i . 'T'
"      "let s .= (i == t ? '%1*' : '%2*')
"      "let s .= ' '
"      let wn = tabpagewinnr(i,'$')
"      "let s .= '%#TabNum#'
"      let s .= (i == t ? '%#TabLineSel#' : '%#TabNum#')
"      let s .= i
"      "let s .= '%*'
"      let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
"      let bufnr = buflist[winnr - 1]
"      let file = bufname(bufnr)
"      let buftype = getbufvar(bufnr, 'buftype')
"      if buftype == 'nofile'
"        if file =~ '\/.'
"          let file = substitute(file, '.*\/\ze.', '', '')
"        endif
"      else
"        let file = fnamemodify(file, ':p:t')
"      endif
"      if file == ''
"        let file = '[No Name]'
"      endif
"      let s .= ':' . file . '%#TabLine# '
"      let i = i + 1
"    endwhile
"    let s .= '%T%#TabLineFill#%='
"    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
"    let s .= '%#TabLineSel#'
"    return s
"  endfunction
"  set stal=2
"  set tabline=%!MyTabLine()
"  set showtabline=1
"  "set showtabline=2
"  highlight link TabNum Special
"endif

" Maps
let mapleader = ";"
let maplocalleader = ";"
inoremap kj <Esc>
vnoremap KJ <Esc>
nnoremap Y y$
inoremap <leader>w <Esc>:<C-u>w<CR>
inoremap <C-S-O> <Esc>O
nnoremap <leader>w :<C-u>w<CR>
nnoremap <leader>sv :<C-u>source ~/.vimrc<CR>
nnoremap <leader>v :<C-u>vsplit<CR>
nnoremap <leader>b :<C-u>split<CR>
nnoremap <leader>t :<C-u>tabnew %<CR>
nnoremap <leader>e :<C-u>e<Space>
nnoremap -- :e .<CR>
nnoremap === <C-w>=
nnoremap __ <C-w>_
nnoremap \|\| <C-w>\|
nnoremap <PageUp> gt
nnoremap <PageDown> gT
nnoremap gr gT
"nnoremap <Tab> gt
"nnoremap <S-Tab> gT
nnoremap tc :tabclose<CR>
nnoremap <leader>lc :set cursorline!<CR>
nnoremap <leader>z vi{zf
" Are the p ones really necessary? They might just paste FROM reg 0, meanwhile
" the d one already has deleting TO reg 0 (incl in p and c) covered.
"vnoremap p "0p
"vnoremap P "0P
"nnoremap d "0d
nnoremap <leader>] :cn<CR>
nnoremap <leader>[ :cp<CR>
nnoremap <leader>sb :<C-u>sb<Space>
"nnoremap <leader>eb :<C-u>b<Space>
nnoremap <leader>B :<C-u>ls<CR>:b<Space>
nnoremap <leader>M :<C-u>marks<CR>:norm! '
nnoremap <leader>nt :Ntree<CR>ggj
nnoremap <leader>S :%s//g<Left><Left>
vnoremap <leader>S :s//g<Left><Left>
nnoremap <leader>fm :!ranger $PWD<CR>
nnoremap <leader>G :vimgrep //g **/*<Left><Left><Left><Left><Left><Left><Left>
nnoremap <leader>X :w<CR>:!sudo chmod a+x %<CR>
nnoremap cl :<C-u>pclose <bar> lclose <bar> cclose<CR>
nnoremap co :<C-u>cclose \| copen<CR>
nnoremap <leader>ct :execute "set colorcolumn=" . (&colorcolumn == "" ? "101" : "")<CR>
nnoremap <leader>nn :set number!<CR>:set relativenumber!<CR>
cnoremap kj <C-c>
cnoremap fn ^func<Space>.*
cnoremap \( \(\)<Left><Left>
cnoremap \< \<\><Left><Left>
inoremap <leader>db log.Infof("") // DEBUGGING<Esc>?"<Cr>i
inoremap <expr> ,. pumvisible() ? "-><C-E><C-X><C-U>" : "-><C-X><C-U>"
"inoremap ., <-
nnoremap vvv ^v$h

inoremap <expr> . pumvisible() ? ".<C-E><C-X><C-U>" : ".<C-X><C-U>"

" Autoclose parens, brackets, etc...
"inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap { {}<Esc>i
inoremap {<CR> {<CR>}<Esc>O
inoremap <silent> ) <c-r>=ClosePair(')')<CR>
inoremap <silent> ] <c-r>=ClosePair(']')<CR>
"inoremap } <c-r>=CloseBracket()<CR>
inoremap <silent> } <c-r>=ClosePair('}')<CR>
inoremap <silent> " <c-r>=QuoteDelim('"')<CR>
inoremap <silent> ` <c-r>=QuoteDelim('`')<CR>
"inoremap ' <c-r>=QuoteDelim("'")<CR>
"augroup htmlcarrots
"  autocmd Syntax html,vim inoremap < <lt>><Esc>i| inoremap > <c-r>=ClosePair('>')<CR>
"augroup END

" Function text object (only works in Go)
vnoremap af <Esc>:silent! normal! l<CR>?^func <CR>V$%
vmap if <Esc>:silent! normal! l<CR>?^func <CR>$vi{
omap af :normal Vaf<CR>
omap if :normal Vif<CR>

" Search only within visual selection
vnoremap <leader>/ <Esc>/\%V
vnoremap <leader>? <Esc>?\%V

" Select between x and y marks
vnoremap xy <Esc>`xv`y

function! ClosePair(char)
  if getline('.')[col('.') - 1] == a:char
  return "\<Right>"
  else
  return a:char
  endif
endf

"function CloseBracket()
" if match(getline(line('.') + 1), '\s*}') < 0
" return "\<CR>}"
" else
" return "\<Esc>j0f}a"
" endif
"endf

function! QuoteDelim(char)
  let line = getline('.')
  let col = col('.')
  if line[col - 2] == "\\"
  "Inserting a quoted quotation mark into the string
  return a:char
  elseif line[col - 1] == a:char
  "Escaping out of the string
  return "\<Right>"
  else
  "Starting a string
  return a:char.a:char."\<Esc>i"
  endif
endf

" Fix initial drawing in alacritty+tmux
autocmd VimEnter * :silent exec "!kill -s SIGWINCH $PPID"

" Change cursor depending on mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
augroup myCmds
  au!
  autocmd VimEnter * silent !echo -ne "\e[2 q"; echo ''
augroup END

" Edit and run jupyter-notebook-style scripts from Vim
source $HOME/.vim/jupyterrun.vim

" Netrw-specific maps
nmap <Leader>- <Plug>VinegarUp
nnoremap - -
"augroup netrw_mapping
"    autocmd!
"    autocmd filetype netrw call NetrwMapping()
"augroup END
"
"function! NetrwMapping()
"    "noremap <buffer> a
"endfunction

"========================================="
" Vundle configuration / External plugins "
"========================================="

filetype off
set rtp+=~/.vim/bundle/Vundle.vim
if isdirectory(expand('$HOME/.vim/bundle/Vundle.vim'))
  call vundle#begin()
  Plugin 'VundleVim/Vundle.vim' " Let Vundle manage Vundle, required.

  Plugin 'tpope/vim-sensible' " Sensible defaults

  "Plugin 'vim-scripts/netrw.vim' " Basic default file navigator
  Plugin 'tpope/vim-vinegar' " Enhancements for netrw

  "Plugin 'tpope/vim-obsession' " Persist vim sessions

  " Syntastic (syntax checking)
  "Plugin 'scrooloose/syntastic'
  "set statusline+=%#warningmsg#
  "set statusline+=%{SyntasticStatuslineFlag()}
  "set statusline+=%*
  "let g:syntastic_always_populate_loc_list = 1
  "let g:syntastic_auto_loc_list = 1
  "let g:syntastic_check_on_open = 1
  "let g:syntastic_check_on_wq = 1
  "let g:syntastic_go_checkers = ['go', 'golint', 'govet'] " go

  Plugin 'scrooloose/nerdcommenter' " Better commenting
  let g:NERDCommentEmptyLines = 1
  let g:NERDDefaultAlign = 'left'
  let g:NERDToggleCheckAllLines = 1

  " Smooth navigation between tmux panes and vim buffers with ctrl-direction
  "Plugin 'christoomey/vim-tmux-navigator'

  " Snippets
  Plugin 'SirVer/ultisnips'
  Plugin 'honza/vim-snippets'
  let g:ycm_key_invoke_completion='<cr>'
  let g:ycm_key_list_select_completion=["<tab>"]
  let g:ycm_key_list_previous_completion=["<S-tab>"]
  "let g:UltiSnipsJumpForwardTrigger="<tab>"
  "let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
  let g:UltiSnipsJumpForwardTrigger="<CR>"
  let g:UltiSnipsJumpBackwardTrigger="<S-CR>"
  let g:UltiSnipsExpandTrigger="<nop>"
  let g:ulti_expand_or_jump_res = 1
  function! <SID>ExpandSnippetOrReturn()
    let snippet = UltiSnips#ExpandSnippetOrJump()
    if g:ulti_expand_or_jump_res > 0
      return snippet
    else
      return "\<CR>"
    endif
  endfunction
  inoremap <expr> <CR> pumvisible() ? "<C-R>=<SID>ExpandSnippetOrReturn()<CR>" : "\<CR>"

  " Fzf
  set rtp+=~/.fzf
  Plugin 'junegunn/fzf.vim'
  " Customize fzf colors to match your color scheme
  "let g:fzf_colors =
  "\ { 'fg':    ['fg', 'Normal'],
  "\ 'bg':    ['bg', 'Normal'],
  "\ 'hl':    ['fg', 'Comment'],
  "\ 'fg+':   ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  "\ 'bg+':   ['bg', 'CursorLine', 'CursorColumn'],
  "\ 'hl+':   ['fg', 'Statement'],
  "\ 'info':  ['fg', 'PreProc'],
  "\ 'border':  ['fg', 'Ignore'],
  "\ 'prompt':  ['fg', 'Conditional'],
  "\ 'pointer': ['fg', 'Exception'],
  "\ 'marker':  ['fg', 'Keyword'],
  "\ 'spinner': ['fg', 'Label'],
  "\ 'header':  ['fg', 'Comment'] }

  " LaTeX editing
  Plugin 'lervag/vimtex'

  " Surround selection with things
  Plugin 'tpope/vim-surround'

  " Send text to tmux panes
  "Plugin 'esamattis/slimux' " Has bugs with unmerged pull-requests
  Plugin 'lotabout/slimux'
  let g:slimux_python_use_ipython=1
  let g:slimux_python_press_enter=1

  " Asynchronous external commands
  Plugin 'tpope/vim-dispatch'

  " Highlight instances of current word
  "Plugin 'dominikduda/vim_current_word'
  "
  " Colorschemes
  Plugin 'flazz/vim-colorschemes'

  " Airline
  Plugin 'vim-airline/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'

  " Better opening from quickfix
  Plugin 'yssl/QFEnter'

  Plugin 'vim-scripts/vcscommand.vim'

  Plugin 'vimwiki/vimwiki'

  Plugin 'mboughaba/i3config.vim'

  "Plugin 'jackguo380/vim-lsp-cxx-highlight'

  Plugin 'neovim/nvim-lspconfig'
  let g:LanguageClient_serverCommands = {
    \ 'cpp': ['clangd'],
    \ 'c': ['clangd'],
    \ 'python': ['pyright'],
    \ 'javascript': ['tsserver'],
    \ 'typescript': ['tsserver'],
    \ 'sh': ['bash-language-server', 'start'],
    \ 'bash': ['bash-language-server', 'start'],
    \ }

  Plugin 'ms-jpq/coq_nvim', {'branch': 'coq'}
  
  " 9000+ Snippets
  Plugin 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
  
  " lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
  " Need to **configure separately**
  Plugin 'ms-jpq/coq.thirdparty', {'branch': '3p'}
  " - shell repl
  " - nvim lua api
  " - scientific calculator
  " - comment banner
  " - etc
  
  let g:coq_settings = { 
        \ 'auto_start': 'shut-up',
        \ "keymap.jump_to_mark": "<c-b>",
        \ "keymap.manual_complete": "<c-space>",
        \ "limits.completion_auto_timeout": 1,
        \ "display.pum.fast_close": v:true,
        \ }

  Plugin 'ray-x/lsp_signature.nvim'

  Plugin 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  "Plugin 'octol/vim-cpp-enhanced-highlight'
  "Plugin 'bfrg/vim-cpp-modern'
  "let g:cpp_class_scope_highlight = 1
  "let g:cpp_member_variable_highlight = 1
  "let g:cpp_class_decl_highlight = 1
  "let g:cpp_attributes_highlight = 1
  "let g:cpp_simple_highlight = 1
  "let g:cpp_concepts_highlight = 1
  
  Plugin 'mfussenegger/nvim-dap'
  Plugin 'mfussenegger/nvim-dap-python'

  nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
  nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
  nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
  nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
  nnoremap <silent> <Leader>Tb <Cmd>lua require'dap'.toggle_breakpoint()<CR>
  nnoremap <silent> <Leader>Cb <Cmd>lua require'dap'.clear_breakpoints()<CR>
  nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
  nnoremap <silent> <F4> <Cmd>lua require'dap'.terminate()<CR>
  nnoremap <silent> <Leader>ds <Cmd>lua scopes_sidebar.open()<CR>

  Plugin 'spolu/dwm.vim'
  "Plugin 'davidrv00/dwm.vim-fork'
  "nnoremap <leader><space> :<C-u>call DWM_Focus()<CR>
  nnoremap <cr> :<C-u>call DWM_Focus()<CR>
  
  " Load non-portable plugins and settings
  source $HOME/.vim_vundle_noport.vim

  call vundle#end()
else
  echomsg 'Vundle is not installed. You can install Vundle from'
    \ 'https://github.com/VundleVim/Vundle.vim'
endif

source $HOME/.vim_noport.vim

" Enable file type based indentation
" This must be done AFTER loading plugins and sourcing configuration.
filetype plugin indent on
syntax on

" Notebook conceal
augroup py
  autocmd BufNewFile,BufRead *.py,*.r,*.R :set updatetime=100

  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=_
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=¶
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=»
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=
  autocmd BufNewFile,BufRead,CursorHold *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=―
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=━
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=┈
  "autocmd BufNewFile,BufRead *.py,*.r,*.R :syntax match Normal '^# In\[.*\]:.*' conceal cchar=⎯
  autocmd BufNewFile,BufRead,CursorHold *.py,*.r,*.R :set conceallevel=1
  autocmd BufNewFile,BufRead,CursorHold *.py,*.r,*.R :set concealcursor=nc " ,*.md,*.wiki
augroup END

" Auto-write latex files if cursor is held still (then vimtex compiles on save)
"augroup tex
"  autocmd BufNewFile,BufRead *.tex :VimtexCompile
"  autocmd BufNewFile,BufRead *.tex :set updatetime=500
"  autocmd CursorHold *.tex :update
"  autocmd CursorHoldI *.tex :update
"augroup END

" Auto draw graphviz files
augroup gv
  autocmd BufWritePost *.gv :silent !dot -Tpng % -o %.png
augroup END

" C-like files
augroup c
  autocmd BufNewFile,BufRead *.c,*.cpp,*.cc,*.h,*.hpp :set expandtab
augroup END

" Javascript and typescript
augroup c
  autocmd BufNewFile,BufRead *.js,*.ts :set expandtab
augroup END

" Appearance
set background=dark

"colorscheme Atelier_CaveDark
"colorscheme 1989
colorscheme OceanicNext
"colorscheme blues

"colorscheme wasabi256
colorscheme vibrantink

let g:airline_theme='base16_eighties'
"let g:airline_theme='base16_ashes'
"let g:airline_theme='badwolf'
"let g:airline_theme='biogoo'
"let g:airline_theme='fairyfloss'
"let g:airline_theme='jet'
"let g:airline_theme='base16_google'
"let g:airline_theme='peaksea'
"let g:airline_theme='behelit'

"let g:airline_section_c = airline#section#create(['%-20f'])
"let g:airline_section_gutter = airline#section#create([' ---------------------------- %='])

"let g:airline_section_z = airline#section#create_right(['%l','%c'])

"function! AirlineInit()
"  "let g:airline_section_a = airline#section#create(['filetype'])
"  "let g:airline_section_z = ""
"  "let g:airline_section_z = airline#section#create_right(['%l','%c'])
"endfunction
"autocmd VimEnter * call AirlineInit()


"let &colorcolumn=join(range(101,999),",")

"set cursorline
augroup colorenter
	autocmd WinEnter * set cursorline
	autocmd WinLeave * set nocursorline
augroup END

"set fillchars+=vert:\ " Note the space
"set fillchars+=vert:∎" Note the space
set fillchars+=vert:┃" Note the space

highlight Comment cterm=italic

"hi! Normal ctermbg=NONE
"hi! ColorColumn ctermbg=232
"hi! LineNr ctermbg=232 ctermfg=236
"hi! CursorLineNr cterm=NONE ctermbg=232 ctermfg=68
""hi! CursorLineNr cterm=NONE ctermbg=68 ctermfg=232
hi! CursorLineNr cterm=NONE ctermbg=233
"hi! CursorLine cterm=NONE ctermbg=233
hi! CursorLine cterm=NONE ctermbg=16
"hi! TabLineFill ctermfg=234 ctermbg=234
""hi! TabLineSel ctermbg=236 ctermfg=75
"hi! TabLineSel ctermbg=68 ctermfg=16
"hi! TabLine ctermbg=234 cterm=None
"hi! TabNum ctermbg=234 ctermfg=None
"hi! Pmenu ctermbg=24 ctermfg=16
"hi! PmenuSel ctermbg=16 ctermfg=39
hi! Conceal ctermfg=68 ctermbg=NONE
"hi! VertSplit ctermbg=16 ctermfg=16
"hi! VertSplit ctermbg=NONE ctermfg=232
"hi! VertSplit ctermbg=232 ctermfg=232
hi! VertSplit ctermbg=232 ctermfg=0
"hi! SignColumn ctermbg=232
"hi! EndOfBuffer ctermbg=232
""hi! StatusLine ctermfg=247 ctermbg=16
"
"" Set this dynamically based on whether the menu is up?
"" Or, just make it the same color as the status line?
"hi! StatusLine ctermfg=100 ctermbg=NONE 
"
hi! StatusLine ctermfg=234 ctermbg=234 
hi! StatusLineNC ctermfg=234 ctermbg=234
"hi! StatusLineNC ctermfg=16 ctermbg=16
"hi! StatusLineNC ctermfg=NONE ctermbg=NONE
"hi! StatusLineNC ctermbg=232 ctermfg=232
"hi! WildMenu ctermbg=236 ctermfg=39
"hi! WildMenu ctermbg=68 ctermfg=16
"hi! Folded ctermbg=233
"hi! Visual ctermbg=233 cterm=none
""hi! link QuickFixLine PmenuSel

" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
"let g:airline_left_sep = '▶'
"let g:airline_left_sep = '◤'
"let g:airline_right_sep = '◀'
"let g:airline_right_sep = '▟'
"let g:airline_symbols.linenr = '␊'
"let g:airline_symbols.linenr = '␤'
"let g:airline_symbols.linenr = '¶'
"let g:airline_symbols.branch = '⎇'
"let g:airline_symbols.paste = 'ρ'
"let g:airline_symbols.paste = 'Þ'
"let g:airline_symbols.paste = '∥'
"let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
