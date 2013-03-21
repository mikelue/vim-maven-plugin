if exists("current_compiler")
	finish
endif

let current_compiler = "maven"

call setbufvar(bufnr('%'), "&makeprg", 'mvn -B $*')

" The errorformat for recognize following errors
" 1. Error due to POM file
" 2. Compliation error
" 	2.1. Ignore the lines after '[INFO] BUILD FAILURE' because the error message of
" 		compiler has been perceived before it.
" 3. Warning
" 4. Errors for unit test
"
" Tested versions of Maven
"
" Maven Version: 3.0.X~
" http://maven.apache.org/
"
" Compiler Plugin Version: 3.0
" http://maven.apache.org/plugins/maven-compiler-plugin/
"
" Surefire Plugin Version: 2.14~
" http://maven.apache.org/plugins/maven-surefire-plugin/
CompilerSet errorformat=
	\%-A[INFO]\ BUILD\ FAILURE%.%#,%-C%.%#,%-Z%.%#,
    \%-G[INFO]\ %.%#,
    \%-G[debug]\ %.%#,
	\[%tRROR]%\\s%#Malformed\ POM\ %\\f%\\+:%m@\ %f\\,\ line\ %l\\,\ column\ %c%.%#,
    \[%tRROR]\ %f:[%l\\,%c]\ %m,
    \[%tARNING]\ %f:[%l\\,%c]\ %m,
    \[%tRROR]\ %m,
    \[%tARNING]\ %m,
	\Failed\ tests:%\\s%#%s(%f):\ %m,
	\%E%>%s(%f)%.%#FAILURE!,
	\%C%>%.%#java.lang.AssertionError:\ %m,
	\%-C%>%.%#at\ %.%#Assert%.%#,
	\%Z%\\s%#at\ %[%^(]%\\+%m
