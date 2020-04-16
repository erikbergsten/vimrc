set wrap
set hlsearch
set autoindent
set number
set shiftwidth=2
set softtabstop=2
set expandtab
set colorcolumn=81
set ruler
set scrolloff=5
set backspace=start,eol,indent
colorscheme elflord

set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list
syntax on
filetype plugin indent on
set splitright
set splitbelow

" tab shorthand
cnoremap tb tabnew
nnoremap <C-t>l :tabn<cr>
nnoremap <C-t>h :tabp<cr>
nnoremap <C-t>n :tabnew<cr>

let mapleader = "-"

"fix highlihting
nnoremap <silent> <C-l> :let @/ = ""<CR><C-l>
nnoremap <silent> <C-n> :syn sync fromstart<CR>

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

"for xclip clipboard usage when vim * and + registers arent available
vnoremap <leader>y :w !xclip -sel c -i<cr><cr>
nnoremap <leader>p :r !xclip -sel c -o<cr>

source ~/.vim/clojure.vim
source ~/.vim/c.vim
source ~/.vim/agda.vim
source ~/.vim/abbreviations.vim
