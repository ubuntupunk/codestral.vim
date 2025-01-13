" Created by Ubuntupunk on 12 January 2025
" Last modified on 13 January 2025
" copyright: Copyright (c) 2025
" File:plugin/codestral.vim"
" Description: This file contains the Vimscript code for the Codestral plugin.
" 
" This plugin provides integration with the Codestral API for code completions
" and chat-based interactions.

"Configuration variables"
let g:codestral_api_key = $CODESTRAL_API_KEY " Get API key from environment variable"
let g:codestral_api_chat_url = 'https://codestral.mistral.ai/v1/chat/completions'
let g:codestral_api_completion_url = 'https://codestral.mistral.ai/v1/fim/completions'
let g:codestral_debug_mode = 0 " 0: Disable debug messages, 1: Enable debug messages


function! CodestralDisable()
    let g:codestral_enabled = 0
endfunction

function! CodestralHandleResponse(job_id, data, event)
    if a:event ==# 'stdout'
        let l:response = '' " Initialize l:response to an empty string
        try
            let l:response = json_decode(a:data)
            if has_key(l:response, 'error')
                echoerr 'Codestral API Error: ' . l:response.error.message
            else
                call s:processChatResponse(l:response)
            endif
        catch /JSONDecodeError/
            echoerr 'Error decoding JSON response from Codestral API: ' . a:data
        endtry
    elseif a:event ==# 'stderr'
        echoerr 'Codestral API request failed: ' . a:data
    endif
endfunction

function! s:processChatResponse(response)
    if !has_key(a:response, 'choices')
        if g:codestral_debug_mode
            echomsg "Error: 'choices' key not found in API response. Check the raw response for details."
        endif
        return
    endif

    " Extract the content directly
    let l:message_content = a:response.choices[0].message.content

    " 1. Decode HTML entities
    let l:message_content = s:decodeHtmlEntities(l:message_content)

    " 2. Replace newlines with Vim newlines
    let l:message_content = substitute(l:message_content, '\n', "\n", 'g')

    " 3. Remove remaining problematic characters (carefully)
    let l:message_content = substitute(l:message_content, '[[:cntrl:]]', '', 'g')  " Only remove control characters now

    " Display the message content (you can adapt this part as needed)
    call s:displayChatMessages([l:message_content])  " Pass as a list
endfunction

function! s:decodeHtmlEntities(str)
    " Decode common HTML entities using a regular expression
    let l:str = substitute(a:str, '&quot;', '"', 'g')
    let l:str = substitute(l:str, '&#x27;', "'", 'g')
    let l:str = substitute(l:str, '&amp;', '&', 'g')
    let l:str = substitute(l:str, '&lt;', '<', 'g')
    let l:str = substitute(l:str, '&gt;', '>', 'g')
    return l:str
endfunction

function! s:displayChatMessages(messages)
    new
    for i in range(len(a:messages))
        let l:message = printf("%d. %s", i+1, a:messages[i])
        call append(line('$'), l:message)
    endfor
    nnoremap <buffer> <CR> :call s:insertChatResponse(line('.') - 1)<CR>
    nnoremap <buffer> <1-9> :call s:insertChatResponse(str2nr(nr2char(v:char)) - 1)<CR>
endfunction

function! s:insertChatResponse(index)
    let l:response = getline(line('.') + a:index)
    let l:response = matchstr(l:response, '\d+\. \(.*\)')
    normal! o
    normal!a
    call append(line('.'), split(l:response, '\n'))
    normal! k
endfunction

function! s:sendChatRequest(message)
    let l:data = json_encode({'model': 'codestral-latest', 'messages': [{'role': 'user', 'content': a:message}]})
    let l:headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ' . g:codestral_api_key}
    let l:curl_command = 'curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer ' . g:codestral_api_key . '" -d ' . shellescape(l:data) . ' ' . g:codestral_api_chat_url . ' > /tmp/codestral_response' " Redirect output to a file
    let l:exit_code = system(l:curl_command)
    if l:exit_code != 0
        echoerr 'Error: curl command failed with exit code ' . l:exit_code . ': ' . system('echo $?')  " Display the exit code
        let l:error_message = system('cat /tmp/codestral_response 2>/dev/null || echo "Curl output not found"') " Capture potential error messages from curl
        echoerr l:error_message
        return
    endif
    let l:response = readfile('/tmp/codestral_response')[0] " Read the response from the file
    if g:codestral_debug_mode
        echomsg "Raw API Response: " . l:response "Added line to print raw response"
    endif
    call delete('/tmp/codestral_response') " Clean up the temporary file. IMPORTANT!
    call CodestralHandleResponse(0, l:response, 'stdout')
