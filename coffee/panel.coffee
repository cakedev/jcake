jcake.plugin(
  "cakePanel"
  [ "show", "hide", "setTitle", "setDraggable", "setClosable", "setCentered" ]
  ($el, props) ->
    props = if props? then props else {}

    title = props.title
    modal = if props.modal? then props.modal else yes
    draggable = if props.draggable? then props.draggable else yes
    closable = if props.closable? then props.closable else yes
    width = if props.width? then "#{props.width}px" else null
    height = if props.height? then "#{props.height}px" else null
    centered = if props.centered? then props.centered else yes

    return new Panel $el, title, modal, draggable, closable, width, height, centered
  ->
    $(".x-jcake-panel").each ->
      $el = $ @

      $el.cakePanel
        title: $el.data "title"
        modal: $el.data "modal"
        draggable: $el.data "draggable"
        closable: $el.data "closable"
        width: $el.data "width"
        height: $el.data "height"
        centered: $el.data "centered"

    $(document).on "mousemove", (event) ->
      jcake.eachCmp (cmp, id) ->
        cmp.onMousemove(event) if cmp instanceof Panel

    $(document).on "mouseup", ->
      jcake.eachCmp (cmp, id) ->
        cmp.setDragging(no) if cmp instanceof Panel
)

class Panel
  constructor: (@el, @title, @modal, @draggable, @closable, @width, @height, @centered) ->
    me = @
    @panel = $ "<div class='jcake-panel' />"

    if @modal
      @wrapper = $ "<div class='jcake-panel-wrapper' />"
      @wrapper.append "<div class='jcake-panel-wrapper-bg' />"
      @wrapper.insertBefore @el
      
      $wrapperContent = $ "<div class='jcake-panel-wrapper-content' />"
      @wrapper.append $wrapperContent
      $wrapperContent.append @panel

      $wrapperContent.on "click", (event) ->
        if me.closable and $(event.target).hasClass "jcake-panel-wrapper-content"
          me.hide()
    else
      @panel.insertBefore @el

    @header = $ "<div class='jcake-panel-header' />"
    @header.append "<h1 />"

    @panel.append @header

    @content = $ "<div class='jcake-panel-content' />"
    @panel.append @content
    @content.append @el

    @panel.css "width", @width if @width?
    @panel.css "height", @height if @height?

    @draggingOffset = null

    @setTitle @title
    @setClosable @closable
    @setDraggable @draggable

  # public methods

  setTitle: (title) ->
    if typeof title isnt "string"
      title = ""

    @header.children("h1").text title

    return @el

  show: ->
    if @modal
      @showModal()
    else
      @panel.show()

    if @centered
      @centerPanel()

    return @el

  hide: ->
    if @modal
      @hideModal()
    else
      @panel.hide()

    return @el

  setClosable: (allowClose) ->
    $closeBtn = @header.children ".jcake-close-button"

    if allowClose
      @header.addClass "jcake-closable"

      if not $closeBtn.length
        @header.append @getCloseButton()
    else
      @header.removeClass "jcake-closable"

      if $closeBtn.length
        $closeBtn.remove()

    return @el

  setDraggable: (allowDrag) ->
    @header.removeClass "jcake-draggable"
    @header.off "mousedown"

    if allowDrag
      me = this

      @header.addClass "jcake-draggable"

      @header.on "mousedown", (event) ->
        event.preventDefault()

        me.draggingOffset =
          top: event.pageY - me.panel.offset().top
          left: event.pageX - me.panel.offset().left

        me.setDragging yes

    return @el

  setCentered: (center) ->
    @centered = center

    if @centered
      @centerPanel()

  # end

  onMousemove: (event) ->
    if @dragging
      top = event.pageY - @draggingOffset.top
      left = event.pageX - @draggingOffset.left

      @panel.offset
        top: top
        left: left

  getContainerHeight: ->
    return (if @modal then @wrapper.height() else $(document).height()) - 1

  getContainerWidth: ->
    return (if @modal then @wrapper.width() else $(document).width()) - 1

  setDragging: (dragging) ->
    @dragging = dragging

  getCloseButton: ->
    me = @

    $closeBtn = $ "<button class='jcake-close-button' />"
    $closeBtn.on "click", (e) ->
      e.preventDefault()
      me.el.cakePanel "hide"

    $closeBtn

  showModal: (callback) ->
    me = this

    $("body").css "overflow", "hidden"

    @wrapper.fadeIn "fast", ->
      me.panel.show()

  hideModal: (callback) ->
    @panel.hide()
    @wrapper.fadeOut "fast", ->
      if not $(".jcake-panel-wrapper:visible").length
        $("body").css "overflow", "visible"

  centerPanel: ->
    @panel.css "top", "50%"
    @panel.css "margin-top", "-#{Math.round(@panel.height() / 2)}px"

    @panel.css "left", "50%"
    @panel.css "margin-left", "-#{Math.round(@panel.width() / 2)}px"
