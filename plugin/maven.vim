if exists('g:loaded_maven')
	if !exists('g:reload_maven')
		finish
	endif

	unmenu Plugin.maven

	nunmap <Plug>MavenRunUnittest
	iunmap <Plug>MavenRunUnittest
	nunmap <Plug>MavenRunUnittestAll
	iunmap <Plug>MavenRunUnittestAll
	nunmap <Plug>MavenSwitchUnittestFile
	iunmap <Plug>MavenSwitchUnittestFile
	iunmap <Plug>MavenOpenTestResult
	nunmap <Plug>MavenOpenTestResult

	augroup MavenAutoDetect
		au!
	augroup END
	augroup! MavenAutoDetect
endif

let g:loaded_maven = 1

" Global settings {{{
if !exists("g:maven_auto_set_path")
	let g:maven_auto_set_path = 1
endif
if !exists("g:maven_auto_chdir")
	let g:maven_auto_chdir = 0
endif
if !exists("g:maven_keymaps")
	let g:maven_keymaps = 0
endif
if !exists("g:maven_detect_root")
  let g:maven_detect_root = 1
endif
" }}}

" Maps {{{
if g:maven_keymaps
	nnoremap <silent> <unique> <Plug>MavenRunUnittest :Mvn test -Dtest=%:t:r -DfailIfNoTests=false --offline<CR>
	inoremap <silent> <unique> <Plug>MavenRunUnittest <C-O>:Mvn test -Dtest=%:t:r -DfailIfNoTests=false --offline<CR>
	nnoremap <silent> <unique> <Plug>MavenRunUnittestAll :Mvn test -DfailIfNoTests=true<CR>
	inoremap <silent> <unique> <Plug>MavenRunUnittestAll <C-O>:Mvn test -DfailIfNoTests=true<CR>

	nnoremap <silent> <unique> <Plug>MavenSwitchUnittestFile :call <SID>SwitchUnitTest()<CR>
	inoremap <silent> <unique> <Plug>MavenSwitchUnittestFile <C-O>:call <SID>SwitchUnitTest()<CR>
	nnoremap <silent> <unique> <Plug>MavenOpenTestResult :call <SID>OpenTestResult()<CR>
	inoremap <silent> <unique> <Plug>MavenOpenTestResult <C-O>:call <SID>OpenTestResult()<CR>
endif
" }}}

" Autocmds {{{
augroup MavenAutoDetect
	autocmd BufNewFile,BufReadPost *.* call s:SetupMavenEnv()
	autocmd BufWinEnter *.* call s:AutoChangeCurrentDirOfWindow()
	autocmd QuickFixCmdPost make call s:ProcessQuickFixForMaven(getqflist())
augroup END
" }}}

" Commands {{{
command! -bang -nargs=+ -complete=custom,s:CompleteMavenLifecycle Mvn call s:RunMavenCommand(<q-args>, expand("<bang>"))
command! -nargs=1 -complete=customlist,s:ListCandidatesOfTest MvnEditTestCode call s:EditTestCode(<q-args>)
command! -nargs=+ -complete=custom,s:CmdCompleteListPackage MvnNewMainFile call s:EditNewFile("main", <f-args>)
command! -nargs=+ -complete=custom,s:CmdCompleteListPackage MvnNewTestFile call s:EditNewFile("test", <f-args>)
" }}}

