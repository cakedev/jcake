###
jCaKeDev 1.0
cakedevp.github.com/jcakedev
###

cake =
  _init: ($) ->
    $.fn.cake = (plugin, action, params) ->
      if @length
        if plugin?
          if cake[plugin]?
            cake[plugin].invoke.call @, action, params
          else
            console.log "plugin definition not found for '#{plugin}'"
        else
          console.log "plugin name not specified"
    null

if jQuery?
  cake._init jQuery
else
  console.log "jQuery not found"
