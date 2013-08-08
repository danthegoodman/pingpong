fs = require 'fs'
spawn = require('child_process').spawn

option '-v', '--verbose', 'Print out mongo db print statements'

dbpath = 'dbdata'
client_src = 'client'
style_src = 'style'
out_dir = 'public/out'

# ------ Tasks ------ #

task 'compile', 'Compile all client files', (options) ->
	doCompile watch: false

task 'watch', 'Watch and compile all files as needed', (options) ->
	doCompile watch: true

task 'serve', 'Serve the output under the development environment', (options) ->
	process.env.NODE_ENV = 'development'
	require('./app')

# ------ Internal Commands ------ #
doCompile = (opts) ->
	cFlags = if opts.watch then '-wc' else '-c'
	dirs = []
	files = []

	for f in fs.readdirSync(client_src)
		if f.indexOf('.') is -1
			dirs.push ["#{out_dir}/#{f}.js", "#{client_src}/#{f}"]
		else
			files.push "#{client_src}/#{f}"

	run "coffee -o #{out_dir} #{cFlags} #{files.join(' ')}"

	for d in dirs
		run "coffee -j #{d[0]} #{cFlags} #{d[1]}"

	for sf in fs.readdirSync(style_src)
		doLessCompile(sf, opts.watch)

doLessCompile = (file, watch) ->
	inFile = "#{style_src}/#{file}"
	outFile = "#{out_dir}/"+file.slice(0, -5)+".css"
	CMD = "lessc #{inFile} #{outFile}"
	if watch
		run CMD, {exit: "lessc: Compiled #{outFile}"}
		fs.watch inFile, (event)->
			run CMD, {exit: "lessc: Compiled #{outFile}"}
	else
		run CMD

openProcesses = 0;
run = (command, options = {}) ->
	cmd = command.split(' ')
	proc = spawn(cmd[0], cmd[1...cmd.length])
	printer = (buf) -> console.log buf.toString('utf8', 0, buf.length-1)
	proc.stdout.on('data', printer) unless options?.quiet
	proc.stderr.on('data', printer)

	openProcesses += 1

	proc.on 'exit', ->
		console.log options.exit if options?.exit
		openProcesses -= 1
		process.exit(0) if openProcesses is 0

	process.stdin.resume() # Prevent SIGINT from terminating proc.
	process.on 'SIGINT', -> # Catch the CTRL-C termination
		proc.kill()