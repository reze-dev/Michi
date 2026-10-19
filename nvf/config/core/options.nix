{ pkgs, lib, ... }: {
  config.vim = {
    # nvf sources its config through $VIMINIT while the command-line buffers
    # already exist. `:syntax on` (nvf's basic module) calls `filetype on`
    # and then `doautoall filetypedetect BufRead`, which detects those
    # buffers and fires FileType during the init, long before plugin setups
    # (e.g. vim.g.rustaceanvim) and the LSP enable autocmds are registered.
    # Skip detection around `syntax on` and turn it on at the end of the
    # init; the buffers are read afterwards, so their FileType events fire
    # at the normal time.
    luaConfigRC.filetype_deferred = lib.nvim.dag.entryBefore [ "basic" ] ''
      vim.g.did_load_filetypes = "deferred-until-init-finishes"
    '';
    luaConfigRC.filetype_enable = lib.nvim.dag.entryAfter [ "lsp-servers" ] ''
      if vim.g.did_load_filetypes == "deferred-until-init-finishes" then
        vim.g.did_load_filetypes = nil
        vim.cmd("filetype on")
      end
    '';

    # System Environment & PATH: prepend Mason bin (~/.local/share/nvim/mason/bin),
    # ~/go/bin, ~/.cargo/bin and ~/.local/bin when they exist and are not
    # already in PATH (matches the standalone config's conditional prepend).
    luaConfigRC.env = ''
      local home = vim.env.HOME or vim.fn.expand("~")
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
      local go_bin = home .. "/go/bin"
      local cargo_bin = home .. "/.cargo/bin"
      local local_bin = home .. "/.local/bin"

      local path_prepend = {}
      local function maybe_prepend(dir)
        if dir and dir ~= "" and vim.uv.fs_stat(dir) then
          if not string.find(vim.env.PATH or "", dir, 1, true) then
            path_prepend[#path_prepend + 1] = dir
          end
        end
      end

      maybe_prepend(mason_bin)
      maybe_prepend(go_bin)
      maybe_prepend(cargo_bin)
      maybe_prepend(local_bin)

      if #path_prepend > 0 then
        vim.env.PATH = table.concat(path_prepend, ":") .. ":" .. (vim.env.PATH or "")
      end
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
      winborder = "rounded";
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
      foldlevelstart = 99;

      # Migrated from lua_config.nix
      inccommand = "split";
      jumpoptions = "view";
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
