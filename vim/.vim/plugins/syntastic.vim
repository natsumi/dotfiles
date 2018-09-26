let g:syntastic_python_checkers=['flake8'] "Python syntax checker
let g:syntastic_ruby_checkers=['rubocop'] "Ruby
let g:syntastic_scss_checkers=['scss_lint'] "SASS CSS
let g:syntastic_haml_checkers=['haml-lint'] "HAML
let g:syntastic_json_checkers=['jsonlint'] "JSON
let g:syntastic_javascript_checkers=['eslint'] "ES6
let g:syntastic_slim_checkers=['slimrb'] "Slim Template
let g:syntastic_aggregate_errors = 1

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_loc_list_height = 5
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let g:syntastic_error_symbol = '❌'
let g:syntastic_style_error_symbol = '⁉️'
let g:syntastic_warning_symbol = '⚠️'
let g:syntastic_style_warning_symbol = '💩'

highlight link SyntasticErrorSign SignColumn
highlight link SyntasticWarningSign SignColumn
highlight link SyntasticStyleErrorSign SignColumn
highlight link SyntasticStyleWarningSign SignColumn

