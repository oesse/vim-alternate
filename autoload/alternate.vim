
" === Public API =======================================================
function! alternate#GotoAlternateFile()
  let this_file = expand("%")
  let candidates = s:GetAlternateCandidates(this_file)

  call s:SwitchToBestCandidate(candidates)
endfunction


function! s:GetAlternateCandidates(filename)
  let candidates = s:GetSimilarFileNames(a:filename)
  let NotThisFile = {val -> fnamemodify(a:filename, ":p") !=# fnamemodify(val, ":p")}
  let NotADirectory = {val -> !isdirectory(val)}

  let IsViable = {val -> NotThisFile(val) && NotADirectory(val)}

  return filter(candidates, {idx, val -> IsViable(val)})
endfunction

function! s:GetSimilarFileNames(filename)
  let file_tail = fnamemodify(a:filename, ":t")
  let file_base = strpart(file_tail, 0, stridx(file_tail, "."))
  return globpath(".", "**/".file_base.".*", v:false, v:true)
endfunction

function! s:SwitchToBestCandidate(candidates)
  let number_of_candidates = len(a:candidates)
  if number_of_candidates == 0
    echom "No alternate file found"
    return 
  endif

  if number_of_candidates > 1
    let choice = s:ChooseBestCandidate(a:candidates)
    if len(choice) != 0
      execute "edit ".choice
      return
    endif
  endif

  execute "edit ".a:candidates[0]
endfunction

function! s:ChooseBestCandidate(candidates)
    let choice = confirm("switch to file: ", join(map(copy(a:candidates), {idx, val -> (idx+1) . " " . val}), "\n"))
   
    if choice == 0
      return ""
    endif
    return a:candidates[choice-1]
endfunction
