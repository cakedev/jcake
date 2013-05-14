###
jcake
cakedevp.github.com/jcake/
###

jcake =
  plugins: {}
  components: {}

  eachPlugin: (lambda) ->
    for id, plugin of @plugins
      lambda.call plugin, plugin, id

  eachCmp: (lambda) ->
    for id, cmp of @components
      lambda.call cmp, cmp, id

  getCmp: ($el) ->
    id = $el.data "jcakeId"
    return @components[id]

  addCmp: (id, cmp) ->
    @components[id] = cmp

  removeCmp: (id) ->
    delete @components[id]

  log: (text) ->
    if "console" of window
      console.log text
    else
      alert text

  newID: ->
    Math.random().toString().substring 2

  plugin: (id, methods, createFn, initFn) ->
    if not ("jQuery" of window)
      @log "Can't initialize #{id}, jQuery not found"
      return

    me = @
    me.plugins[id] =
      createFn: createFn
      initFn: initFn
      methods: methods

    $.fn[id] = (args...) ->
      values = []

      for i in [0...@.length]
        $el = @.eq i
        value = $el

        if typeof args[0] is "string"
          method = args[0]

          if methods? and $.inArray(method, methods) > -1
            cmp = me.getCmp $el

            if cmp?
              value = cmp[method].apply cmp, Array.prototype.slice.call args, 1
            else
              me.log "Element must be initialized as #{id} first"
          else
            me.log "'#{method}' is not a valid method for #{id}"
        else
          cmp = createFn.apply me, [ $el ].concat Array.prototype.slice.call args

          if cmp?
            cakeId = $el.data "jcakeId"

            if not cakeId?
              cakeId = me.newID()
              $el.data "jcakeId", cakeId

            me.addCmp cakeId, cmp
          else
            me.log "Element couldn't be initialized as #{id}"

        values.push value

      if values.length is 1
        return values[0]
      else
        isjQueryCollection = yes

        for value in values
          if not value instanceof jQuery
            isjQueryCollection = no
            break

        if isjQueryCollection
          collection = $()
          collection = collection.add value for value in values
          values = collection

      return values

  init: ->
    @eachPlugin (plugin, id) ->
      if typeof plugin.initFn is "function"
        plugin.initFn()
