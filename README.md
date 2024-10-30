# vim-maven-plugin
This plugin provides convenient functions to Apache Maven project.

See [doc/maven.txt](doc/maven.txt) for example of mappings.

## Limitations

* **This plugin wouldn't read the content of `pom.xml` to setup the context of Maven project.
So you should setup directories of source code in your project by default.**

## Main features:
1. Detects your editing file if it is under Maven's project(by looking for pom.xml)
1. Executes Maven as compiler with supporting of quickfix
1. Jump files between source/test code
1. Functions for retrieving maven path in current editing buffer

## Installation:

### [VimPlugin](https://github.com/junegunn/vim-plug)(Recommended)
Put following configuration to your vim-plug block of vimrc:

```vim
Plug 'mikelue/vim-maven-plugin'
```

Restart VIM and execute `:PlugInstall`

### [Vundle](https://github.com/VundleVim/Vundle.vim)
Put following configuration to your vundle block of vimrc:

```vim
Plugin 'mikelue/vim-maven-plugin'
```

Restart VIM and execute `:PluginInstall`

Please check out the documentations of your favorite plugin.

### Manually
Get the source and copy the source into your runtime path of VIM.
Then type `helptags ~/vimfiles/doc/` to build tags of help file.

Use `help maven.txt` to open the help of this plugin.

# Brief

## Project environment

* Setting of `'path'` option of VIM automatically, to make `:find`, `:sfind` working in your `src/`.
* Auto-appending options for Maven by buffer-scoped: `b:maven_cli_options`.
* Controlling changing working directory automatically by `g:maven_auto_chdir`.

## Command mode

By `:Mvn <command>`, you can execute Maven command and open quickfix-window.

e.g.,
* `:Mvn compile`  Execute the 'compile' phase of Maven
* `:Mvn! compile` Execute the 'compile' phase of Maven with opening shell window

## Mappings

* With `<Plug>MavenRunUnittest`, you can set-up your own shortcut to run test of current file.
* With `<Plugn>MavenSwitchUnittestFile`, you can set-up your own shortcut to switch files between `main/java/Something.java` and `src/main/java/SomethingTest.java`.
* Theses mappings are supported in normal mode and insertion mode.

See _"1.7. Suggestions of keystrokes"_ of [doc/maven.txt](doc/maven.txt) for example of mappings.

## APIs(VIM functions)

* With `maven#getMavenProjectRoot(buf)`, you can get the root directory(by looking for `pom.xml`) of current file.
* With `maven#getListOfPaths(buf)`, you can get list of `/src/main/java`, `src/test/java`, etc., to get search paths of source.
* With `maven#getCandidateClassNameOfTest(className)`, you can get candidate class name for tests.
	* e.g. Converts `Something` a list of names: `["SomethingTest", "SomethingTestCase", "SomethingIT", "TestSomething"]`

## Quckfix window

With setting of `'errorformat'`, quickfix can show some kinds of errors output by Maven provided by this plugin.

* Error of POM.xml:
	```
	The project idv.mikelue:sandbox-java:1.0-SNAPSHOT (D:\Code\sandbox-java\pom.xml) has 1 error
	sandbox-java/pom.xml|10 col 8 error| Unrecognised tag: 'data' (position: START_TAG seen ...</parent>\r\n\r\n\t<data>... @10:8)
	```
* Failure of Unit Test(JUnit or TestNG): >
	```
	-------------------------------------------------------
	 T E S T S
	-------------------------------------------------------
	Running idv.mikelue.RegionAndInheritancePerformanceTest
	Configuring TestNG with: TestNG652Configurator
	Tests run: 13, Failures: 3, Errors: 0, Skipped: 0, Time elapsed: 0.656 sec <<< FAILURE!
		src/test/java/idv/mikelue/RegionAndInheritancePerformanceTest.java|\<do1\>|  expected [3] but found [1]    at org.testng.Assert.fail(Assert.java:94)
	     at org.testng.Assert.failNotEquals(Assert.java:494)
	     at org.testng.Assert.assertEquals(Assert.java:123)
	     at org.testng.Assert.assertEquals(Assert.java:370)
	     at org.testng.Assert.assertEquals(Assert.java:380)
	     at idv.mikelue.RegionAndInheritancePerformanceTest.do1(RegionAndInheritancePerformanceTest.java:25)
	```

So that you can set-up your own by `CompilerSet errorformat=`.

## LICENSE

see [VIM LICENSE](./LICENSE)
