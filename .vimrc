" =========================================================================
" basic settings
" =========================================================================
" set the length of a tab to be 4
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set smarttab

" expand tab to space
set expandtab

" highlight the current line and column of the cursor
set cursorline
set cursorcolumn

" highlight the matching terms when searching
set hlsearch

" jump to corresponding matches when typing the search characters
set incsearch

" set relative line number
set number
set relativenumber

" set cmd height
" set cmdheight=2

" enable mouse usage in all modes
set mouse=a

" set leader key
let g:mapleader = "\<Space>"

" executed when opening terminal
" (for example, using :term)
" do two things:
" activate conda environment
" jump to the folder of the last window
function! ExecuteOnOpeningTerminal()
  let conda_env = GetCurrentCondaEnvName()
  if conda_env != ""
    call term_sendkeys("", 'conda activate ' . conda_env . "\<CR>")
  else
    call term_sendkeys("", 'conda activate base' . "\<CR>")
  endif

  if exists("g:last_window_folder_path")
    call term_sendkeys("", 'cd ' . g:last_window_folder_path . "\<CR>")
  endif
endfunction

function! GetCurrentCondaEnvName()
  let output = system('conda info --env')
  let lines = split(output, '\n')
  let current_env = ''
  for line in lines
    if stridx(line, "*") >= 0
      let current_env = split(line, ' ')[0]
      break
    endif
  endfor
  return current_env
endfunction

function! GetCurrentFolderPath()
  return expand("%:p:h")
endfunction

function! UpdateFolderInfo()
  if exists("g:current_window_folder_path")
    let g:last_window_folder_path = g:current_window_folder_path
    let g:current_window_folder_path = GetCurrentFolderPath()
  else
    let g:current_window_folder_path = GetCurrentFolderPath()
  endif
endfunction

autocmd VimEnter * call UpdateFolderInfo()
autocmd WinEnter * call UpdateFolderInfo()
autocmd TerminalOpen * call ExecuteOnOpeningTerminal()

" Install pynvim package if not found in current environemnt
" won't install for the 'base' env nor when no virtual env is activated
function! PackageInstallForDefx()
  let current_env_name = GetCurrentCondaEnvName()
  if current_env_name == 'base'
    echo "Base environment is currently activated, pynvim will not be installed."
  elseif current_env_name == ''
    echo "No virtual environment is current current activated, pynvim will not be installed."
  else
    let has_pynvim = (system('pip list | grep pynvim') != '')
    if !has_pynvim
      call system('pip install pynvim')
    endif
  endif
endfunction

autocmd VimEnter * call job_start('PackageInstallForDefx')
" =========================================================================


" =========================================================================
" vim-plug configurations
" =========================================================================
 " Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif
" =========================================================================


" =========================================================================
" plugins
" =========================================================================
call plug#begin()
" color scheme
Plug 'sainnhe/everforest'

" better syntax highlight support, suggested by everforest
Plug 'sheerun/vim-polyglot'

" statusline
Plug 'itchyny/lightline.vim'

" auto completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" add `"suggest.noselect": true` to CocConfig
" to enable conda environment, one need to do the following work:
" 1. create a file:
" #!/bin/bash
" python \"$@\" (the '\' should be deleted)
" 2. make it executable: chmod +x file_path
" 3. edit coc-settings.json: \"python.pythonPath\": \"file_path\"
" 4. conda activate before starting vim

" keybindings
Plug 'liuchengxu/vim-which-key'

" smooth scroll
Plug 'psliwka/vim-smoothie'

" show register content
Plug 'junegunn/vim-peekaboo'

" file tree
" use :Defx to open
if has('nvim')
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/defx.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'kristijanhusak/defx-icons'

" colorful indents
Plug 'nathanaelkane/vim-indent-guides'

" generate tags automatically
Plug 'ludovicchabant/vim-gutentags'

" markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }

call plug#end()
" =========================================================================



" =========================================================================
" plugin setup
" =========================================================================

