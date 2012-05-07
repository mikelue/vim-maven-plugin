if exists('g:loaded_maven') && !exists('g:reload_maven')
    finish
endif

if exists('g:reload_maven')
	autocmd! MavenAutoDetect
	augroup! MavenAutoDetect

	unmenu Maven

	nunmap maven#run-unittest
	iunmap maven#run-unittest
	nunmap maven#run-unittest-all
	iunmap maven#run-unittest-all
	nunmap maven#switch-unittest-file
	iunmap maven#switch-unittest-file
	iunmap maven#open-test-result
	nunmap maven#open-test-result
endif

let g:loaded_maven = 1

" Global settings {{{
if !exists("g:maven_auto_set_path")
	let g:maven_auto_set_path = 1
endif
if !exists("g:maven_auto_chdir")
	let g:maven_auto_chdir = 0
endif
" }}}

" Maps {{{
nnoremap <silent> <unique> maven#run-unittest :Mvn test -Dtest=%:t:r -DfailIfNoTests=true<CR>
inoremap <silent> <unique> maven#run-unittest <C-O>:Mvn test -Dtest=%:t:r -DfailIfNoTests=true<CR>
nnoremap <silent> <unique> maven#run-unittest-all :Mvn test -DfailIfNoTests=true<CR>
inoremap <silent> <unique> maven#run-unittest-all <C-O>:Mvn test -DfailIfNoTests=true<CR>
nnoremap <silent> <unique> maven#switch-unittest-file :call <SID>SwitchUnitTest()<CR>
inoremap <silent> <unique> maven#switch-unittest-file <C-O>:call <SID>SwitchUnitTest()<CR>
nnoremap <silent> <unique> maven#open-test-result :call <SID>OpenTestResult()<CR>
inoremap <silent> <unique> maven#open-test-result <C-O>:call <SID>OpenTestResult()<CR>
" }}}

" Autocmds {{{
augroup MavenAutoDetect
autocmd MavenAutoDetect BufNewFile,BufReadPost *.* call s:SetupMavenEnv()
autocmd MavenAutoDetect BufWinEnter *.* call s:AutoChangeCurrentDirOfWindow()
autocmd MavenAutoDetect QuickFixCmdPost make call s:ProcessQuickFixForMaven()
" }}}

" Commands {{{
command! -bang -nargs=+ -complete=custom,s:CompleteMavenLifecycle Mvn call s:RunMavenCommand(<q-args>, expand("<bang>"))
command! -nargs=1 -complete=customlist,s:ListCandidatesOfTest MvnEditTestCode call s:EditTestCode(<q-args>)
command! -nargs=+ -complete=custom,s:CmdCompleteListPackage MvnNewMainFile call s:EditNewFile(<q-args>, "main")
command! -nargs=+ -complete=custom,s:CmdCompleteListPackage MvnNewTestFile call s:EditNewFile(<q-args>, "test")
" }}}

" Menu {{{
210menu <silent> Maven.Run\ File\ UnitTest<Tab><F5> :Mvn test -Dtest=%:t:r<CR>
210menu <silent> Maven.Run\ UnitTest<Tab><Ctrl-F5> :Mvn test<CR>
210menu <silent> Maven.Switch\ Unit\ Test\ File<Tab><F6> :call <SID>SwitchUnitTest()<CR>
210menu <silent> Maven.Open\ Unit\ Test\ Result<Tab><Ctrl-F6> :MvnOpenTestResult<CR>

210menu <silent> Maven.Phrase.Clean.pre-clean :Mvn pre-clean<CR>
210menu <silent> Maven.Phrase.Clean.clean :Mvn clean<CR>
210menu <silent> Maven.Phrase.Clean.post-clean :Mvn post-clean<CR>

