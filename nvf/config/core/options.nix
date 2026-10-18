{ pkgs, ... }: {
  config.vim = {
    # System Environment & PATH fallback
    luaConfigRC.env = ''
      local home = vim.env.HOME or vim.fn.expand("~")
      local go_bin = home .. "/go/bin"
      local cargo_bin = home .. "/.cargo/bin"
      vim.env.PATH = go_bin .. ":" .. cargo_bin .. ":" .. (vim.env.PATH or "")
    '';

    options = {
      number = true;
      relativenumber = true;
      signcolumn = "yes";
      cursorline = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;

      autoindent = true;
      breakindent = true;
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;
      termguicolors = true;
      background = "dark";
      showmode = false;
      pumheight = 10;
      pumblend = 10;
      winblend = 0;
      conceallevel = 0;
      cmdheight = 1;
      laststatus = 3;
      list = true;
      mouse = "a";
      clipboard = "unnamedplus";
      wrap = false;
      linebreak = true;
      scrolloff = 8;
      sidescrolloff = 8;
      splitright = true;
      splitbelow = true;
      swapfile = false;
      backup = false;
      undofile = true;
      updatetime = 200;
      timeoutlen = 300;
      confirm = true;
      shell = "bash";
      foldmethod = "expr";
      foldexpr = "v:lua.vim.treesitter.foldexpr()";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;

      # Migrated from lua_config.nix
      inccommand = "split";
      jumpoptions = "view";
      virtualedit = "block";
      smoothscroll = true;
      completeopt = [
        "menu"
        "menuone"
        "noselect"
      ];

      # Adopted from the standalone nvim config.
      #
      # smartindent off: treesitter and filetype indent already own
      # indentation, and smartindent fights them — it reindents on operators
      # that treesitter has already handled.
      smartindent = false;
      # Round indent to the shiftwidth multiple.
      shiftround = true;
      # ripgrep drives every grep-style plugin here.
      grepprg = "rg --vimgrep";
      grepformat = "%f:%l:%c:%m";

      # NOT ported: winborder = "rounded". dressing-nvim already draws float
      # borders, so setting both double-draws every float.
    };

    # diffopt/sessionoptions need :append semantics to keep Vim's defaults,
    # and config.vim.options assigns wholesale — hardcoding the defaults here
    # would rot on the next Neovim bump. Two appends earn their Lua.
    luaConfigRC.core_opt_appends = ''
      vim.opt.diffopt:append("linematch:60")
      vim.opt.sessionoptions:append("globals")
    '';

    luaConfigRC.core_opt_extras = ''
      vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
      vim.opt.fillchars = { eob = " ", fold = " ", foldopen = "v", foldsep = " ", foldclose = ">" }
      vim.opt.shortmess:append("sI")

      local undo_dir = vim.fn.stdpath("data") .. "/undo"
      vim.opt.undodir = undo_dir
      pcall(vim.fn.mkdir, undo_dir, "p")
    '';
  };
}
