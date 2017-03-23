" release autogroup in MyAutoCmd
augroup MyAutoCmd
    autocmd!
augroup END

syntax on
set showmatch matchtime=1
set autoindent
"Cインデントの設定
set cinoptions+=:0
"タイトルを表示
set title
"コマンドラインの高さ (gvimはgvimrcで指定)
set cmdheight=2
set laststatus=2
"コマンドをステータス行に表示
set showcmd
"画面最後の行をできる限り表示する
set display=lastline
" ハイライトを有効にする
if &t_Co > 2 || has('gui_running')
    syntax on
endif
set ts=4 sw=4 sts=4
set tabstop=4
set autoindent
set expandtab
set number
"検索系
set ignorecase          " 大文字小文字を区別しない
set smartcase           " 検索文字に大文字がある場合は大文字小文字を区別
set incsearch           " インクリメンタルサーチ
set hlsearch            " 検索マッチテキストをハイライト (2013-07-03
"編集系
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'

set shiftround          " '<'や'>'でインデントする際に'shiftwidth'の倍数に丸める
set infercase           " 補完時に大文字小文字を区別しない
set virtualedit=all     " カーソルを文字が存在しない部分でも動けるようにする
set hidden              " バッファを閉じる代わりに隠す（Undo履歴を残すため）
set switchbuf=useopen   " 新しく開く代わりにすでに開いてあるバッファを開く
set showmatch           " 対応する括弧などをハイライト表示する
set matchtime=3         " 対応括弧のハイライト表示を3秒にする

" 対応括弧に'<'と'>'のペアを追加
set matchpairs& matchpairs+=<:>
" バックスペースでなんでも消せるようにする
set backspace=indent,eol,start


" Swapファイル？Backupファイル？前時代的すぎなので全て無効化する
set nowritebackup
set nobackup
set noswapfile



"表示関係
"set list
set wrap                " 長いテキストの折り返し
set textwidth=0         " 自動的に改行が入るのを無効化
"set colorcolumn=80      " その代わり80文字目にラインを入れる

" 前時代的スクリーンベルを無効化
set t_vb=
set novisualbell


" デフォルト不可視文字は美しくないのでUnicodeで綺麗に
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↲
" TABにて対応ペアにジャンプ
nnoremap <Tab> %
vnoremap <Tab> %

" w!! でスーパーユーザーとして保存（sudoが使える環境限定）
cmap w!! w !sudo tee > /dev/null %


