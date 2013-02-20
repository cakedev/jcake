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
          when "setTitle"
            me.setTitle @, args[1]
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
    width = if params.width? then "#{params.width}px" else null
    height = if params.height? then "#{params.height}px"  else null
    position = if params.position is "fixed" then "fixed" else "absolute"

    $obj.each ->
      panel = new Panel $(@), title, modal, draggable, closable, width, height
      me.pluginManager.addComponent panel

  show: ($obj) ->
    me = @

    $obj.each ->
      panel = me.pluginManager.getComponent $(@)

      if panel?
        panel.show()

  hide: ($obj) ->
    me = @

    $obj.each ->
      panel = me.pluginManager.getComponent $(@)
      
      if panel?
        panel.hide()

  setTitle: ($obj, title) ->
    me = @

    $obj.each ->
      panel = me.pluginManager.getComponent $(@)
      
      if panel?
        panel.setTitle title

class Panel
  constructor: (@el, @title, @modal, @draggable, @closable, @width, @height, @position) ->
    me = @
    @panel = $ "<div class='-cakedev-panel' />"
    @panel.css "position", @position

    if @modal
      @wrapper = $ "<div class='-cakedev-panel-wrapper' />"
      @wrapper.append "<div class='-cakedev-panel-wrapper-bg' />"
      @wrapper.insertBefore @el
      
      $wrapperContent = $ "<div class='-cakedev-panel-wrapper-content' />"
      @wrapper.append $wrapperContent
      $wrapperContent.append @panel

      $wrapperContent.on "click", (event) ->
        if me.closable and $(event.target).hasClass "-cakedev-panel-wrapper-content"
          me.hide()
    else
      @panel.insertBefore @el

    @header = $ "<div class='-cakedev-panel-header' />"

    @panel.append @header

    @content = $ "<div class='-cakedev-panel-content' />"
    @panel.append @content
    @content.append @el

    @content.css "width", @width if @width?
    @content.css "height", @height if @height?

    @draggingOffset = null

    @panel.css("position", "fixed") if not modal

    @setTitle @title
    @setClosable @closable

  setTitle: (title) ->
    if title? and typeof title is "string"
      @usingTitleBar = yes

      if @header.hasClass "-cakedev-panel-titlebar"
        @header.children("h1").text title
      else
        @header.addClass "-cakedev-panel-titlebar"
        @header.append "<h1>#{title}</h1>"
    else
      @usingTitleBar = no

      @header.removeClass "-cakedev-panel-titlebar"
      @header.children("h1").remove()

    @setDraggable @draggable

  onMousemove: (event) ->
    if @dragging
      top = event.pageY - @draggingOffset.top
      left = event.pageX - @draggingOffset.left

      containerHeight = @getContainerHeight()
      containerWidth = @getContainerWidth()

      if top < 0
        top = 0
      else if top + @panel.outerHeight() > containerHeight
        top = containerHeight - @panel.outerHeight()

      if left < 0
        left = 0
      else if left + @panel.outerWidth() > containerWidth
        left = containerWidth - @panel.outerWidth()

      @panel.offset
        top: top
        left: left

  getContainerHeight: ->
    return (if @modal then @wrapper.height() else $(document).height()) - 1

  getContainerWidth: ->
    return (if @modal then @wrapper.width() else $(document).width()) - 1

  setDraggable: (allowDrag) ->
    @header.removeClass "-cakedev-draggable"
    @header.off "mousedown"

    if allowDrag and @usingTitleBar
      me = this

      @header.addClass "-cakedev-draggable"

      @header.on "mousedown", (event) ->
        event.preventDefault()

        me.draggingOffset =
          top: event.pageY - me.panel.offset().top
          left: event.pageX - me.panel.offset().left

        me.setDragging yes

  setDragging: (dragging) ->
    @dragging = dragging

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

    $closeBtn = $ "<button class='-cakedev-close-button' />"
    $closeBtn.on "click", ->
      me.el.cakePanel "hide"

    $closeBtn

  show: ->
    if @modal
      @showModal()
    else
      @panel.show()

    @centerPanel()

  hide: ->
    if @modal
      @hideModal()
    else
      @panel.hide()

  showModal: (callback) ->
    me = this

    $("body").css "overflow", "hidden"

    @wrapper.fadeIn "fast", ->
      me.panel.show()

  hideModal: (callback) ->
    @panel.hide()
    @wrapper.fadeOut "fast", ->
      if not $(".-cakedev-panel-wrapper:visible").length
        $("body").css "overflow", "visible"

  centerPanel: ->
    @panel.css "top", "50%"
    @panel.css "margin-top", "-#{Math.round(@panel.height() / 2)}px"

    @panel.css "left", "50%"
    @panel.css "margin-left", "-#{Math.round(@panel.width() / 2)}px"

$(document).on "mousemove", (event) ->
  for cmp in jcakedev.components
    if cmp instanceof Panel
      cmp.onMousemove.apply cmp, [ event ]

$(document).on "mouseup", ->
  for cmp in jcakedev.components
    if cmp instanceof Panel
      cmp.setDragging no
