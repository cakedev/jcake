jcakedev.plugins.panel =
  pluginManager: null  

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakePanel = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "show"
            me.show @
          when "hide"
            me.hide @
          else
            pm.notify "'#{action}' is not a valid action for cakePanel"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @

  create: ($obj, params) ->
    me = @

    title = params.title
    modal = if params.modal? then params.modal else yes
    draggable = if params.draggable? then params.draggable else yes
    closable = if params.closable? then params.closable else yes
    width = if params.width? then "#{params.width}px" else "auto"
    height = if params.height? then "#{params.height}px" else "auto"

    $obj.each ->
      panel = new Panel $(@), title, modal, draggable, closable, width, height
      me.pluginManager.addComponent panel

  show: ($obj) ->
    me = @

    $obj.each ->
      panel = me.pluginManager.getComponent $(@)

      if panel?
        if panel.modal
          me.pluginManager.lockContent -> panel.show()
        else
          panel.show()

  hide: ($obj) ->
    me = @

    $obj.each ->
      panel = me.pluginManager.getComponent $(@)
      
      if panel?
        panel.hide()
        me.pluginManager.unlockContent() if panel.modal

class Panel
  constructor: (@el, @title, @modal, @draggable, @closable, @width, @height) ->
    @el.addClass "-cakedev-panel"

    @header = $ "<div class='-cakedev-panel-header' />"
    @el.prepend @header

    @el.css "width", @width
    @el.css "height", @height
    @el.css "margin-left", "-#{Math.round(@el.width() / 2)}px"

    @draggingOffset = null

    @setTitle() if @title? and typeof @title is "string"
    @setDraggable @draggable
    @setClosable @closable

  setTitle: ->
    @header.addClass "-cakedev-panel-titlebar"
    @header.append "<h1>#{@title}</h1>"

  onMousemove: (event) ->
    if @draggingOffset?
      @el.addClass "-cakedev-draggable" if not @el.hasClass "-cakedev-draggable"

      @el.offset
        top: event.pageY - @draggingOffset.top
        left: event.pageX - @draggingOffset.left

  setDraggable: (allowDrag) ->
    if allowDrag
      me = this
      @header.addClass "-cakedev-draggable"

      @el.on "mousedown", (event) ->
        me.draggingOffset =
          top: event.pageY - me.el.offset().top
          left: event.pageX - me.el.offset().left

        event.preventDefault()
    else
      @el.removeClass "-cakedev-draggable"
      @el.off "mousedown"

  setClosable: (allowClose) ->
    $closeBtn = @header.children ".-cakedev-close-button"

    if allowClose
      if not $closeBtn.length
        @header.append @getCloseButton()
    else
      if $closeBtn.length
        $closeBtn.remove()

  getCloseButton: ->
    me = @

    $closeBtn = $ "<button class='-cakedev-close-button'>&times;</button>"
    $closeBtn.on "click", ->
      me.el.cakePanel "hide"

    $closeBtn

  show: ->
    @el.show()

  hide: ->
    @el.hide()

$(document).on "mousemove", (event) ->
  for cmp in jcakedev.components
    if cmp instanceof Panel
      cmp.onMousemove.apply cmp, [ event ]

$(document).on "mouseup", ->
  for cmp in jcakedev.components
    if cmp instanceof Panel
      cmp.draggingOffset = null
      cmp.el.removeClass "-cakedev-draggable"