" everforest set up
if has('termguicolors')
set termguicolors
endif
" set dark or light version
set background=dark
" Set contrast.
" Available values: 'hard', 'medium'(default), 'soft'
let g:everforest_background = 'soft'
" For better performance
let g:everforest_better_performance = 1
" enable colorscheme
colorscheme everforest

" lightline setup
set noshowmode " already shown in lightline
" colorscheme
let g:lightline = {'colorscheme' : 'everforest'}
" fix bug
set laststatus=2

" vim-indent-guides setup
let g:indent_guides_enable_on_vim_startup = 1

" vim-gutentags setup
let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']
let g:gutentags_ctags_tagfile = '.tags'
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" markdown-preview.nvim setup
let g:mkdp_auto_start = 1

" coc.nvim setup
nmap <silent> gd <Plug>(coc-definition)
" the following extensions will be automatically installed
let g:coc_global_extensions = [
      \ 'coc-pairs', 
      \ 'coc-pyright',
      \ ]

" defx.nvim setup
call defx#custom#option('_', {
      \ 'winwidth': 30,
      \ 'split': 'vertical',
      \ 'direction': 'topleft',
      \ 'toggle': 1,
      \ 'resume': 1,
      \ })
" key mappings
autocmd FileType defx call s:defx_my_settings()
function! s:defx_my_settings() abort
  " Define mappings
  nnoremap <silent><buffer><expr> <CR>
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> c
  \ defx#do_action('copy')
  nnoremap <silent><buffer><expr> m
  \ defx#do_action('move')
  nnoremap <silent><buffer><expr> p
  \ defx#do_action('paste')
  nnoremap <silent><buffer><expr> l
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> E
  \ defx#do_action('open', 'vsplit')
  nnoremap <silent><buffer><expr> P
  \ defx#do_action('preview')
  nnoremap <silent><buffer><expr> o
  \ defx#do_action('open_tree', 'toggle')
  nnoremap <silent><buffer><expr> K
  \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N
  \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> M
  \ defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> C
  \ defx#do_action('toggle_columns',
  \                'mark:indent:icon:filename:type:size:time')
  nnoremap <silent><buffer><expr> S
  \ defx#do_action('toggle_sort', 'time')
  nnoremap <silent><buffer><expr> d
  \ defx#do_action('remove')
  nnoremap <silent><buffer><expr> r
  \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> !
  \ defx#do_action('execute_command')
  nnoremap <silent><buffer><expr> x
  \ defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> yy
  \ defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> .
  \ defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> ;
  \ defx#do_action('repeat')
  nnoremap <silent><buffer><expr> h
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> ~
  \ defx#do_action('cd')
  nnoremap <silent><buffer><expr> q
  \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> <Space>
  \ defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> *
  \ defx#do_action('toggle_select_all')
  nnoremap <silent><buffer><expr> j
  \ line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k
  \ line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> <C-l>
  \ defx#do_action('redraw')
  nnoremap <silent><buffer><expr> <C-g>
  \ defx#do_action('print')
  nnoremap <silent><buffer><expr> cd
  \ defx#do_action('change_vim_cwd')
endfunction
" update defx automatically when changing file
autocmd BufWritePost * call defx#redraw()
" open file by double click
nnoremap <silent><buffer><expr> <2-LeftMouse> defx#do_action('open')

" vim-which-key setup
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
call which_key#register('<Space>', "g:which_key_map", 'n')
call which_key#register('<Space>', "g:which_key_map_visual", 'v')
set timeoutlen=500
let g:which_key_map = {}
let g:which_key_map['i'] = {
      \ 'name' : '+Indent Guides',
      \ 'g' : 'IndentGuidesToggle'
      \ }
let g:which_key_map.C = {
      \ 'name' : '+Coc',
      \ 'd' : ['<Plug>(coc-definition)', 'definition'],
      \ 't' : ['<Plug>(coc-type-definition)', 'type-definition'],
      \ 'i' : ['<Plug>(coc-implementation)', 'implementation'],
      \ 'r' : ['<Plug>(coc-references)', 'references'],
      \ }
let g:which_key_map.d = [':Defx -columns=icons:indent:filename:type', 'Open Defx']
" =========================================================================