" :e などでファイルを開く際にフォルダが存在しない場合は自動作成
function! s:mkdir(dir, force)
    if !isdirectory(a:dir) && (a:force ||
                \ input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
        call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
endfunction
autocmd MyAutoCmd BufWritePre * call s:mkdir(expand('<afile>:p:h'), v:cmdbang)

" vim 起動時のみカレントディレクトリを開いたファイルの親ディレクトリに指定
autocmd MyAutoCmd VimEnter * call s:ChangeCurrentDir('', '')
function! s:ChangeCurrentDir(directory, bang)
    if a:directory == ''
        lcd %:p:h
    else
        execute 'lcd' . a:directory
    endif

    if a:bang == ''
        pwd
    endif
endfunction


set backspace=indent,eol,start
set t_Co=256
colorscheme molokai
set fileencoding=utf-8


if has('vim_starting')
    set runtimepath+=~/.vim/bundle/neobundle.vim
    call neobundle#rc(expand('~/.vim/.bundle'))
endif

" originalrepos on github
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/Snipmate.vim'
NeoBundle 'https://github.com/thinca/vim-quickrun.git'
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'plasticboy/vim-markdown'
NeoBundle 'kannokanno/previm'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'fatih/vim-go'
NeoBundleLazy 'supermomonga/neocomplete-rsense.vim', { 'autoload' : {
            \ 'insert' : 1,
            \ 'filetypes': 'ruby',
            \ }}


filetype plugin on
filetype indent on

"set clipboard=unnamed,autoselect
"set clipboard& clipboard+=unnamedplus " 2013-07-03 14:30 unnamed 追加
"set clipboard& clipboard+=unnamed
set clipboard+=unnamed









"---------------------------------------
""ゆとり仕様(カーソルキーとかBSキーとか)
"---------------------------------------
""viとの互換性を無効にする(INSERT中にカーソルキーが有効になる)
set nocompatible
"カーソルを行頭，行末で止まらないようにする
set whichwrap=b,s,h,l,<,>,[,]
""BSで削除できるものを指定する
" indent  : 行頭の空白
" " eol     : 改行
" " start   : 挿入モード開始位置より手前の文字
augroup InsertHook
    autocmd!
    autocmd InsertEnter * highlight StatusLine guifg=#ccdc90 guibg=#2E4340
    autocmd InsertLeave * highlight StatusLine guifg=#2E4340 guibg=#ccdc90
augroup END
set clipboard+=unnamed
set history=1000
augroup vimrcEx
    autocmd!
    autocmd BufReadPost *
                \ if line("'\"") > 1 && line("'\"") <= line('$') |
                \   exe "normal! g`\"" |
                \ endif
augroup END

set ruler
set cursorline 
"set cursorcolumn 
highlight CursorLine cterm=underline ctermfg=NONE ctermbg=NONE
set showmatch 
let g:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none'
if has('syntax')
    augroup InsertHook
        autocmd!
        autocmd InsertEnter * call s:StatusLine('Enter')
        autocmd InsertLeave * call s:StatusLine('Leave')
    augroup END
endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
    if a:mode == 'Enter'
        silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
        silent exec g:hi_insert
    else
        highlight clear StatusLine
        silent exec s:slhlcmd
        redraw
    endif
endfunction 

function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=underline ctermfg=darkgrey gui=underline guifg=darkgrey
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        " ZenkakuSpaceをカラーファイルで設定するなら次の行は削除
        autocmd ColorScheme       * call ZenkakuSpace()
        " 全角スペースのハイライト指定
        autocmd VimEnter,WinEnter * match ZenkakuSpace /　/
    augroup END
    call ZenkakuSpace()
endif
"#############################################



function! s:meet_neocomplete_requirements()
    return has('lua') && (v:version > 703 || (v:version == 703 && has('patch885')))
endfunction

if s:meet_neocomplete_requirements()
    NeoBundle 'Shougo/neocomplete.vim'
    NeoBundleFetch 'Shougo/neocomplcache.vim'
else
    NeoBundleFetch 'Shougo/neocomplete.vim'
    NeoBundle 'Shougo/neocomplcache.vim'
endif


if s:meet_neocomplete_requirements()
    " 新しく追加した neocomplete の設定
    "------------------------------------
    " neocomplete.vim
    "------------------------------------
    "Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
    " Disable AutoComplPop.
    let g:acp_enableAtStartup = 0
    " Use neocomplete.
    let g:neocomplete#enable_at_startup = 1
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
        " return neocomplete#close_popup() . "\<CR>"
        " For no inserting <CR> key.
        return pumvisible() ? neocomplete#close_popup() : "\<CR>"
    endfunction
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  neocomplete#close_popup()
    inoremap <expr><C-e>  neocomplete#cancel_popup()

    " Close popup by <Space>.
    "inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"

    " autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
else
    " Disable AutoComplPop. Comment out this line if AutoComplPop is not installed.
    let g:acp_enableAtStartup = 0
    " Launches neocomplcache automatically on vim startup.
    let g:neocomplcache_enable_at_startup = 1
    " Use smartcase.
    let g:neocomplcache_enable_smart_case = 1
    " Use camel case completion.
    let g:neocomplcache_enable_camel_case_completion = 1
    " Use underscore completion.
    let g:neocomplcache_enable_underbar_completion = 1
    " Sets minimum char length of syntax keyword.
    let g:neocomplcache_min_syntax_length = 3
    " buffer file name pattern that locks neocomplcache. e.g. ku.vim or fuzzyfinder 
    let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

    " Define file-type dependent dictionaries.
    let g:neocomplcache_dictionary_filetype_lists = {
                \ 'default' : '',
                \ 'vimshell' : $HOME.'/.vimshell_hist',
                \ 'scheme' : $HOME.'/.gosh_completions'
                \ }
    "#let g:neocomplete#force_omni_input_patterns.python = '\h\w*\|[^. \t]\.\w*'

    " Define keyword, for minor languages
    if !exists('g:neocomplcache_keyword_patterns')
        let g:neocomplcache_keyword_patterns = {}
    endif
    let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

    " .や::を入力したときにオムニ補完が有効になるようにする
    if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
    endif
    let g:neocomplete#force_omni_input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'

    " 環境変数RSENSE_HOMEに'/usr/local/bin/rsense'を指定しても動く
    let g:neocomplete#sources#rsense#home_directory = '/usr/local/bin/rsense'

    "" Recommended key-mappings.
    "<CR>: close popup and save indent.
    inoremap <expr><CR>  pumvisible() ? neocomplcache#close_popup() : "\<CR>"
    "" <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    "" <C-h>, <BS>: close popup and delete backword char.
    "inoremap <expr><Space> neocomplcache#close_popup()."\<Space>"
    inoremap <expr><BS> neocomplcache#smart_close_popup()."\<BS>"
    inoremap <expr><C-e>  neocomplcache#close_popup()
    "inoremap <expr><C-e>  neocomplcache#cancel_popup()
    "
    "" AutoComplPop like behavior.
    let g:neocomplcache_enable_auto_select = 0

    " Enable omni completion. Not required if they are already set elsewhere in .vimrc
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

    " Enable heavy omni completion, which require computational power and may stall the vim. 
    if !exists('g:neocomplcache_omni_patterns')
        let g:neocomplcache_omni_patterns = {}
    endif
    let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
    "autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
    let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
    let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::' 

endif

" for lightline.vim --------------------
let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ 'component': {
            \   'readonly': '%{&readonly?"\u2b64":""}',
            \ },
            \ 'separator': { 'left': "\u2b80", 'right': "\u2b82" },
            \ 'subseparator': { 'left': "\u2b81", 'right': "\u2b83" },
            \ }

