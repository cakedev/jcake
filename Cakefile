fs = require "fs"
cp = require "child_process"

coffee_dir = "coffee"
sass_dir = "sass"
dev_dir = "lib/dev"
prod_dir = "lib/prod"

files_to_compile = [
  "main"
  "combo",
  "tabs",
  "slideshow",
  "tooltip",
  "table",
  "panel",
  "init"
]

isFn = (fn, createEmpty) ->
  isIt = typeof fn is "function"

  if createEmpty
    return if isIt then fn else new Function()
  else
    return isIt

log = (message) ->
  console.log message

module_exists = (name) ->
  exists = yes

  try
    require.resolve name
  catch ex
    exists = no

  return exists

create_directory = (path) ->
  dirs = path.split "/"
  current_dir = ""

  for dir in dirs
    current_dir += "#{dir}/"

    continue if not current_dir.length or current_dir is "/"

    try
      fs.mkdirSync current_dir
      log "#{current_dir} created"
    catch ex
      if not ex.code is "EEXIST"
        throw ex

save_file = (path, content, doneFn) ->
  fs.writeFile(path, content, (err) ->
    if err?
      log err
      throw err

    isFn(doneFn, yes)()
  )

verify_directories = ->
  create_directory dev_dir
  create_directory prod_dir

exec = (command, doneFn) ->
  cp.exec command, (err, stdout, stderr) ->
    if err?
      log stdout + stderr
      throw err if err

    isFn(doneFn, yes)()

compress_js = (doneFn) ->
  if module_exists "uglify-js"
    uglifier = require "uglify-js"
    save_file "#{prod_dir}/jcake.js", uglifier.minify("#{dev_dir}/jcake.js").code, doneFn
  else
    log "UglifyJS wasn't found. JavaScript code won't be compressed."

    rs = fs.createReadStream "#{dev_dir}/jcake.js"
    ws = fs.createWriteStream "#{prod_dir}/jcake.js"

    rs.pipe ws

    isFn(doneFn, yes)()

compile_coffee = (doneFn) ->
  exec(
    "coffee -j #{dev_dir}/jcake.js  -c #{coffee_dir}/#{files_to_compile.join('.coffee ' + coffee_dir + '/')}.coffee",
    doneFn
  )

compile_sass = (doneFn) ->
  exec(
    "sass #{sass_dir}/jcake.scss #{dev_dir}/jcake.css",
    doneFn
  )

compile_compress_coffee = (doneFn) ->
  compile_coffee ->
    compress_js ->
      isFn(doneFn, yes)()

compile_compress_sass = (doneFn) ->
  compile_sass()
  exec(
    "sass --style compressed #{sass_dir}/jcake.scss #{prod_dir}/jcake.css",
    doneFn
  )

compile = ->
  compile_coffee()
  compile_sass()

watch_coffee = ->
  exec "coffee -w -j #{dev_dir}/jcake.js  -c #{coffee_dir}/#{files_to_compile.join('.coffee ' + coffee_dir + '/')}.coffee"
  log "Watching for changes on coffee files..."

watch_sass = ->
  exec "sass --watch #{sass_dir}/jcake.scss:#{dev_dir}/jcake.css"
  log "Watching for changes on sass files..."

watch = ->
  watch_coffee()
  watch_sass()

task("watch", "Watch for changes to compile (development)", ->
  verify_directories()
  watch()
)

task("compile:dev", "Compile for development", ->
  verify_directories()
  compile()
)

task("compile:prod", "Compile for production", ->
  verify_directories()
  compile_compress_coffee()
  compile_compress_sass()
)
