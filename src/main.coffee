###
jCaKeDev 1.3
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

  newID: ->
    Math.random().toString().substring 2

  init: ($) ->
    for plugin of @plugins
      @plugins[plugin].init @
