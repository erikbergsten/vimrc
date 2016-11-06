"apply clojure syntax highlighting to .cljx files
augroup cljx_files
  autocmd!
  autocmd BufNewFile,BufRead *.cljx set syntax=clojure
augroup END
