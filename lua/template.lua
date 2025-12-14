vim_path = os.getenv("VIMPATH")
function template_path(path)
  return vim_path .. "/templates/" .. path
end

function get_replacements(rest_args)
  local replacements = {}
  for key,arg in pairs(rest_args) do
    if key ~= 1 then
      replacements[key] = vim.split(arg, "=")
    end
  end
  return replacements
end

function replace_all(line, replacements)
  for i, repl in pairs(replacements) do
    line = line:gsub("$"..repl[1], repl[2])
  end
  return line
end

function template(opts)
  local path = template_path(opts.fargs[1])
  replacements = get_replacements(opts.fargs)
  for line in io.lines(path) do
    local updated_line = replace_all(line, replacements)
    vim.api.nvim_buf_set_lines(0, -1, -1, false, {updated_line})
  end
end

vim.api.nvim_create_user_command('Tpl', template, { nargs = '*' })

test1 = {"foo", "bar", "baz"}
print(unpack(test1, 2))
