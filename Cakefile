fs = require "fs"
cp = require "child_process"

version = "1.1.0"

coffee_dir = "coffee"
stylus_dir = "stylus"
dev_dir = "dist/dev"
prod_dir = "dist/prod"

target_dev = "dev"
target_prod = "prod"

default_target = target_dev

files_to_compile = [
  "main"
  "combo",
  "tabs",
  "slideshow",
  "tooltip",
  "table",
  "panel"
]

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

save_file = (path, content, done_fn) ->
  fs.writeFile(path, content, (err) ->
    if err?
      log err
      throw err

    done_fn?()
  )

copy_file = (from, to, done_fn) ->
  rs = fs.createReadStream from
  ws = fs.createWriteStream to

  rs.pipe ws
  rs.on "end", ->
    done_fn?()

verify_directories = ->
  create_directory dev_dir
  create_directory prod_dir

exec = (command, done_fn) ->
  process = cp.exec command, (err, stdout, stderr) ->
    if err?
      log stdout + stderr
      throw err

    done_fn?()

  process.stdout.on "data", (data) ->
    log data.toString()

compress_js = (done_fn) ->
  if module_exists "uglify-js"
    uglifier = require "uglify-js"
    content = "// jcake #{version}\n" + uglifier.minify("#{dev_dir}/jcake.js").code

    save_file "#{prod_dir}/jcake.js", content, done_fn
  else
    log "UglifyJS wasn't found. Development version will be used instead."

    copy_file "#{dev_dir}/jcake.js", "#{prod_dir}/jcake.js", done_fn

compile_coffee = (done_fn) ->
  exec(
    "coffee -j #{dev_dir}/jcake.js -c #{coffee_dir}/#{files_to_compile.join('.coffee ' + coffee_dir + '/')}.coffee",
    done_fn
  )

compile_stylus = (done_fn) ->
  exec(
    "stylus #{stylus_dir}/jcake.styl -o #{dev_dir}",
    done_fn
  )

compile_compress_coffee = (done_fn) ->
  compile_coffee ->
    compress_js ->
      done_fn?()

compile_compress_stylus = (done_fn) ->
  compile_stylus()
  exec(
    "stylus -c #{stylus_dir}/jcake.styl -o #{prod_dir}",
    done_fn
  )

compile_compress = ->
  compile_compress_coffee()
  compile_compress_stylus()

compile = ->
  compile_coffee()
  compile_stylus()

watch_coffee = ->
  exec "coffee -w -j #{dev_dir}/jcake.js  -c #{coffee_dir}/#{files_to_compile.join('.coffee ' + coffee_dir + '/')}.coffee"
  log "Watching for changes on coffee files..."

watch_stylus = ->
  exec "stylus -w #{stylus_dir}/jcake.styl -o #{dev_dir}"
  log "Watching for changes on stylus files..."

watch = ->
  watch_coffee()
  watch_stylus()

# TASKS

option "-t", "--target [TARGET]", "Sets the compilation target. Production 'prod' or development 'dev'."

task "watch", "Watch for changes to compile (for development).", ->
  verify_directories()
  watch()

task "compile", "Compile both coffee and stylus files. You can specify the target (-t) for this task.", (params) ->
  verify_directories()

  target = params.target or default_target

  if target is target_prod
    compile_compress()
  else if target is target_dev
    compile()
  else
    log "Invalid target"
