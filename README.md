# dumb-projects.nvim

A simple project switcher for Neovim. 

It keeps a list of project directories in a small JSON file and shows them in a floating window so you can jump between them and open a file picker, its really dumb!

## Features

- Add the current working directory as a project
- List saved projects in a centered floating window
- Open a project (changes the cwd and launches a file picker)
- Remove a project
- Projects are persisted to `stdpath("data")/dumb-projects.nvim/projects.json`

## Requirements

- [fff.nvim](https://github.com/dmtrKovalenko/fff.nvim) used as the file picker when a project is opened

## Installation

Using `vim.pack` (requires Neovim 0.12+):

```lua
vim.pack.add({
  { src = "https://github.com/dmtrKovalenko/fff.nvim" },
  { src = "https://github.com/galal-hussein/dumb-projects.nvim" },
})
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "galal-hussein/dumb-projects.nvim",
  dependencies = { "dmtrKovalenko/fff.nvim" },
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use({
  "galal-hussein/dumb-projects.nvim",
  requires = { "dmtrKovalenko/fff.nvim" },
})
```

`setup()` is called automatically on load, it creates the data directory and the `projects.json` file.

## Usage

Open the projects window:

```lua
require("dumb-projects").find_projects()
```

You'll probably want to bind it to a key:

```lua
vim.keymap.set("n", "<leader>p", function()
  require("dumb-projects").find_projects()
end, { desc = "Projects" })
```

### Keymaps (inside the projects window)

| Key     | Action                                                      |
| ------- | ----------------------------------------------------------- |
| `<CR>`  | Open the project under the cursor (cd + open file picker)   |
| `<C-a>` | Add the current working directory as a project              |
| `<C-x>` | Remove the project under the cursor                         |
| `<C-q>` | Close the projects window                                   |

A project's name is the basename of the directory you add. Adding a directory whose name already exists is a no-op.

## TODO

- [ ] Support different file pickers, including [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) and [fzf-lua](https://github.com/ibhagwan/fzf-lua)
- [ ] Add options to customize the UI and colors
- [ ] Add options to customize the key bindings
- [ ] Add rename project