endfunction


function! OpenChatBuffer()
    if exists('g:codestral_enabled') && g:codestral_enabled == 0
        return
    endif
    let l:input = input("Enter your message: ")
    if l:input != ""
        call s:sendChatRequest(l:input)
    endif
endfunction

function! CodestralEnabled()
    if exists('g:codestral_enabled') && g:codestral_enabled == 0
        return
    endif
endfunction

function! codestral#CompletionEnable()
    let g:codestral_completion_enabled = 1
    setlocal completefunc=codestral#Complete
endfunction

function! codestral#CompletionDisable()
    let g:codestral_completion_enabled = 0
    "setlocal completefunc= "Commented out to avoid potential conflicts
endfunction

function! codestral#Complete(findstart, base)
    if !g:codestral_completion_enabled
        return []
    endif

    let l:context = getline(line('.')-5, line('.')-1)

    let l:completions = s:getCodestralCompletions(a:base, l:context)

    return l:completions
endfunction

function! s:getCodestralCompletions(base, context) abort
    let l:data = json_encode({
        \ 'model': 'codestral-latest',  " Or the appropriate model name
        \ 'max_tokens': 50,  " Adjust as needed
        \ 'temperature': 0.2,  " Adjust as needed
        \ 'stop': ["\n"]  " Stop at newline
        \ })

    let l:headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ' . g:codestral_api_key}

    " Get the current filetype
    let l:filetype = &filetype

    " Add filetype information to the prompt
    let l:prompt = join(a:context, "\n") . a:base
    if !empty(l:filetype)
        let l:prompt = '-- ' . l:filetype . " --\n" . l:prompt
    endif

    " Update l:data with the modified prompt
    let l:data = json_encode({
        \   'model': 'codestral-latest',
        \   'prompt': l:prompt,  " Use the modified prompt here
        \   'max_tokens': 50,
        \   'temperature': 0.2,
        \   'stop': ["\n"]
        \ })

    let l:cmd = ['curl', '-s', '-X', 'POST',
                \ '-H', 'Content-Type: application/json',
                \ '-H', 'Authorization: Bearer ' . g:codestral_api_key,
                \ '-d', l:data,
                \ g:codestral_api_completion_url]

    let l:job_id = jobstart(l:cmd, {
        \ 'on_stdout': function('s:handleCompletionResponse', [a:base]),
        \ 'on_stderr': {j, d, e -> echoerr 'Completion request failed: ' . a:d},
        \ 'err_close': {j, c -> echoerr 'Completion request error: ' . a:c}
        \ })

    return []
endfunction


function! s:handleCompletionResponse(base, job_id, data, event)
    if a:event !=# 'stdout'
        return  " Ignore non-stdout events
    endif

    if g:codestral_debug_mode
        echomsg "Codestral Completion: Handling response"  " Debug message 1
    endif

    let l:response = json_decode(a:data)

    if has_key(l:response, 'error')
        echoerr 'Codestral API Error: ' . l:response.error.message
        return []
    endif

    if !has_key(l:response, 'choices') || empty(l:response.choices)
        if g:codestral_debug_mode
            echomsg "Codestral Completion: No choices returned" " Debug message 2
        endif
        return []
    endif

    let l:completions = []
    for choice in l:response.choices
        let l:word = choice.text
        call add(l:completions, {'word': l:word, 'menu': '[Codestral]'})
    endfor

    if g:codestral_debug_mode
        echomsg "Codestral Completion: Triggering completion popup with " . len(l:completions) . " items"  " Debug message 3
    endif

    call complete(1, l:completions)
endfunction

function! codestral#ToggleDebug()
    let g:codestral_debug_mode = !g:codestral_debug_mode
    echomsg "Codestral debug mode: " . (g:codestral_debug_mode ? "Enabled" : "Disabled")
endfunction
