set wrap
set hlsearch
set autoindent
set number
set shiftwidth=2
set softtabstop=2
set expandtab
set colorcolumn=81
set ruler
set backspace=start,eol,indent
colorscheme elflord

set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list
syntax on
filetype plugin indent on
set splitright
set splitbelow
let mapleader = "-"

"fix highlihting
nnoremap <silent> <C-l> :let @/ = ""<CR><C-l>

"uppercase current word
inoremap <c-u> <esc>viwUea

"edit and reload vimrc
nnoremap <leader>ev :split ~/.vimrc<cr>G
nnoremap <leader>sv :source ~/.vimrc<cr>

"singe or doubleqoute a word
nnoremap <leader>" viw<esc>a"<esc>hbi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>hbi'<esc>lel

"change contents of containers
onoremap <leader>s i"
onoremap <leader>( i(
onoremap <leader>[ i[
onoremap <leader>{ i{
"when caret is to the left of a container
onoremap <leader>ns :<c-u>normal! f"vi"<cr>
onoremap <leader>n( :<c-u>normal! f(vi(<cr>
onoremap <leader>n{ :<c-u>normal! f{vi{<cr>
onoremap <leader>n[ :<c-u>normal! f[vi[<cr>

source ~/.vim/clojure.vim
source ~/.vim/c.vim
source ~/.vim/agda.vim
source ~/.vim/abbreviations.vim
