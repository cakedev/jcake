###
jCaKeDev 1.3.1
cakedevp.github.com/jcakedev
###

jcakedev =
  plugins: {}
  components: []

  getComponent: ($el) ->
    id = $el.data "cakeId"
    component = null

    for comp in @components
      if comp.id is id
        component = comp
        break

    component

  addComponent: (comp) ->
    comp.id = @newID()
    comp.el.data "cakeId", comp.id
    @components.push comp

  removeComponent: (id) ->
    index = -1

    for comp, i in @components
      if comp.id is id
        index = i
        break
    
    if index > -1
      @components.splice index, 1

  notify: (text) ->
    console.log text

  newID: ->
    Math.random().toString().substring 2

  lockContent: (callback) ->
    if !$("#cakedev-screenLocker").length
      $locker = $ "<div id='cakedev-screenLocker' />"
      $("body").append $locker

      $locker.fadeIn "fast", ->
        if typeof callback is "function"
          callback()
    else if typeof callback is "function"
      callback()

  unlockContent: (callback) ->
    $locker = $("#cakedev-screenLocker")

    doFinalActions = ->
      $locker.remove()

      if typeof callback is "function"
          callback()

    if $locker.length
      $locker.fadeOut "fast", doFinalActions
    else
      doFinalActions()

  init: ($) ->
    for plugin of @plugins
      @plugins[plugin].init @