210menu <silent> Maven.Phrase.Default.validate :Mvn validate<CR>
210menu <silent> Maven.Phrase.Default.initialize :Mvn initialize<CR>
210menu <silent> Maven.Phrase.Default.generate-sources :Mvn generate-sources<CR>
210menu <silent> Maven.Phrase.Default.process-sources :Mvn process-sources<CR>
210menu <silent> Maven.Phrase.Default.generate-resources :Mvn generate-resources<CR>
210menu <silent> Maven.Phrase.Default.process-resources :Mvn process-resources<CR>
210menu <silent> Maven.Phrase.Default.compile :Mvn compile<CR>
210menu <silent> Maven.Phrase.Default.process-classes :Mvn process-classes<CR>
210menu <silent> Maven.Phrase.Default.generate-test-sources :Mvn generate-test-sources<CR>
210menu <silent> Maven.Phrase.Default.process-test-sources :Mvn process-test-sources<CR>
210menu <silent> Maven.Phrase.Default.generate-test-resources :Mvn generate-test-resources<CR>
210menu <silent> Maven.Phrase.Default.process-test-resources :Mvn process-test-resources<CR>
210menu <silent> Maven.Phrase.Default.test-compile :Mvn test-compile<CR>
210menu <silent> Maven.Phrase.Default.process-test-classes :Mvn process-test-classes<CR>
210menu <silent> Maven.Phrase.Default.post-process :Mvn post-process<CR>
210menu <silent> Maven.Phrase.Default.test :Mvn test<CR>
210menu <silent> Maven.Phrase.Default.prepare-package :Mvn prepare-package<CR>
210menu <silent> Maven.Phrase.Default.package :Mvn package<CR>
210menu <silent> Maven.Phrase.Default.pre-integration-test :Mvn pre-integration-test<CR>
210menu <silent> Maven.Phrase.Default.integration-test :Mvn integration-test<CR>
210menu <silent> Maven.Phrase.Default.post-integration-test :Mvn post-integration-test<CR>
210menu <silent> Maven.Phrase.Default.verify :Mvn verify<CR>
210menu <silent> Maven.Phrase.Default.install :Mvn install<CR>
210menu <silent> Maven.Phrase.Default.deploy :Mvn deploy<CR>

210menu <silent> Maven.Phrase.Site.pre-site :Mvn pre-site<CR>
210menu <silent> Maven.Phrase.Site.site :Mvn site<CR>
210menu <silent> Maven.Phrase.Site.post-site :Mvn post-site<CR>
210menu <silent> Maven.Phrase.Site.site-deploy :Mvn site-deploy<CR>
" }}}

" Setup the maven environment for current buffer
function! <SID>SetupMavenEnv()
	let currentBuffer = bufnr("%")

    call maven#setupMavenProjectInfo(currentBuffer)

    if !maven#isBufferUnderMavenProject(currentBuffer)
        return
    endif

	" Setup the paths of current buffer
	if g:maven_auto_set_path == 1
		let currentPath = getbufvar(currentBuffer, "&path")
		let mavenPaths = maven#getListOfPaths(currentBuffer)

		if stridx(currentPath, mavenPaths[0]) == -1
			call setbufvar(currentBuffer, "&path", join(mavenPaths, ",") . "," . &path)
		endif
	endif
	" //:~)

	compiler maven
endfunction

