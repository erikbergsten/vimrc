function! Elem(comment, key, value)
python << endpython
import vim

comment = vim.eval("a:comment")
key = vim.eval("a:key")
value = vim.eval("a:value")

buff = vim.current.buffer
row = vim.current.range.start

start = row
while len(buff[start]) != 0 and start > 0:
  start -= 1

buff.append(f"{comment} more stufff", -(len(buff)-start))
buff.append(f"{comment} <element {key}='{value}'>", -(len(buff)-start))

end = vim.current.range.start
while len(buff[end]) != 0 and end < len(buff):
  end += 1

buff.append(f"{comment} </element>", end-len(buff)-1)

endpython
endfunction
