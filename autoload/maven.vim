if exists("g:autoload_maven") && !exists("g:reload_autoload_maven")
    finish
endif

let g:autoload_maven = 1

" ==================================================
" Functions for Maven information
" ==================================================
function! maven#getMavenProjectRoot(buf)
	return getbufvar(a:buf, "_mvn_project")
endfunction

function! maven#isBufferUnderMavenProject(buf)
	call maven#setupMavenProjectInfo(a:buf)
	return maven#getMavenProjectRoot(a:buf) != ""
endfunction

function! maven#getDependencyClasspath(buf)
	if !maven#isBufferUnderMavenProject(a:buf)
		throw "This buffer is not under project of Maven"
	endif

	let cmdForClasspath = "mvn -f " . maven#getMavenProjectRoot(a:buf) . "/pom.xml dependency:build-classpath"
	let outputOfMaven = split(system(cmdForClasspath), "\n")

	" ==================================================
	" Look for 'Dependencies classpath' which is used to extract the
	" classpaths
	" ==================================================
	let idxOfClasspath = 0
	while idxOfClasspath < len(outputOfMaven)
		if outputOfMaven[idxOfClasspath] =~ "Dependencies classpath"
			let idxOfClasspath += 1
			break
		endif
		let idxOfClasspath += 1
	endwhile
	" //:~)

	if idxOfClasspath >= len(outputOfMaven)
		throw "Can't extract classpaths. Output: " . join(outputOfMaven, "\n")
	endif

	return outputOfMaven[idxOfClasspath]
endfunction

function! maven#setupMavenProjectInfo(buf)
    " Skip the buffer which is not listed
	if !buflisted(a:buf)
		return
	endif
    " //:~)

	" Check the flag for having been detected
	if getbufvar(a:buf, "_mvn_detected") != ""
		return
	endif
	call setbufvar(a:buf, "_mvn_detected", 1)
	" //:~)

	" Detect the root path of Maven project
	let belongMavenPath = s:LookForMavenProjectRoot(maven#slashFnamemodify(bufname(a:buf), ":p:h"))
    if belongMavenPath == ""
        return
    endif
    " //:~)

    " Setup the root of buffer
	call s:SetProjectRootToBuffer(a:buf, belongMavenPath)
    " //:~)

    call s:SetupOutputFile(a:buf)
endfunction

function! maven#getListOfPaths(buf)
    let resultPaths = []

    if !maven#isBufferUnderMavenProject(a:buf)
        return resultPaths
    endif

    let projectRoot = maven#getMavenProjectRoot(a:buf)

    call add(resultPaths, projectRoot . "/src/main/java/**")
    call add(resultPaths, projectRoot . "/src/test/java/**")
    call add(resultPaths, projectRoot . "/src/main/resources/**")
    call add(resultPaths, projectRoot . "/src/test/resources/**")
    call add(resultPaths, projectRoot . "/src/main/webapp/**")
    call add(resultPaths, projectRoot . "/src/test/webapp/**")
    call add(resultPaths, projectRoot . "/src/main/**")
    call add(resultPaths, projectRoot . "/src/test/**")
    call add(resultPaths, projectRoot . "/target/**")
    call add(resultPaths, projectRoot)

    return resultPaths
endfunction
" // Functions for Maven information :~)

" ==================================================
" Functions for Unit Test
" ==================================================
function! maven#getCandidateClassNameOfTest(className)
	if !exists("b:func_maven_unitest_patterns")
		return maven#getDefaultCandidateClassNameOfTest(a:className)
	endif

	let FuncGetCandidates = getbufvar("%", "func_maven_unitest_patterns")
	return FuncGetCandidates(a:className)
endfunction
function! maven#getDefaultCandidateClassNameOfTest(className)
	return [
		\ a:className . "Test",
		\ a:className . "TestCase",
		\ "Test" . a:className,
		\ a:className . "IT"
	\ ]
endfunction
" // Functions for Unit Test :~)

" ==================================================
" Functions for Package Information
" ==================================================
function! maven#convertPathToJavaPackage(filename)
    let targetPath = maven#slashFnamemodify(a:filename, ":p:h")

    let pattern = '\v(^.+/src/(main|test)/\k+/)@<=.+'
    if targetPath !~ pattern
        return targetPath
    endif

    return substitute(matchstr(targetPath, pattern), '/', '.', 'g')
endfunction

function! maven#getJavaPackageOfBuffer(buf)
    if !maven#isBufferUnderMavenProject(a:buf)
        return "<Unknown>"
    endif

    return substitute(maven#getJavaClasspathOfBuffer(a:buf), '/', '.', 'g')
endfunction

function! maven#getJavaClasspathOfBuffer(buf)
    if !maven#isBufferUnderMavenProject(a:buf)
        return "<Unknown>"
    endif

	" Remodify the file name in case of different letter case of path
	let projectRoot = maven#slashFnamemodify(maven#getMavenProjectRoot(a:buf), ":p:h")
	let dirOfFile = maven#slashFnamemodify(bufname(a:buf), ":p:h")
	" //:~)

    let resultClasspath = substitute(dirOfFile, projectRoot, '', '')
    let resultClasspath = matchstr(resultClasspath, '\v(^/\k+/\k+/\k+/)@<=.+') " Remove first three heading paths

    return resultClasspath
endfunction
" // Functions for Package Information :~)

" ==================================================
" Miscelllaneous Functions
" ==================================================
function! maven#slashFnamemodify(fname, mods)
	let fnameResult = fnamemodify(a:fname, a:mods)

	if has("win32") && !&shellslash
		return substitute(fnameResult, '\\\+', '/', 'g')
	endif

	return fnameResult
endfunction
" // Miscelllaneous Functions :~)

function! <SID>LookForMavenProjectRoot(srcPath)
    let closestPomPath = findfile("pom.xml", a:srcPath . ";")
    if closestPomPath == ""
        return ""
    endif

    return maven#slashFnamemodify(closestPomPath, ":p:h")
endfunction

function! <SID>SetProjectRootToBuffer(buf, rootPath)
	call setbufvar(a:buf, "_mvn_project", a:rootPath)
endfunction

function! <SID>SetupOutputFile(targetBuf)
	let currentPath = maven#slashFnamemodify(bufname(a:targetBuf), ":p")
    if currentPath !~ '/target/'
        return
    endif

	call setbufvar(a:targetBuf, "&buftype", "nowrite")
	call setbufvar(a:targetBuf, "&modifiable", 0)
    call setbufvar(a:targetBuf, "&swapfile", 0)
endfunction
