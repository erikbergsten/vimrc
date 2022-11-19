set wrap
set hlsearch
set autoindent
set number
set shiftwidth=2
set softtabstop=2
set tabstop=4
set expandtab
set colorcolumn=81
set ruler
set scrolloff=5
set backspace=start,eol,indent
set numberwidth=5

set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
set list
syntax on
filetype plugin indent on
set splitright
set splitbelow

" move in wrapped line one step at a time, non-wrapped lines function normally
nnoremap j gj
nnoremap k gk

" move past wrapped lines (like normal vim settings) using leader-j or k
nnoremap <leader>j j
nnoremap <leader>k k

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

"indent at last whitespace before column 81
nnoremap <c-n> 81\|Bhs<enter><esc>
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

vnoremap @ :normal @

iabbrev somerandom <C-r>=system('openssl rand -base64 21')[:-2]<CR>

source ~/.vim/clojure.vim
source ~/.vim/c.vim
source ~/.vim/agda.vim
source ~/.vim/abbreviations.vim

autocmd Filetype java setlocal ts=2 sw=2 sts=2 expandtab
autocmd Filetype erlang setlocal ts=4 sw=4 sts=4 expandtab
autocmd BufNewFile,BufRead *.tex,*.txt set wrap linebreak

augroup typescriptx_files
  autocmd!
  autocmd BufNewFile,BufRead *.tsx set syntax=typescript
augroup END

augroup json_files
  autocmd!
  autocmd BufNewFile,BufRead *.json set syntax=yaml
augroup END
augroup gotmpl
  autocmd!
  autocmd BufNewFile,BufRead *.gotmpl set syntax=yaml
augroup END

let g:ftplugin_sql_omni_key = '<C-j>'

tnoremap <C-T> <C-\><C-N>