" Menu {{{
if g:maven_keymaps
	menu <silent> Plugin.maven.Run\ File\ UnitTest<Tab><F5> <Plug>MavenRunUnittest
	menu <silent> Plugin.maven.Run\ UnitTest<Tab><Ctrl-F5> <Plug>MavenRunUnittestAll
	menu <silent> Plugin.maven.Switch\ Unit\ Test\ File<Tab><F6> <Plug>MavenSwitchUnittestFile
	menu <silent> Plugin.maven.Open\ Unit\ Test\ Result<Tab><Ctrl-F6> <Plug>MavenOpenTestResult
	imenu <silent> Plugin.maven.Run\ File\ UnitTest<Tab><F5> <Plug>MavenRunUnittest
	imenu <silent> Plugin.maven.Run\ UnitTest<Tab><Ctrl-F5> <Plug>MavenRunUnittestAll
	imenu <silent> Plugin.maven.Switch\ Unit\ Test\ File<Tab><F6> <Plug>MavenSwitchUnittestFile
	imenu <silent> Plugin.maven.Open\ Unit\ Test\ Result<Tab><Ctrl-F6> <Plug>MavenOpenTestResult
endif

menu <silent> Plugin.maven.Phrase.Clean.pre-clean :Mvn pre-clean<CR>
menu <silent> Plugin.maven.Phrase.Clean.clean :Mvn clean<CR>
menu <silent> Plugin.maven.Phrase.Clean.post-clean :Mvn post-clean<CR>

menu <silent> Plugin.maven.Phrase.Default.validate :Mvn validate<CR>
menu <silent> Plugin.maven.Phrase.Default.initialize :Mvn initialize<CR>
menu <silent> Plugin.maven.Phrase.Default.generate-sources :Mvn generate-sources<CR>
menu <silent> Plugin.maven.Phrase.Default.process-sources :Mvn process-sources<CR>
menu <silent> Plugin.maven.Phrase.Default.generate-resources :Mvn generate-resources<CR>
menu <silent> Plugin.maven.Phrase.Default.process-resources :Mvn process-resources<CR>
menu <silent> Plugin.maven.Phrase.Default.compile :Mvn compile<CR>
menu <silent> Plugin.maven.Phrase.Default.process-classes :Mvn process-classes<CR>
menu <silent> Plugin.maven.Phrase.Default.generate-test-sources :Mvn generate-test-sources<CR>
menu <silent> Plugin.maven.Phrase.Default.process-test-sources :Mvn process-test-sources<CR>
menu <silent> Plugin.maven.Phrase.Default.generate-test-resources :Mvn generate-test-resources<CR>
menu <silent> Plugin.maven.Phrase.Default.process-test-resources :Mvn process-test-resources<CR>
menu <silent> Plugin.maven.Phrase.Default.test-compile :Mvn test-compile<CR>
menu <silent> Plugin.maven.Phrase.Default.process-test-classes :Mvn process-test-classes<CR>
menu <silent> Plugin.maven.Phrase.Default.post-process :Mvn post-process<CR>
menu <silent> Plugin.maven.Phrase.Default.test :Mvn test<CR>
menu <silent> Plugin.maven.Phrase.Default.prepare-package :Mvn prepare-package<CR>
menu <silent> Plugin.maven.Phrase.Default.package :Mvn package<CR>
menu <silent> Plugin.maven.Phrase.Default.pre-integration-test :Mvn pre-integration-test<CR>
menu <silent> Plugin.maven.Phrase.Default.integration-test :Mvn integration-test<CR>
menu <silent> Plugin.maven.Phrase.Default.post-integration-test :Mvn post-integration-test<CR>
menu <silent> Plugin.maven.Phrase.Default.verify :Mvn verify<CR>
menu <silent> Plugin.maven.Phrase.Default.install :Mvn install<CR>
menu <silent> Plugin.maven.Phrase.Default.deploy :Mvn deploy<CR>

menu <silent> Plugin.maven.Phrase.Site.pre-site :Mvn pre-site<CR>
menu <silent> Plugin.maven.Phrase.Site.site :Mvn site<CR>
menu <silent> Plugin.maven.Phrase.Site.post-site :Mvn post-site<CR>
menu <silent> Plugin.maven.Phrase.Site.site-deploy :Mvn site-deploy<CR>
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
		let l:mavenPaths = maven#getListOfPaths(currentBuffer)

		if !exists("b:mvn_backup_path")
			let b:mvn_backup_path = &path
		else
			execute "setlocal path=" . b:mvn_backup_path
		endif

		let l:reversedPaths = reverse(copy(mavenPaths))
		for mavenPath in reversedPaths
			execute "setlocal path^=" . mavenPath
		endfor
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
			execute "pedit " . targetFileName
		endif
		return
	endif

	call s:EchoWarning("File not exists:" . targetFileName)
