###
jCaKeDev 1.2.6
cakedevp.github.com/jcakedev
###

jcakedev =
  plugins: {}
  elements: []

  getElement: (id) ->
    element = null

    for el in @elements
      if el.id is id
        element = el
        break

    element

  addElement: (element) ->
    @elements.push element

  removeElement: (id) ->
    index = -1

    for el, i in @elements
      if el.id is id
        index = i
        break
    
    if index > -1
      @elements.splice index, 1

  newID: ->
    Math.random().toString().substring 2

  init: ($) ->
    for plugin of @plugins
      @plugins[plugin].init @
