function! Guard(name)
python << endpython
import vim

name = vim.eval("a:name")


vim.current.buffer.append("#define __" + name + "_h__", 0)
vim.current.buffer.append("#ifndef __" + name + "_h__", 0)

vim.current.buffer.append("#endif /* __" + name + "_h__ */")

endpython
endfunction


augroup c_files
  autocmd!
  autocmd BufNewFile,BufRead *.c,*.h command! -nargs=* Guard call Guard( '<args>' )
augroup END