endfunction
function! <SID>SwitchUnitTest()
	let projectRoot = maven#getMavenProjectRoot(bufnr("%"))

	" ==================================================
	" Jump back to the file of test code from the result file of test
	" ==================================================
	let testFileByReport = s:LoadTestFileByReportFile(projectRoot, fnamemodify(bufname("%"), ":t"))
	if testFileByReport != ""
		execute "edit " . testFileByReport
		return
	endif
	" //:~)

	update
	let currentBuf = bufnr("%")

	if !s:CheckFileInMavenProject(currentBuf)
		return
	endif

	" ==================================================
	" Recognize the what file type is(source/unit test)
	" ==================================================
	let classNameOfBuf = maven#slashFnamemodify(bufname(currentBuf), ":t:r")
	let fileDir = maven#slashFnamemodify(bufname(currentBuf), ":p:h")
	let fileExtension = maven#slashFnamemodify(bufname(currentBuf), ":e")

	if fileDir !~ '/src/'
		call s:EchoWarning("Can't recognize file of code: " . maven#slashFnamemodify(bufname(currentBuf), ":t"))
		return
	endif
	" //:~)

	" ==================================================
	" Compose the corresponding file name
	" ==================================================
	let listOfExistingCandidates = []
	let listOfNewCandidates = []

	if fileDir =~ 'src/main'
		let targetFilePath = s:ConvertToFilePathForTest(projectRoot, classNameOfBuf, fileDir, fileExtension)
	else
		let targetFilePath = s:ConvertToFilePathForSource(classNameOfBuf, fileDir, fileExtension)
	endif

	if targetFilePath == ""
		return
	endif
	" //:~)

	" ==================================================
	" Ask whether to edit a new file if the file doesn't exist
	" ==================================================
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

function! <SID>LoadTestFileByReportFile(projectRoot, filename)
	" ==================================================
	" Jump back to the file of test code from the result file of test
	" ==================================================
	if a:filename !~ '^TEST-.\+\.xml$'
		return
	endif

	let testFilePattern = matchstr(a:filename, '^TEST-\zs.\+\ze\.xml$')
	let testFilePattern = substitute(testFilePattern, '\.', '/', 'g') . '.*'

	let resultFiles = glob(a:projectRoot . "/src/*/*/" . testFilePattern, 1, 1)
	if len(resultFiles) == 0
		throw "Can't find the file of test code for: " . testFilePattern
	endif

	return resultFiles[0]
	" //:~)
endfunction
function! <SID>ConvertToFilePathForTest(projectRoot, sourceClassName, fileDir, fileExtension)
	let subFoldersOfTest = filter(glob(a:projectRoot . "/src/*", 1, 1), 'v:val =~ "\\v\\c/src/.*(test|it).*$"')

	" ==================================================
	" Test file of default --> src/test/<package>/<class>Test.java
	" ==================================================
	if len(subFoldersOfTest) == 0
		return printf("%s/%sTest.%s", substitute(a:fileDir, 'src/main', 'src/test', ''), a:sourceClassName, a:fileExtension)
	endif
	" //:~)

	" List candidate files of test(see Surefire/Failsafe by default)
	let listOfCandidates = maven#getCandidateClassNameOfTest(a:sourceClassName)

	" ==================================================
	" Searchs existing testing file corresponding to classname
	" ==================================================
	let listOfExistingCandidates = []
	for subFolder in subFoldersOfTest
		for candidate in listOfCandidates
			let checkedFilePath = printf("%s/%s.%s",
				\ substitute(a:fileDir, 'src/main', 'src/' . fnamemodify(subFolder, ":t:r"), ''),
				\ candidate, a:fileExtension
			\ )

			if filereadable(checkedFilePath)
				call add(listOfExistingCandidates, checkedFilePath)
			endif
		endfor
	endfor
	" //:~)

	" ==================================================
	" Asks the user to choose multiple condidates of existing test file
	" ==================================================
	let numOfExistingCandidates = len(listOfExistingCandidates)
	if numOfExistingCandidates == 1
		return listOfExistingCandidates[0]
	elseif numOfExistingCandidates > 0
		let listForInput = s:BuildListOfLastPart(listOfExistingCandidates, "Select test file:")
		let selectedIdx = inputlist(listForInput) - 1
		if selectedIdx < 0 || selectedIdx >= numOfExistingCandidates
			return
		endif

		return listOfExistingCandidates[selectedIdx]
	endif
	" //:~)

	return s:ConvertToFilePathForNewTest(subFoldersOfTest, listOfCandidates, a:fileDir, a:fileExtension)
endfunction
function! <SID>ConvertToFilePathForNewTest(subFoldersOfTest, listOfCandidates, fileDir, fileExt)
	" ==================================================
	" Asks the user to choose multiple condidates of existing test file
	" ==================================================
	let numOfTestFolders = len(a:subFoldersOfTest)
	if numOfTestFolders == 1
		let targetFolder = a:subFoldersOfTest[0]
	elseif numOfTestFolders > 1
		let listForInput = s:BuildListOfLastPart(a:subFoldersOfTest, "Choose sub-folder under src/*:")
		let selectedIdx = inputlist(listForInput) - 1
		if selectedIdx < 0 || selectedIdx >= numOfTestFolders
			return
		endif

		let targetFolder = a:subFoldersOfTest[selectedIdx]
	endif
	" //:~)

	let pathOfTestFile = substitute(a:fileDir, '/src/main/', printf("/src/%s/", fnamemodify(targetFolder, ":t:r")), '')
	let listForInput = s:BuildListOfLastPart(a:listOfCandidates, printf("Edit a new test file(@src/%s:", targetFolder))
	let selectedIdx = inputlist(listForInput) - 1
	if selectedIdx < 0 || selectedIdx >= len(a:listOfCandidates)
		return
	endif

	return printf("%s/%s.%s", pathOfTestFile, a:listOfCandidates[selectedIdx], a:fileExt)
	" //:~)

endfunction
function! <SID>ConvertToFilePathForSource(testClassName, fileDir, fileExtension)
	let fileDir = substitute(a:fileDir, '.*\zs/src/[^/]\+/', '/src/main/', '')
	let matchedFilenames = []

	" Convert the class name of test code to class name of source code
	for matchPattern in s:BuildMatchPattersForTestClass()
		if a:testClassName =~ matchPattern
			let filename = fileDir . "/" . substitute(a:testClassName, matchPattern, "", "") . "." . a:fileExtension

			if filereadable(filename)
				return filename
			endif

			call add(matchedFilenames, filename)
		endif
	endfor
	" //:~)

	" ==================================================
	" Use the shortest filename as the source name if
	" none of matched pattern has existing file
	" ==================================================
	if len(matchedFilenames) > 1
		call sort(matchedFilenames, { f1, f2 -> len(f1) - len(f2) })
	endif
	" //:~)

	if len(matchedFilenames) >= 1
		return matchFilenames[0]
	endif

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
	let dirsInSrc = glob(heading . "**/", 1, 1)

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
	let prefixDirectories = glob(a:rootDir . prefixGlob, 1, 1)

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

function! <SID>EditNewFile(category, ...)
	if !maven#isBufferUnderMavenProject(bufnr("%"))
		throw "Current buffer is not under Maven project"
	endif

	let l:editOptions = s:ProcessOptions(a:000)

	if !has_key(editOptions, "prefix")
		if has_key(editOptions, "p")
			let editOptions["prefix"] = editOptions["p"]
		else
			let editOptions["prefix"] = "java"
		endif
	endif

	if !has_key(editOptions, "package")
		let editOptions["package"] = maven#getJavaPackageOfBuffer("%")
	endif

	if !has_key(editOptions, "file_name")
		let editOptions["file_name"] = expand("%:t")
	endif
	if editOptions["file_name"] =~ '^\.\w\+$'
		let editOptions["file_name"] = expand("%:t:r") . editOptions["file_name"]
	endif

	" Prepare the full path name of new file
	let fileFullPath = printf("%s/src/%s/%s/%s/%s",
		\ maven#getMavenProjectRoot(bufnr("%")),
		\ a:category,
		\ editOptions["prefix"],
		\ substitute(editOptions["package"], '\.', '/', 'g'),
		\ editOptions["file_name"]
	\ )
	" //:~)

	" Build the tree of directory of new file
	let fileDir = fnamemodify(fileFullPath, ":p:h")
	if !isdirectory(fileDir)
		call mkdir(fileDir, "p")
	endif
	" //:~)

	execute "edit " . fileFullPath
endfunction

" Process options to dictionary
" For example:
" -o1=20 -o2=ccc a.b.c filename.json
"
" {
"	"o1" : 20,
"	"o2" : "ccc,
" 	"package" : "a.b.c",
" 	"file_name" : "filename.json"
" }
function! <SID>ProcessOptions(listOfOptions)
	let resultOptions = {}

	let unnamed = 1

	for rowOption in a:listOfOptions
		if rowOption =~ '^-\S\+=\S\+$'
			let resultOptions[matchstr(rowOption, '\v-@<=\S+\=@=')] = matchstr(rowOption, '\v\=@<=\S+')
		else
			if unnamed == 1
				let resultOptions["file_name"] = rowOption
			elseif unnamed == 2
				let resultOptions["package"] = let resultOptions["file_name"]
				let resultOptions["file_name"] = rowOption
			endif

			let unnamed += 1
		endif
	endfor

	return resultOptions
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

function! <SID>BuildListOfLastPart(listOfPath, prompt)
	let result = [a:prompt]

	let i = 1
	for path in a:listOfPath
		call add(result, printf("%d. %s", i, fnamemodify(path, ":t:r")))
		let i += 1
	endfor

	return result
endfunction

function! <SID>RunMavenCommand(args, bang)
	call s:RunMavenCommandWithQuickfixWindow(a:args, a:bang)
	call s:RedrawByNeededEnv()
endfunction
function! <SID>RunMavenCommandWithQuickfixWindow(args, bang)
	update

	let currentBuf = bufnr("%")
	if !s:CheckFileInMavenProject(currentBuf)
		return
	endif

	" ==================================================
	" Combines the various source of arguments
	" ==================================================
	let argsAsText = join(s:BuildArguments(currentBuf) + [a:args], " ")
	" //:~)

	" Execute Maven in console
	if a:bang == "!"
		execute "!mvn " . argsAsText

		if v:shell_error == 0
			call s:EchoMessage("Execute 'mvn " . argsAsText .  "' successfully.")
		else
			call s:EchoWarning("Executing 'mvn " . argsAsText .  "' is failed. Exit Code: " . v:shell_error)
		endif

		return
	endif
	" //:~)

	" Execute Maven by compiler framework in VIM
	execute "silent make! " . argsAsText

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

	call s:EchoMessage("Execute 'mvn " . argsAsText .  "' successfully.")
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
function! <SID>CheckFileInMavenProject(buf)
	if !maven#isBufferUnderMavenProject(a:buf)
		call s:EchoWarning("This buffer is Non-Mavenized.")
		return 0
	endif

	return 1
endfunction

" Because the path in message output by Maven has '/<fullpath>' in windows
" system, this function would adapt the path for correct path of jump voer
" quickfix
function! <SID>ProcessQuickFixForMaven(qflist)
	for qfentry in a:qflist
		" Get the filename coming from VIM's quickfix
		if has_key(qfentry, "filename")
			let filename = qfentry.filename
		elseif qfentry.bufnr > 0
			let filename = bufname(qfentry.bufnr)
		else
			let filename = ""
		endif
		" //:~)

		" ==================================================
		" Process the file name for:
		" 1. Fix wrong file name in Windows system
		" 2. Convert class name(<full class name>.<method name>) to file name for unit test
		" ==================================================
		"
		" The file name which comes from full class name of Java.
		" It maybe includes method name.
		if filename =~ '\v^\l+%(\.\l+)*\.\u\k+(\.\l\k+)?$' " The file name matches the pattern of full class name of Java
			call s:AdaptFilenameOfUnitTest(qfentry, filename)
			call s:RefineTextForUnitTest(qfentry)
		elseif qfentry.type =~ '^[EW]$' && filename =~ '\v^\f+$' " The file name matches valid file format under OS
			call s:AdaptFilenameOfError(qfentry, filename)
		endif
		" //:~)
	endfor

	call setqflist(a:qflist, 'r')
endfunction

function! <SID>AdaptFilenameOfError(qfentry, rawFileName)
	let rawFileName = a:rawFileName
	let shellSlash = &shellslash ? '/' : '\\'

	" ==================================================
	" Fix the /C:/source.code path generated by maven-compiler-plugin 3.0
	" ==================================================
	let headingShellSlashOfWin32 = '\v^' . shellSlash . '[a-zA-Z]:' . shellSlash
	if has("win32") && rawFileName =~ headingShellSlashOfWin32
		let a:qfentry.filename = substitute(rawFileName, '^' . shellSlash, '', '')
		unlet a:qfentry.bufnr
	endif
	" //:~)
endfunction
function! <SID>RefineTextForUnitTest(qfentry)
	let a:qfentry.text = substitute(a:qfentry.text, '\[ERROR]\s*', '', '')
	let a:qfentry.text = substitute(a:qfentry.text, '\v\s*Time elapsed:[^<]+\<\<\<\s*%(FAILURE|ERROR)!\s*', ' --> ', '')
	let a:qfentry.text = substitute(a:qfentry.text, '\n', ' ', 'g')
endfunction
function! <SID>AdaptFilenameOfUnitTest(qfentry, fullClassName)
	let filename = substitute(a:fullClassName, '\.', '/', 'g')
	let filename = substitute(filename, '\zs/\l\k\+$', '', '')

	let projectRoot = maven#getMavenProjectRoot(bufnr("%"))
	let listOfTestFiles = glob(printf("%s/src/test/**/%s.*", projectRoot, filename), 1, 1)

	if len(listOfTestFiles) == 0
		let a:qfentry.text = printf("<!! Can't find file(%s) !!> %s", filename, a:qfentry.text)
		let a:qfentry.filename = a:fullClassName
	else
		let a:qfentry.filename = listOfTestFiles[0]
		let a:qfentry.module = pathshorten(substitute(listOfTestFiles[0], printf('^%s/src/test/\w\+/', projectRoot), '', ''))
	endif
	unlet a:qfentry.bufnr
	" //:~)
endfunction

" Builds necessary arguments by:
" 1) global or buffer variable(maven_cli_options)
" 2) Checking the current folder to decide whether or not to add '-p <project_root/pom.xml>'
function! <SID>BuildArguments(buf)
	let allArgs = []

	let projectRoot = maven#getMavenProjectRoot(a:buf)
	if projectRoot != getcwd()
		let allArgs += ["-f", projectRoot . "/pom.xml"]
	endif

	let allArgs += maven#getArgsOfBuf(a:buf)

	return allArgs
endfunction

" Redraws for following situations
" 1. Vim is under TMUX.
function! <SID>RedrawByNeededEnv()
	if exists('$TMUX')
		redraw!
	endif
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
