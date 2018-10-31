if exists('g:loaded_maven_android') && !exists('g:reload_maven_android')
    finish
endif

if exists("g:reload_maven_android")
	autocmd! MavenAndroidAutoDetect
endif

let g:loaded_maven_android = 1

runtime plugin/maven.vim

augroup MavenAndroidAutoDetect
	au!
	autocmd BufNewFile,BufReadPost *.* call s:SetupAndroidEnv()
augroup END

" Setup the path for Android development
function! <SID>SetupAndroidEnv()
	let currentBuffer = bufnr("%")

    if !maven#isBufferUnderMavenProject(currentBuffer)
        return
    endif

	let projectRoot = maven#getMavenProjectRoot(currentBuffer)
	if filereadable(projectRoot . "/AndroidManifest.xml")
		call setbufvar(currentBuffer, "&path", projectRoot . "/res/**," . &path)
	endif
endfunction