function! <SID>OpenTestResult()
	let triggeredFileName = maven#slashFnamemodify(expand("%"), ":p")
	let currentBuf = bufnr(triggeredFileName)

	if !s:CheckFileInMavenProject(currentBuf)
		return
	endif

	let testSourcePattern = '\v^.+/src/test/java/(.+)\.java$'
	let testNgResultPattern = '\v^.+/target/surefire-reports/junitreports/TEST-(.+)\.xml$'
	let junitResultPattern = '\v^.+/target/surefire-reports/(.+)\.txt$'
	let mavenProjectRoot = maven#getMavenProjectRoot(currentBuf)

	" Open the file of testing or the result of testing, repectively
	if triggeredFileName =~ testSourcePattern
		let fullClassName = substitute(substitute(triggeredFileName, testSourcePattern, '\1', ''), '/', '.', 'g')

		let testNgResultFile = mavenProjectRoot . '/target/surefire-reports/junitreports/TEST-' . fullClassName . ".xml"
		let junitResultFile = mavenProjectRoot . '/target/surefire-reports/' . fullClassName . ".txt"

		if filereadable(testNgResultFile)
			let targetFileName = testNgResultFile
		elseif filereadable(junitResultFile)
			let targetFileName = junitResultFile
		else
			call s:EchoWarning("Can't find result file of testing for: " . fullClassName)
			return
		endif
	elseif triggeredFileName =~ testNgResultPattern
		let targetFileName = substitute(triggeredFileName, testNgResultPattern, '\1', '')
		let targetFileName = mavenProjectRoot . '/src/test/java/' . substitute(targetFileName, '\.', '/', 'g') . ".java"
	elseif triggeredFileName =~ junitResultPattern
		let targetFileName = substitute(triggeredFileName, junitResultPattern, '\1', '')
		let targetFileName = mavenProjectRoot . '/src/test/java/' . substitute(targetFileName, '\.', '/', 'g') . ".java"
	else
		call s:EchoWarning("Can't recognize file: " . triggeredFileName)
		return
	endif
	" //:~)

	if filereadable(targetFileName)
		if targetFileName =~ '\.java$'
			execute "edit " . targetFileName
		else
			execute "view " . targetFileName
		endif
		return
	endif

	call s:EchoWarning("File not exists:" . targetFileName)
