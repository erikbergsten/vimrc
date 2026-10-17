set wrap
set nomodeline
set hlsearch
set autoindent
set number
set shiftwidth=2
set softtabstop=2
set tabstop=4
set expandtab
set colorcolumn=81,101,168,208
set ruler
set scrolloff=5
set backspace=start,eol,indent
set numberwidth=5
set backupcopy=yes
colorscheme elflord

set wildmode=longest:full,full
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list

" not needed for neovim but important for old school vim
syntax on
filetype plugin indent on

set splitright
set splitbelow

" move in wrapped line one step at a time, non-wrapped lines function normally
nnoremap j gj
nnoremap k gk

let mapleader = "-"

"fix highlihting
nnoremap <silent> <C-l> :let @/ = ""<CR><C-l>
nnoremap <silent> <C-n> :syn sync fromstart<CR>

" reload vimrc
nnoremap <leader>sv :source ~/.config/nvim/init.vim<cr>

"singe or doubleqoute a word
nnoremap <leader>" viw<esc>a"<esc>hbi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>hbi'<esc>lel

"change contents of containers
onoremap <leader>s i"
onoremap <leader>( i(
onoremap <leader>[ i[
onoremap <leader>{ i{

"when caret is to the left of a container
onoremap <leader>ns :<c-u>normal! 2f"vi"<cr>
onoremap <leader>n( :<c-u>normal! f(vi(<cr>
onoremap <leader>n{ :<c-u>normal! f{vi{<cr>
onoremap <leader>n[ :<c-u>normal! f[vi[<cr>

"when caret is to the right of a container
onoremap <leader>ps :<c-u>normal! 2F"vi"<cr>
onoremap <leader>p( :<c-u>normal! F(vi(<cr>
onoremap <leader>p{ :<c-u>normal! F{vi{<cr>
onoremap <leader>p[ :<c-u>normal! F[vi[<cr>

iabbrev somerandom <C-r>=system('openssl rand -base64 21')[:-2]<CR>

"" omegayank
" vnoremap <leader>y :w !wl-copy<cr>
vnoremap <leader>y "+y
nnoremap <leader>p "+p

