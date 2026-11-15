if empty(glob('~/vimfiles/autoload/plug.vim'))
  silent !curl -fLo ~/vimfiles/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/vimfiles/plugged')

Plug 'preservim/nerdtree'
Plug 'preservim/tagbar'
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'tpope/vim-surround'
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

call plug#end()

syntax on
filetype plugin indent on
set nocompatible 
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8
set showmatch
set matchtime=2               " Время показа парной скобки (0.2 сек)
set linebreak                 " Перенос по словам
set tabstop=2
set shiftwidth=4
set expandtab
set guifont=Iosevka\ 20
set guioptions-=m
set guioptions-=T
set noesckeys
set relativenumber
set number
set ignorecase
set smartcase
set expandtab                 " Табуляция пробелами
set incsearch
set cinoptions=l1
set modeline
set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0
set autoindent
set autochdir
set backspace=indent,eol,start " Корректная работа Backspace
set hidden                    " Разрешаем скрытые буферы
set shortmess+=I              " Не показывать приветственное сообщение
set updatetime=300            " Задержка для gitgutter
set clipboard=unnamed
set shellslash                " Используем / в путях (важно для Windows)
set nobackup
set mouse=a
set noundofile
colorscheme habamax
" set statusline+=%{&iminsert ? '[RU]' : '[EN]'}


" Only for gui (Gvim)
if has('gui_running')
  " Шрифт (Consolas - стандартный моноширинный шрифт Windows)
  set guifont=Consolas:h11
  " Убираем меню и тулбар для экономии места
  set guioptions-=m
  set guioptions-=T
  " Максимальное окно при запуске
  autocmd GUIEnter * simalt ~x
endif

" NerdTree
let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1
let NERDTreeAutoDeleteBuffer=1
let NERDTreeIgnore=['\.pyc$', '\~$', '\.swp$', '__pycache__', '\.git$', 'node_modules']
let NERDTreeQuitOnOpen=0
let NERDTreeShowLineNumbers=0
let NERDTreeWinSize=25

" Closing vim if exists only NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


" Tagbar
nnoremap <silent> <F8> :TagbarToggle<CR>
let g:tagbar_position = 'right'
let g:tagbar_width = 30
let g:tagbar_autoshowtag = 1
let g:tagbar_sort = 0
let g:tagbar_autoclose = 0

" ctags
" vim-gitgutter
let g:gitgutter_sign_added = '++'
let g:gitgutter_sign_modified = '~~'
let g:gitgutter_sign_removed = '--'
let g:gitgutter_sign_modified_removed = '~~'
let g:gitgutter_map_keys = 0
let g:gitgutter_async = 1
let g:gitgutter_sign_column_always = 1
" Увеличиваем интервал обновления для экономии CPU
let g:gitgutter_sign_priority = 10

" NERD Commenter
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1

let mapleader = " "


autocmd BufEnter * if &filetype == "go" | setlocal noexpandtab
autocmd BufNewFile,BufRead ?\+.c3 setf c

" maps
map gf :e <cfile><CR>
"map <leader>D :execute 'normal! a' . strftime('(%Y%m%d-%H%M%S)')<CR>
map <leader>D :execute 'normal! a' . system('date -u "+(%Y%m%d-%H%M%S)"')<CR>

"NERDTree
nnoremap <silent> <C-n> :NERDTreeToggle<CR>
nnoremap <silent> <leader>f :NERDTreeFind<CR>

" bufenter
nnoremap <silent> <leader>b :BufExplorer<CR>


" vim-fugitive - Git
nnoremap <silent> <leader>gs :Git<CR>
nnoremap <silent> <leader>gc :Git commit<CR>
nnoremap <silent> <leader>gp :Git push<CR>
nnoremap <silent> <leader>gl :Git pull<CR>
nnoremap <silent> <leader>gd :Gdiffsplit<CR>
nnoremap <silent> <leader>gb :Git blame<CR>

" vim-gitgutter - навигация по изменениям
nnoremap <silent> [h :GitGutterPrevHunk<CR>
nnoremap <silent> ]h :GitGutterNextHunk<CR>
nnoremap <silent> <leader>hp :GitGutterPreviewHunk<CR>
nnoremap <silent> <leader>hs :GitGutterStageHunk<CR>
nnoremap <silent> <leader>hu :GitGutterUndoHunk<CR>

" Быстрое сохранение и выход
nnoremap <silent> <leader>w :w<CR>
nnoremap <silent> <leader>q :q<CR>
nnoremap <silent> <leader>x :x<CR>


" Быстрая очистка подсветки поиска
nnoremap <silent> <leader><space> :nohlsearch<CR>


" Отключаем синтаксис для очень больших файлов (>10MB)
augroup LargeFile
  autocmd!
  autocmd BufReadPre * let f = getfsize(expand("<afile>")) | if f > 10000000 | syntax clear | set norelativenumber | endif
augroup END

" Отключаем курсор-мигание (экономит ресурсы)
set gcr=a:blinkon0

" Status line

" set statusline=
" set statusline+=\ %f          " Имя файла
" set statusline+=\ %m          " Модифицирован?
" set statusline+=\ %r          " Только для чтения?
" set statusline+=%=            " Разделитель справа
" set statusline+=\ %y          " Тип файла
" set statusline+=\ %{&encoding}
" set statusline+=\ %l/%L       " Строка/всего строк
" set statusline+=\ %c          " Колонка
" set statusline+=\ %P          " Процент от начала файла

set laststatus=2