NeoBundle "thinca/vim-template"
" テンプレート中に含まれる特定文字列を置き換える
autocmd MyAutoCmd User plugin-template-loaded call s:template_keywords()
function! s:template_keywords()
    silent! %s/<+DATE+>/\=strftime('%Y-%m-%d')/g
    silent! %s/<+FILENAME+>/\=expand('%:r')/g
endfunction
" テンプレート中に含まれる'<+CURSOR+>'にカーソルを移動
autocmd MyAutoCmd User plugin-template-loaded
            \   if search('<+CURSOR+>')
            \ |   silent! execute 'normal! "_da>'
            \ | endif

NeoBundle "nathanaelkane/vim-indent-guides"
let s:hooks = neobundle#get_hooks("vim-indent-guides")
function! s:hooks.on_source(bundle)
    let g:indent_guides_guide_size = 1
    IndentGuidesEnable " 2013-06-24 10:00 追記
endfunction
let g:indent_guides_auto_colors=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd   ctermbg=110
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven  ctermbg=140
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_guide_size=1

NeoBundleLazy "davidhalter/jedi-vim", {
            \ "autoload": {
            \   "filetypes": ["python", "python3", "djangohtml"],
            \ },
            \ "build": {
            \   "mac": "pip install jedi",
            \   "unix": "pip install jedi",
            \ }}

let g:syntastic_python_checkers = ['flake8', 'pep8']
let g:syntastic_python_flake8_args = '--ignore="E501"'
let g:syntastic_python_pep8_args = '--ignore="E501"'

au BufRead,BufNewFile *.md set filetype=markdown

function! Preserve(command)
    " Save the last search.
    let search = @/
    " Save the current cursor position.
    let cursor_position = getpos('.')
    " Save the current window position.
    normal! H
    let window_position = getpos('.')
    call setpos('.', cursor_position)
    " Execute the command.
    execute a:command
    " Restore the last search.
    let @/ = search
    " Restore the previous window position.
    call setpos('.', window_position)
    normal! zt
    " Restore the previous cursor position.
    call setpos('.', cursor_position)
endfunction

function! Autopep8()
    call Preserve(':silent %!autopep8 -')
endfunction

" Shift + F で自動修正
autocmd FileType python nnoremap <S-f> :call Autopep8()<CR>
execute pathogen#infect()
