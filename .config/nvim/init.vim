set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc
luafile ~/.config/nvim/nvim.lua

" We get an error if we try to reload nvim.lua, maybe remapping is a problem?
"nnoremap <leader>sv :<C-u>source ~/.config/nvim/init.vim<CR>
