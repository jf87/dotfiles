" Minimal plugin-free vimrc for plain vim.
" Neovim uses its own config: ~/.config/nvim (jf87/kickstart.nvim)

set nocompatible
filetype plugin indent on
syntax on
silent! colorscheme habamax

" General {
    set virtualedit=onemore             " Allow for cursor beyond last character
    set history=1000                    " Store a ton of history
    set iskeyword-=.                    " '.' is an end of word designator
    set iskeyword-=#                    " '#' is an end of word designator
    set iskeyword-=-                    " '-' is an end of word designator
    set nobackup
    set nowritebackup
    set updatetime=300
    set clipboard^=unnamed,unnamedplus  " Yank to system clipboard
    if has('termguicolors')
        set termguicolors
    endif

    " Start at the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " Restore cursor to file position in previous editing session
    function! ResCur()
        if line("'\"") <= line("$")
            silent! normal! g`"
            return 1
        endif
    endfunction
    augroup resCur
        autocmd!
        autocmd BufWinEnter * call ResCur()
    augroup END
" }

" UI {
    set tabpagemax=15
    set showmode
    set ruler
    set showcmd
    set backspace=indent,eol,start
    set number
    set showmatch
    set incsearch
    set hlsearch
    set ignorecase
    set smartcase
    set wildmenu
    set wildmode=list:longest,full
    set whichwrap=b,s,h,l,<,>,[,]
    set scrolljump=5
    set scrolloff=3
    set signcolumn=yes
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:.
    set colorcolumn=88
" }

" Formatting {
    set nowrap
    set autoindent
    set shiftwidth=4
    set expandtab
    set tabstop=4
    set softtabstop=4
    set nojoinspaces
    set splitright
    set splitbelow

    " Wrapping and spell checking for text-like files
    au BufRead,BufNewFile *.txt,*.tex,*.md,*.yaml set wrap linebreak nolist textwidth=0 wrapmargin=0
    au BufRead *.txt,*.tex,*.md,*.yaml setlocal spelllang=en_us,de_de

    let g:tex_flavor='latex'
    let g:tex_comment_nospell=1
    let g:tex_conceal = ""
" }

" Key (re)Mappings {
    let mapleader = ','
    let maplocalleader = '_'

    " Find merge conflict markers
    map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

    " Change Working Directory to that of the current file
    cmap cwd lcd %:p:h
    cmap cd. lcd %:p:h

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv
    vnoremap . :normal .<CR>

    " For when you forget to sudo.. Really Write the file.
    cmap w!! w !sudo tee % >/dev/null

    cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
    map <leader>ew :e %%
    map <leader>es :sp %%
    map <leader>ev :vsp %%
    map <leader>et :tabe %%

    map <Leader>= <C-w>=

    " move faster between splits
    nnoremap <C-J> <C-W><C-J>
    nnoremap <C-K> <C-W><C-K>
    nnoremap <C-L> <C-W><C-L>
    nnoremap <C-H> <C-W><C-H>

    " look up word in macOS dictionary
    nmap <silent> <Leader>dd :!open dict://<cword><CR><CR>

    nmap <leader>jt <Esc>:%!python3 -m json.tool<CR><Esc>:set filetype=json<CR>
" }
