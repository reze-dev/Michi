{ ... }: {
  config.vim.globals = {
    mapleader = " ";
    maplocalleader = " ";
    # Netrw disabled: oil.nvim owns directory buffers.
    loaded_netrw = 1;
    loaded_netrwPlugin = 1;
    loaded_python3_provider = 0;
    loaded_ruby_provider = 0;
    loaded_perl_provider = 0;
    loaded_node_provider = 0;
  };
}
