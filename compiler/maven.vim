if exists("current_compiler")
	finish
endif

let current_compiler = "maven"

CompilerSet makeprg=mvn\ -B\ $*

" The errorformat for recognize following errors
" 1. Error due to POM file
" 2. Compliation error
" 	2.1. Ignore the lines after '[INFO] BUILD FAILURE' because the error message of
" 		compiler has been perceived before it.
" 3. Warning
" 4. Errors for unit test
"
" See file content of "maven-output.log"
"
" Tested versions of Maven
"
" Maven Version: 3.5.X~
" http://maven.apache.org/
"
" Compiler Plugin Version: 3.8.0
" http://maven.apache.org/plugins/maven-compiler-plugin/
"
" Surefire Plugin Version: 2.20.0
" http://maven.apache.org/plugins/maven-surefire-plugin/

" See maven-output.txt for debug and enhance errorformat

" Ignored message
CompilerSet errorformat=
	\%-G[INFO]\ %.%#,
	\%-G[debug]\ %.%#

" Error message for POM
CompilerSet errorformat+=
	\[FATAL]\ Non-parseable\ POM\ %f:\ %m%\\s%\\+@%.%#line\ %l\\,\ column\ %c%.%#,
	\[%tRROR]\ Malformed\ POM\ %f:\ %m%\\s%\\+@%.%#line\ %l\\,\ column\ %c%.%#

" Error message for compiling
CompilerSet errorformat+=
	\[%tARNING]\ %f:[%l\\,%c]\ %m,
	\[%tRROR]\ %f:[%l\\,%c]\ %m

" Message from JUnit 5(5.3.X), TestNG(6.14.X), JMockit(1.43), and AssertJ(3.11.X)
CompilerSet errorformat+=
	\%+E%>[ERROR]\ %.%\\+Time\ elapsed:%.%\\+<<<\ FAILURE!,
	\%+E%>[ERROR]\ %.%\\+Time\ elapsed:%.%\\+<<<\ ERROR!,
	\%+Z%\\s%#at\ %f(%\\f%\\+:%l),
	\%+C%.%#
