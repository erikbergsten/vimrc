function! LoadTemplate(...)
python << endpython
import vim
import requests

args = vim.eval("a:1").split(",")
template = args[0].strip('"')
replacements = args[1:]

def replace(text, replacement):
  name, value = replacement.strip('"').split("=")
  return text.replace(f"${name}", value)

def run():
  try:
    url = f"https://raw.githubusercontent.com/erikbergsten/tpl/refs/heads/main/{template}"
    r = requests.get(url)
    if r.ok:
      text = r.text
      for replacement in replacements:
        text = replace(text, replacement)

      lines = text.splitlines()
      del vim.current.buffer[:]
      vim.current.buffer.append(lines, 0)
    else:
      print("I DONT GET IT:", r.status_code)
  except Exception as e:
    print("BAD:", e)

run()
endpython
endfunction

command! -nargs=* Tpl :call LoadTemplate( '<f-args>' )
