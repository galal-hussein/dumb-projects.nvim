local M = {}

---@class (exact) M.project
---@field name string
---@field path string
M.project = {}

---@class (exact) M.projects
---@field  projects M.project[]
M.projects = {}

M.projects_dir = vim.fn.stdpath("data") .. "/dumb-projects.nvim"
M.projects_path = M.projects_dir .. "/projects.json"

function M.setup()
  -- create the base dir
  vim.fn.mkdir(M.projects_dir, "p")

  -- TODO: add options to the plugin
end

---@param buffer integer
function M.set_buf_options(buffer)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buffer })
  vim.api.nvim_set_option_value("readonly", true, { buf = buffer })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buffer })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buffer })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buffer })
end

function M.find_projects()
  local projects = {}
  pcall(function()
    projects = vim.json.decode(vim.fn.readblob(M.projects_path))
  end)
  M.render_projects_ui(projects)
end

---@param win integer
---@param projects M.projects
function M.add_ui_events(win, projects)
  local buf = vim.api.nvim_win_get_buf(win)
  -- Open Project
  vim.keymap.set("n", "<CR>", function()
    if #projects == 0 then
      return
    end

    local row = unpack(vim.api.nvim_win_get_cursor(M.ui))
    vim.api.nvim_set_current_dir(projects[row].path)
    vim.api.nvim_win_close(M.ui, true)
    -- open a file picker here, as a place holder we will fff
    -- but this should be customizable
    require("fff").find_files()
  end, {
    buf = buf,
    silent = true,
  })

  -- Add Project
  vim.keymap.set("n", "<C-a>", function()
    local project_path = vim.fn.getcwd(-1, -1)
    local project_name = vim.fs.basename(project_path)

    ---@type M.project
    local project = {
      name = project_name,
      path = project_path,
    }

    -- do not add project if it already exists
    for _, existing_projects in ipairs(projects) do
      if existing_projects.name == project.name then
        vim.notify("project already exists")
        return
      end
    end

    table.insert(projects, project)

    local projects_json = vim.json.encode(projects)
    vim.fn.writefile({ projects_json }, M.projects_path)

    M.render_projects_ui(projects)
  end, {
    buf = buf,
    silent = true,
  })
  -- Delete Project
  vim.keymap.set("n", "<C-x>", function()
    if #projects == 0 then
      return
    end
    local row = unpack(vim.api.nvim_win_get_cursor(M.ui))
    table.remove(projects, row)

    local projects_json = vim.json.encode(projects)
    vim.fn.writefile({ projects_json }, M.projects_path)

    M.render_projects_ui(projects)
  end, {
    buf = buf,
    silent = true,
  })
  -- Close UI
  vim.keymap.set("n", "<C-q>", function()
    vim.api.nvim_win_close(M.ui, true)
  end, {
    buf = buf,
    silent = true,
  })
end

---@param projects M.projects
function M.render_projects_ui(projects)
  local buf_lines = {}
  local buf_line_max_length = 0
  for i, project in ipairs(projects) do
    local project_line = "  " .. project.name .. " - " .. project.path
    if #project_line > buf_line_max_length then
      buf_line_max_length = #project_line
    end
    table.insert(buf_lines, i, project_line)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  if #buf_lines == 0 then
    buf_lines = { "Add a new project by pressing <C-a>..." }
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, buf_lines)

  -- configure the window
  if buf_line_max_length == 0 then
    buf_line_max_length = 50
  end

  local width = buf_line_max_length
  local height = #projects
  if height == 0 then
    height = 1
  end

  ---@type vim.api.keyset.win_config
  local win_cfg = {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    title = "Projects",
    anchor = "NW",
    style = "minimal",
  }

  M.set_buf_options(buf)
  -- if projects window already exists set the new buffer
  local ok, _ = pcall(function()
    vim.api.nvim_win_set_buf(M.ui, buf)
  end)

  if ok then
    -- adjust the window size
    vim.api.nvim_win_set_config(M.ui, win_cfg)
  else
    M.ui = vim.api.nvim_open_win(buf, true, win_cfg)
  end
  M.add_ui_events(M.ui, projects)
end
return M