endfunction
function! <SID>SwitchUnitTest()
	update
	let currentBuf = bufnr("%")

	if !s:CheckFileInMavenProject(currentBuf)
		return
	endif

	" Recognize the what file type is(source/unit test)
	let classNameOfBuf = maven#slashFnamemodify(bufname(currentBuf), ":t:r")
	let fileDir = maven#slashFnamemodify(bufname(currentBuf), ":p:h")
	let fileExtension = maven#slashFnamemodify(bufname(currentBuf), ":e")

	if fileDir !~ '/src/\%(main\|test\)/\w\+'
		call s:EchoWarning("Can't recognize file of code: " . maven#slashFnamemodify(bufname(currentBuf), ":t"))
		return
	endif
	" //:~)

	" Compose the corresponding file name
	let listOfExistingCandidates = []
	let listOfNewCandidates = []

	if fileDir =~ 'src/main'
		let targetFilePath = s:ConvertToFilePathForTest(classNameOfBuf, fileDir, fileExtension)
	else
		let targetFilePath = s:ConvertToFilePathForSource(classNameOfBuf, fileDir, fileExtension)
	endif

	if targetFilePath == ""
		return
	endif
	" //:~)

	" Ask whether to edit a new file if the file doesn't exist
	let directory = maven#slashFnamemodify(targetFilePath, ":p:h")
	if !isdirectory(directory)
		if confirm("Directory:[" . directory . "] doesn't exist\nCreate It?", "&Yes\n&No", 1) == 2
			return
		endif

		call mkdir(directory, "p")
	endif
	" //:~)

	execute "edit " . targetFilePath
endfunction

function! <SID>ConvertToFilePathForTest(sourceClassName, fileDir, fileExtension)
	" Compose the corresponding file name
	let listOfExistingCandidates = []
	let listOfNewCandidates = []

	" Prepare the list of candidates
	let testDir = substitute(a:fileDir, '/src/main/', '/src/test/', '')
	let listOfCandidates = maven#getCandidateClassNameOfTest(a:sourceClassName)

	for candidate in listOfCandidates
		let candidatePath = testDir . "/" . candidate . "." . a:fileExtension
		if filereadable(candidatePath)
			call add(listOfExistingCandidates, candidatePath)
		endif

		call add(listOfNewCandidates, candidatePath)
	endfor
	" //:~)

	" Ask the user to choose multiple condidates of existing/new test code
	if len(listOfExistingCandidates) == 1
		return listOfExistingCandidates[0]
	elseif len(listOfExistingCandidates) > 0
		let selectedIdx = confirm("Select a test code:\n", s:BuildSelectionOfClassName(listOfExistingCandidates), 1) - 1
		if selectedIdx == -1 || selectedIdx == len(listOfExistingCandidates)
			return
		endif

		return listOfExistingCandidates[selectedIdx]
	elseif len(listOfNewCandidates) > 0
		let selectedIdx = confirm("Edit a new test code:\n", s:BuildSelectionOfClassName(listOfNewCandidates), 1) - 1
		if selectedIdx == -1 || selectedIdx == len(listOfNewCandidates)
			return
		endif

		return listOfNewCandidates[selectedIdx]
	endif
	" //:~)

	throw "Can't figure out a test for: " . a:sourceClassName
endfunction
function! <SID>ConvertToFilePathForSource(testClassName, fileDir, fileExtension)
	let fileDir = substitute(a:fileDir, '/src/test/', '/src/main/', '')

	" Convert the class name of test code to class name of source code
	for matchPattern in s:BuildMatchPattersForTestClass()
		if a:testClassName =~ matchPattern
			return fileDir . "/" . substitute(a:testClassName, matchPattern, "", "") . "." . a:fileExtension
		endif
	endfor
	" //:~)

	throw "Can't figure out a source for: " . a:testClassName
endfunction

" Build patters for matching part of class name of testing code
function! <SID>BuildMatchPattersForTestClass()
	let matchPatterns = []

	for metaClassName in maven#getCandidateClassNameOfTest("<>")
		let beginIndex = match(metaClassName, "<")
		let endIndex = match(metaClassName, ">")

		" There is a prefix in class name of test code
		if beginIndex > 0
			call add(matchPatterns, "^" . strpart(metaClassName, 0, beginIndex))
		endif
		" //:~)
		" There is a suffix in class name of test code
		if endIndex < strlen(metaClassName) - 1
			call add(matchPatterns, strpart(metaClassName, endIndex + 1) . "$")
		endif
		" //:~)
	endfor

	return matchPatterns
endfunction

" List the candidates of file name for testing.
" This function is used to generate command completion in VIM.
"
" This result of this function is the file name of candidate.
" For example:
" [
" 	"ControllerTest.java",
" 	"ControllerTestIT.java",
" 	"ControllerTestCase.java",
" 	"TestController.java"
" ]
function! <SID>ListCandidatesOfTest(argLead, cmdLine, cursorPos)
	let candidatesOfFileNames = maven#getCandidateClassNameOfTest(maven#slashFnamemodify(bufname("%"), ":t:r"))
	let fileExtension = maven#slashFnamemodify(bufname("%"), ":e")

	let i = 0
	while i < len(candidatesOfFileNames)
		let candidatesOfFileNames[i] = candidatesOfFileNames[i] . "." . fileExtension
		let i += 1
	endwhile

	return candidatesOfFileNames
endfunction

" Generate list of package sorted by
" 	1) height of package's hierarchy and
" 	2) literal order
"
" For example:
" 'com.mycompany'
" 'com.mycompany.zoo'
" 'com.mycompany.xyz'
" 'com.mycompany.jdbc.pooling'
function! <SID>CmdCompleteListPackage(argLead, cmdLine, cursorPos)
	let currentCmdArgs = split(a:cmdLine, '\s\+')
	if currentCmdArgs[0] == "MvnNewMainFile"
		let rootOfSource = maven#getMavenProjectRoot(bufnr("%")) . "/src/main/"
	endif
	if currentCmdArgs[0] == "MvnNewTestFile"
		let rootOfSource = maven#getMavenProjectRoot(bufnr("%")) . "/src/test/"
	endif

	" ==================================================
	" Auto-complete the prefix diretories under '/src/{source_type}/*/'
	" ==================================================
	let prefixOption = s:ProcessOptionsForEditNewFile([a:argLead])
	if prefixOption["prefixDef"] != ""
		return s:GetAutoCompleteOfPrefix(rootOfSource, prefixOption)
	endif
	" //:~)

	let prefixOption = s:ProcessOptionsForEditNewFile(currentCmdArgs[1:])

	" ==================================================
	" At the last option, nothing completed
	" ==================================================
	if len(currentCmdArgs) > 3
		return ""
	elseif len(currentCmdArgs) == 3 && prefixOption["prefixDef"] == "" && a:argLead == ""
		return ""
	endif
	" //:~)

	" ==================================================
	" Extract the start directory of auto-complete
	" ==================================================
	let entryDirOfAutoComplete = prefixOption["prefixValue"] != ""  ?
		\ prefixOption["prefixValue"] :
		\ fnamemodify(bufname("%"), ":e")
	" //:~)

	let heading = rootOfSource . entryDirOfAutoComplete . "/"
	let dirsInSrc = split(glob(heading . "**/"), "\n")

	if len(dirsInSrc) == 0
		" Nothing in source directory, give general suffix of domain name
		return "com.\norg.\nidv."
		" //:~)
	endif

	" ==================================================
	" Convert the directories of family to package names
	" ==================================================
	let packages = []
	for dirOfPackage in dirsInSrc
		let packageName = substitute(dirOfPackage, heading, '', '') " Trim heading paths
		let packageName = substitute(packageName, '/', '.', 'g') " Convert the path to format of package
		call add(packages, packageName)
	endfor
	call sort(packages, "s:SortPackageName")
	" //:~)

	return join(packages, "\n")
endfunction
function! <SID>GetAutoCompleteOfPrefix(rootDir, prefixOption)
	let prefixGlob = a:prefixOption["prefixValue"] == "" ? "*/" : a:prefixOption["prefixValue"] . "*/"
	let prefixDirectories = split(glob(a:rootDir . prefixGlob), "\n")

	" ==================================================
	" Trim the root directory of source
	" ==================================================
	let i = 0
	while i < len(prefixDirectories)
		let prefixDirectories[i] = a:prefixOption["prefixDef"] . substitute(prefixDirectories[i], a:rootDir, '', '')
		let prefixDirectories[i] = substitute(prefixDirectories[i], '/$', '', '') " Trim the last '/'(slash)
		let i += 1
	endwhile
	" //:~)

	return join(prefixDirectories, "\n")
endfunction
" Sort name of packages by height of hierarachy and literal name
function! <SID>SortPackageName(leftPackage, rightPackage)
	let heightOfLeftPackage = strlen(substitute(a:leftPackage, '[^.]', '', 'g'))
	let heightOfRightPackage = strlen(substitute(a:rightPackage, '[^.]', '', 'g'))

	" Compare the height of packages' hierarchy
	if heightOfLeftPackage > heightOfRightPackage
		return 1
	elseif heightOfLeftPackage < heightOfRightPackage
		return -1
	endif
	" //:~)

	" Compare the packages' name literally
	if a:leftPackage > a:rightPackage
		return 1
	elseif a:leftPackage < a:rightPackage
		return -1
	endif
	" //:~)

	return 0
endfunction

function! <SID>EditNewFile(args, sourceCategory)
	if !maven#isBufferUnderMavenProject(bufnr("%"))
		throw "Current buffer is not under Maven project"
	endif

	let cmdOptions = split(a:args, '\s\+')
	if len(cmdOptions) < 2
		throw "Needs [-prefix={prefix}] <package> <filename>"
	endif

	" ==================================================
	" Prepare prefix directory
	" ==================================================
	let prefixOption = s:ProcessOptionsForEditNewFile(cmdOptions)
	if prefixOption["prefixDef"] == ""
		let prefix = fnamemodify(cmdOptions[1], ":e")
		let targetPackage = cmdOptions[0]
		let targetFileName = cmdOptions[1]
	else
		let prefix = prefixOption["prefixValue"]
		let targetPackage = cmdOptions[1]
		let targetFileName = cmdOptions[2]
	endif
	" //:~)

	" Prepare the full path name of new file
	let fileFullPath = maven#getMavenProjectRoot(bufnr("%")) . '/src/' . a:sourceCategory . '/'
		\ . prefix . "/"
		\ . substitute(targetPackage, '\.', '/', 'g') . '/'
		\ . targetFileName
	" //:~)

	" Build the tree of directory of new file
	let fileDir = fnamemodify(fileFullPath, ":p:h")
	if !isdirectory(fileDir)
		call mkdir(fileDir, "p")
	endif
	" //:~)

	execute "edit " . fileFullPath
endfunction
function! <SID>ProcessOptionsForEditNewFile(args)
	let prefixDef = ""
	let prefixValue = ""

	if len(a:args) >=1 && a:args[0] =~ '\v^-p%(refix)?\=.*$'
		let prefixContent = matchlist(a:args[0], '\v^(-p%(refix)?\=)(.*)$')
		let prefixDef = prefixContent[1]
		let prefixValue = prefixContent[2]
	endif

	return {
		\ "prefixDef" : prefixDef,
		\ "prefixValue" : prefixValue
		\ }
endfunction

function! <SID>EditTestCode(testFileName)
	let pathOfCurrentBuffer = maven#slashFnamemodify(bufname("%"), ":p:h")
	if pathOfCurrentBuffer !~ '/src/main/'
		throw "Editing test code must be under '/src/main'. Current: " . pathOfCurrentBuffer
	endif

	let pathOfTestFile = substitute(pathOfCurrentBuffer, '/src/main/', '/src/test/', '')

	if !isdirectory(pathOfTestFile)
		call mkdir(pathOfTestFile, "p")
	endif

	execute "edit " . pathOfTestFile . "/" . a:testFileName
endfunction

function! <SID>BuildSelectionOfClassName(listOfPath)
	let listOfSelection = []

	for path in a:listOfPath
		call add(listOfSelection, fnamemodify(path, ":t:r"))
	endfor
	call add(listOfSelection, "*Cancel*") " Add 'Cancel' option

	return join(listOfSelection, "\n")
endfunction

function! <SID>RunMavenCommand(args, bang)
    update

	let pomFile = s:GetPOMXMLFile(bufnr("%"))
	if pomFile == ""
		return
	endif

	" Execute Maven in console
	if a:bang == "!"
		execute "!mvn -f " . pomFile . " " . a:args

		if v:shell_error == 0
			call s:EchoMessage("Execute 'mvn " . a:args .  "' successfully.")
		else
			call s:EchoWarning("Executing 'mvn " . a:args .  "' is failed. Exit Code: " . v:shell_error)
		endif

		return
	endif
	" //:~)

	" Execute Maven by compiler framework in VIM
	execute "silent make! -f " . pomFile . " " . a:args

	" Open cwindow if the shell has error or the list of quickfix has 'Error' or 'Warning'.
	" Otherwise, close the quickfix window
	if v:shell_error != 0
		call s:OpenQuickfixWindowAndJump()
		return
	endif

	for qfentry in getqflist()
		if qfentry.type =~ '^[EW]$'
			call s:OpenQuickfixWindowAndJump()
			return
		endif
	endfor
	call s:EchoMessage("Execute 'mvn " . a:args .  "' successfully.")
	" //:~)
endfunction
function! <SID>OpenQuickfixWindowAndJump()
	copen
endfunction
function! <SID>CompleteMavenLifecycle(argLead, cmdLine, cursorPos)
	return join(['preclean', 'clean', 'postclean',
		\ 'validate', 'initialize',
		\ 'generate-sources', 'process-sources', 'generate-resources', 'process-resources', 'compile', 'process-classes',
		\ 'generate-test-sources', 'process-test-sources', 'generate-test-resources', 'process-test-resources',
		\ 'test-compile', 'process-test-classes', 'post-process', 'test',
		\ 'prepare-package', 'package',
		\ 'pre-integration-test', 'integration-test', 'post-integration-test',
		\ 'verify', 'install', 'deploy',
		\ 'pre-site', 'site', 'post-site', 'site-deploy'
	\ ], "\n")
endfunction

function! <SID>AutoChangeCurrentDirOfWindow()
	if g:maven_auto_chdir == 0
		return
	endif

	let currentBuffer = bufnr("%")

    if !maven#isBufferUnderMavenProject(currentBuffer)
		return
	endif

    execute "lcd " . maven#getMavenProjectRoot(currentBuffer)
endfunction
function! <SID>GetPOMXMLFile(buf)
	if !s:CheckFileInMavenProject(a:buf)
		return
	endif

	return maven#getMavenProjectRoot(a:buf) . "/pom.xml"
endfunction
function! <SID>CheckFileInMavenProject(buf)
	if !maven#isBufferUnderMavenProject(a:buf)
		call s:EchoWarning("File doesn't exist in Maven project")
		return 0
	endif

	return 1
endfunction

" Because the path in message output by Maven has '/<fullpath>' in windows
" system, this function would adapt the path for correct path of jump voer
" quickfix
function! <SID>ProcessQuickFixForMaven()
	let qflist = getqflist()

	for qfentry in qflist
		" Get the file comes from VIM's quickfix
		if has_key(qfentry, "filename")
			let filename = qfentry.filename
		elseif qfentry.bufnr > 0
			let filename = bufname(qfentry.bufnr)
		else
			let filename = ""
		endif
		" //:~)

		" Process the file name for:
		" 1. Fix wrong file name in Windows system
		" 2. Convert class name to file name for unit test
		if filename =~ '\v^\l+%(\.\l+)*\.\u\k+$' " The file name matches the pattern of full class name of Java
			call s:AdaptFilenameOfUnitTest(qfentry, filename)
		elseif qfentry.type =~ '^[EW]$' && filename =~ '\v^\f+$' " The file name matches valid file format under OS
			call s:AdaptFilenameOfError(qfentry, filename)
		endif
	endfor

	call setqflist(qflist, 'r')
endfunction

function! <SID>AdaptFilenameOfError(qfentry, rawFileName)
	" Fix the file path in Windows system
	"
	" In Windows system, the 'D:\folder\ClassName.java' would be
	" '/folder/ClassName.java' in output of Maven's compiler plugin
	if has("win32") && a:rawFileName !~ '\v^[a-zA-Z]:'
		let fullClassName = strpart(fnamemodify(bufname("%"), ":p"), 0, 2) . a:rawFileName

		let a:qfentry.filename = strpart(fnamemodify(bufname("%"), ":p"), 0, 2) . maven#slashFnamemodify(a:rawFileName, ':.')
		unlet a:qfentry.bufnr
	endif
	" //:~)
endfunction
function! <SID>AdaptFilenameOfUnitTest(qfentry, fullClassName)
	" Convert the full name of class to full path of file
	let filename = substitute(a:fullClassName, '\.', '/', 'g')
	let listOfTestFiles = split(glob(maven#getMavenProjectRoot(bufnr("%")) . '/src/test/**/' . filename . ".*"), "\n")

	if len(listOfTestFiles) == 0
		let a:qfentry.filename "<Can't Find File for " . a:fullClassName . ">"
	else
		let a:qfentry.filename = listOfTestFiles[0]
	endif
	unlet a:qfentry.bufnr
	" //:~)

	" Adjust the search string
	let a:qfentry.pattern = substitute(a:qfentry.pattern, '^\^\\V', '', '') " Remove the heading '^\V'
	let a:qfentry.pattern = substitute(a:qfentry.pattern, '\\\$$', '', '') " Remove the tailing '\$'
	let a:qfentry.pattern = '\<' . a:qfentry.pattern . '\>' " Add wrap of a word
	" //:~)

	let a:qfentry.type = "E"
endfunction

" Functions for echoing messages {{{

function! <SID>EchoMessage(msg)
	echohl MoreMsg
	echomsg a:msg
	echohl None
endfunction
function! <SID>EchoWarning(msg)
	echohl WarningMsg
	echomsg a:msg
	echohl None
endfunction

" }}}
