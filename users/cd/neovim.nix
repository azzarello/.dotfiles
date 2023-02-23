# NeoVim for daily work and daily notes
{ config, pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      vimAlias = true;

      # Install Vim Plugins, keep configuration local to install block if possible
      plugins =
        with pkgs.vimPlugins; [

          # -------------------------- colorschemes ---------------------------
          {
            plugin = lush-nvim;
	    type = "lua";
            config = ''
              local lush = require('lush')
            '';
          }

          {
            plugin = zenbones-nvim;
	    type = "viml";
            config = ''
              set termguicolors
              set background=dark
              colorscheme zenbones
            '';
          }


          # --------------------------Lua Plugins (prefered) ------------------

          #twilight-nvim;
          { plugin = zen-mode-nvim; config = "nnoremap <leader>z :ZenMode<CR>"; }

          # Install tree-sitter with all the plugins/grammars
          #   https://tree-sitter.github.io/tree-sitter
          {
            plugin = (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars));
            type = "viml";
            config = ''
              set foldlevelstart=7
              lua << EOF
              require'nvim-treesitter.configs'.setup {
                highlight = {
                  enable = true,
                  additional_vim_regex_highlighting = false
                },
                indent = {
                  enable = true
                },
                incremental_selection = {
                  enable = true,
                  keymaps = {
                    init_selection = "gnn",
                    node_incremental = "grn",
                    scope_incremental = "grc",
                    node_decremental = "grm",
                  },
                },
              }
              EOF

              set foldlevelstart=6
              set foldmethod=expr
              set foldexpr=nvim_treesitter#foldexpr()
            '';
          }

          {
            plugin = mini-nvim;
            type = "lua";
            config = ''

              require('mini.trailspace').setup({})
              require('mini.surround').setup({})
              MiniTrailspace.highlight()
            '';
          }

          # https://github.com/iamcco/markdown-preview.nvim/
          #   "markdown preview plugin for (neo)vim"
          markdown-preview-nvim

          # https://github.com/gpanders/editorconfig.nvim
          #  "EditorConfig plugin for Neovim"
          editorconfig-nvim

          # https://github.com/sudormrfbin/cheatsheet.nvim
          #  "A cheatsheet plugin for neovim with bundled cheatsheets for the
          #   editor, multiple vim plugins, nerd-fonts, regex, etc. with a
          #   Telescope fuzzy finder interface!"
          cheatsheet-nvim # Provides <Leader>? help

          # https://github.com/akinsho/bufferline.nvim
          #  "A snazzy bufferline for Neovim"
          {
            plugin = bufferline-nvim;
            type = "viml";
            config = ''
              lua require("bufferline").setup{}
              nnoremap <silent> <C-h> :BufferLineCyclePrev<CR>
              nnoremap <silent> <C-l> :BufferLineCycleNext<CR>
            '';
          }

          # https://github.com/kyazdani42/nvim-web-devicons
          #   "lua `fork` of vim-web-devicons for neovim"
          nvim-web-devicons # used by bufferline-nvim

          # https://github.com/numToStr/Comment.nvim
          #   "Smart and Powerful commenting plugin for neovim"
          {
            plugin = comment-nvim;
            type = "lua";
            config = "require('Comment').setup({})
            ";
          }

          # https://github.com/nvim-telescope/telescope.nvim
          #   "highly extendable fuzzy finder over lists"
          {
            plugin = telescope-nvim;
            type = "viml";
            config = ''
              nnoremap  ,fg  :execute 'Telescope git_files cwd=' . expand('%:p:h')<cr>
              nnoremap  ,ff  <cmd>lua require('telescope.builtin').find_files()<cr>
              nnoremap  ,f/  <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>
              nnoremap  ,fb  <cmd>lua require('telescope.builtin').buffers()<cr>
              nnoremap  ,fo  <cmd>lua require('telescope.builtin').file_browser()<cr>
              nnoremap  ,fh  <cmd>lua require('telescope.builtin').oldfiles()<cr>
              nnoremap  ,fc  <cmd>lua require('telescope.builtin').colorscheme()<cr>
              nnoremap  ,fr  <cmd>lua require('telescope.builtin').registers()<cr>

              lua << EOF
                _G.open_telescope = function()
                  local first_arg = vim.v.argv[2]
                  if first_arg and vim.fn.isdirectory(first_arg) == 1 then
                    vim.g.loaded_netrw = true
                    require("telescope.builtin").find_files({search_dirs = {first_arg}})
                  end
                end

                vim.api.nvim_exec([[
                  augroup TelescopeOnEnter
                    autocmd!
                    autocmd VimEnter * lua open_telescope()
                  augroup END
                ]], false)
              EOF
            '';
          }

          # https://github.com/akinsho/toggleterm.nvim
          #   "A neovim plugin to persist and toggle multiple terminals during an editing session"
          {
            plugin = toggleterm-nvim;
            type = "viml";
            config = ''
              lua << EOF
              require("toggleterm").setup{
                direction = 'float',
                winblend = 3,
                float_opts = {border = 'curved'}
              }
              EOF
              nnoremap <silent> <c-t>     <cmd>execute 'ToggleTerm direction=float      dir=' . expand('%:p:h')<cr>
              nnoremap <silent> <c-s>     <cmd>execute 'ToggleTerm direction=horizontal dir=' . expand('%:p:h')<cr>
              inoremap <silent> <c-t>     <esc><cmd>execute 'ToggleTerm dir=' . expand('%:p:h')<cr>
              tnoremap <silent> <c-t>     <esc><cmd>ToggleTerm<cr>
              tnoremap <silent> <c-s>     <esc><cmd>ToggleTerm<cr>
            '';
          }

          # https://github.com/mhartington/formatter.nvim
          #   "A format runner for neovim, written in lua"
          {
            plugin = neoformat;
            type = "lua";
            config = "vim.api.nvim_set_keymap('n', ',a', ':Neoformat<cr>',{noremap = true})";
          }

          # https://github.com/f-person/git-blame.nvim
          #   "A git blame plugin for Neovim written in Lua"
          {
            plugin = git-blame-nvim;
            type = "lua";
            config = ''
              vim.g["gitblame_enabled"] = 0
              vim.api.nvim_set_keymap('n', ',,b', ':GitBlameToggle<cr>',{noremap = true})
            '';
          }

          # https://github.com/lewis6991/gitsigns.nvim
          #   "Super fast git decorations implemented purely in lua/teal"
          {
            plugin = gitsigns-nvim;
            type = "viml";
            config = ''
              lua require('gitsigns').setup()
              set signcolumn=yes " always show gutter
            '';
          }

          # https://github.com/hoob3rt/lualine.nvim
          #   "A blazing fast and easy to configure neovim statusline written in pure lua"
          {
            plugin = lualine-nvim;
            type = "lua";
            config = ''
              require('lualine').setup {
                options = {
                  section_separators = " ",
                  component_separators = " "
                }
              }
            '';
          }

          # https://github.com/hrsh7th/nvim-cmp
          #   "A completion plugin for neovim coded in Lua"
          cmp-buffer
          cmp-emoji
          cmp-path
          cmp-spell
          cmp-treesitter
          nvim-lspconfig
          # mason-lspconfig-nvim
          cmp-nvim-lsp
          # cmp-buffer
          # cmp-path
          # cmp-nvim-lua
          # luasnip
          {
            plugin = nvim-cmp;
            type = "viml";
            config = ''
              set completeopt=menu,menuone,noselect

              lua << EOF
                local cmp = require'cmp'

                local has_words_before = function()
                  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
                  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                  return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
                end
                cmp.setup({

                 sources = cmp.config.sources({
                   { name = 'buffer'      },
                   { name = 'emoji',      option = { insert = true }},
                   { name = 'path'        },
                -- { name = 'spell',      keyword_length = 4},
                   { name = 'treesitter'  },
                  }),

                  window = {
                    completion    = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                  },

                  formatting = {
                    format = function(entry, vim_item)
                      vim_item.menu = ({
                        buffer      = "[buffer]",
                        path        = "[path]",
                        spell       = "[spell]",
                        treesitter  = "[treesitter]",
                      })[entry.source.name]
                      return vim_item
                    end
                  },

                  mapping = {
                    ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                  },
                })
              EOF
            '';
          }

          # https://github.com/folke/which-key.nvim
          #   "displays a popup with possible keybindings of the command you started typing"
          {
            plugin = which-key-nvim;
            type = "lua";
            config = "require('which-key').setup()";
          }

          # https://github.com/tjdevries/train.nvim
          #   "Train yourself with vim motions and make your own train tracks :)"
          {
            plugin = train-nvim;
            type = "viml";
            config = ''
              nnoremap  ,tu  :TrainUpDown<cr>
              nnoremap  ,tw  :TrainWord<cr>
              nnoremap  ,to  :TrainTextObj<cr>
            '';
          }

          # https://github.com/nacro90/numb.nvim/
          #   "Peek lines just when you intend"
          {
            plugin = numb-nvim;
            type = "lua";
            config = "require('numb').setup()";
          }
          {
            plugin = copilot-lua;
            config = ''
              lua << EOF
                require('copilot').setup({
                  panel = {
                    enabled = true,
                    auto_refresh = false,
                    keymap = {
                      jump_prev = "[[",
                      jump_next = "]]",
                      accept = "<CR>",
                      refresh = "gr",
                      open = "<M-CR>"
                    },
                    layout = {
                      position = "bottom", -- | top | left | right
                      ratio = 0.4
                    },
                  },
                  suggestion = {
                    enabled = true,
                    auto_trigger = false,
                    debounce = 75,
                    keymap = {
                      accept = "<M-l>",
                      accept_word = false,
                      accept_line = false,
                      next = "<M-]>",
                      prev = "<M-[>",
                      dismiss = "<C-]>",
                    },
                  },
                  filetypes = {
                    yaml = false,
                    markdown = false,
                    help = false,
                    gitcommit = false,
                    gitrebase = false,
                    hgcommit = false,
                    svn = false,
                    cvs = false,
                    ["."] = false,
                  },
                  copilot_node_command = 'node', -- Node.js version must be > 16.x
                  server_opts_overrides = {},
                })
              EOF
            '';
          }
          {
            plugin = copilot-cmp;
            config = ''
              lua << EOF
                require("copilot_cmp").setup({
                  method = "getCompletionsCycling",
                  formatters = {
                    label = require("copilot_cmp.format").format_label_text,
                    insert_text = require("copilot_cmp.format").format_insert_text,
                    preview = require("copilot_cmp.format").deindent,
                  },
                })
              EOF
            '';
          }
          {
            plugin = nvim-tree-lua;
            config = ''
              lua << EOF
                -- nvimtree config
                -- examples for your init.lua

                -- disable netrw at the very start of your init.lua (strongly advised)
                vim.g.loaded_netrw = 1
                vim.g.loaded_netrwPlugin = 1

                -- set termguicolors to enable highlight groups
                vim.opt.termguicolors = true

                -- empty setup using defaults
                require("nvim-tree").setup()

                -- OR setup with some options
                require("nvim-tree").setup({
                  sort_by = "case_sensitive",
                  view = {
                    adaptive_size = true,
                    mappings = {
                      list = {
                        { key = "u", action = "dir_up" },
                      },
                    },
                  },
                  renderer = {
                    group_empty = true,
                  },
                  filters = {
                    dotfiles = true,
                  },
                })
              EOF
            '';
          }
          # ------------------------------------ Vimscript Plugins ---------------------------------------------
          # https://github.com/github/copilot.vim/
          #   "You know what it is"
          {
            plugin = copilot-vim;
          }
          # https://github.com/lambdalisue/vim-manpager
          #  "Use Vim as a MANPAGER program"
          # see shell.nix
          #vim-manpager

          # https://github.com/farmergreg/vim-lastplace
          #   "Intelligently reopen files at your last edit position in Vim"
          vim-lastplace
          undotree

          # https://github.com/dhruvasagar/vim-table-mode
          #   "VIM Table Mode for instant [ASCII] table creation"
          {
            plugin = vim-table-mode;
            type = "viml";
            config = ''
              " Make tables github markdown compatable
              let g:table_mode_corner='|'
              nnoremap  <silent>  ,,a   :TableModeToggle<cr>
            '';
          }
        ];

      extraConfig = ''
        set shortmess=I  " dont show intro message on empty buffer

        set nu

        let theme =  system('dconf read /org/gnome/desktop/interface/color-scheme')
        if theme =~ ".*default.*"
          colorscheme dayfox
        end
        set clipboard=unnamedplus

        imap jj <Esc>

        " Remove newbie crutches in Insert Mode
        inoremap <Down> <Nop>
        inoremap <Left> <Nop>
        inoremap <Right> <Nop>
        inoremap <Up> <Nop>

        " Remove newbie crutches in Normal Mode
        nnoremap <Down> <Nop>
        nnoremap <Left> <Nop>
        nnoremap <Right> <Nop>
        nnoremap <Up> <Nop>

        " Remove newbie crutches in Visual Mode
        vnoremap <Down> <Nop>
        vnoremap <Left> <Nop>
        vnoremap <Right> <Nop>
        vnoremap <Up> <Nop>

        set autoread
        let mapleader=" "
        nnoremap <silent>   <leader><leader>n   Go<cr><esc>:r! date +\%Y-\%m-\%d<cr>I# <esc>o*<space>
        nnoremap            <leader><leader>c   :%y+<cr>
        nnoremap            <leader>d           :% !base64 -d<cr>

        " avoid using :
        nnoremap  <silent>  <leader>qq  :q!<cr>
        nnoremap  <silent>  <leader>ww  :w<cr>
        nnoremap  <silent>  <leader>wq  :wq<cr>

        " keep terminal in background
        "set hidden

        " enable mouse
        set mouse=a
        set updatetime=75

        " Indentation settings for using 2 spaces instead of tabs.
        set shiftwidth=2
        set softtabstop=2
        set expandtab

        " Use case-insensitive search
        set ignorecase

        " helpfull popup for shortcuts
        set timeoutlen=500

        " cant spell
        " set spell
        " set spelllang=en

        " nvim-tree
        nnoremap <silent>   <leader>e           :NvimTreeFocus<cr>
        nnoremap            <leader><leader>e   :NvimTreeToggle<cr>
        nnoremap            <leader><leader>c   :NvimTreeCollapse<cr>
      '';
    };
  };
}

