jcake.plugin(
  "cakeCombo"
  [ "setValue", "getValue", "setItems", "setTitle" ]
  ($el, props) ->
    if not $el.is "select"
      jcake.log "Element must be a 'select' component to behave as a combo"
      return null

    props = if props? then props else {}

    title = props.title if props.title
    maxWidth = props.maxWidth if props.maxWidth

    return new Combo $el, title, maxWidth
  ->
    $(".x-jcake-combo").each ->
      $el = $ @

      $el.cakeCombo
        title: $el.data "title"
        maxWidth: $el.data "maxWidth"

    $(document).on "click", (e) ->
      $el = $(e.target).closest ".jcake-combo-wrapper"
      $panel = $el.find ".jcake-combo-panel"
      $(".jcake-combo-wrapper").find(".jcake-combo-panel").not($panel).cakePanel "hide"
)

class Combo
  constructor: (@el, title, maxWidth) ->
    @wrapper = $ "<div class='jcake-combo-wrapper' />"

    @wrapper.insertAfter @el
    @wrapper.append @el

    @combo = $ "<div class='jcake-combo' />"

    @combo.append "<div class='jcake-combo-text' />"
    @combo.append "<div class='jcake-combo-arrow jcake-icon jcake-arrow-down-black' />"

    @wrapper.append @combo

    if maxWidth?
      @combo.find(".jcake-combo-text").css "max-width", "#{maxWidth - 49}px"

    @panel = $ "<div class='jcake-combo-panel' />"
    
    $searchBox = $ "<div class='jcake-combo-search-box' />"
    $search = $ "<input type='text' class='jcake-combo-search' />"
    $searchBox.append $search

    @panel.append $searchBox
    @panel.append "<div class='jcake-combo-items' />"

    @wrapper.append @panel

    @panel.cakePanel centered: no, modal: no, draggable: no

    items = []

    @el.children("option").each ->
      $opt = $ @

      items.push
        text: $opt.text()
        value: $opt.val()

    me = @

    @combo.on "mouseover", ->
      $(@).find(".jcake-combo-arrow").addClass "jcake-arrow-down-white"

    @combo.on "mouseleave", ->
      $(@).find(".jcake-combo-arrow").removeClass "jcake-arrow-down-white"

    @combo.on "click", ->
      me.showPanel()

    @filterDelay = 200
    @keysPressedCount = 0

    $search.on "keydown", (e) ->
      if e.keyCode is 13
        me.selectCurrentItem()
      else if e.keyCode is 27
        me.hidePanel()
      else if e.keyCode is 38
        me.movePrevious()
      else if e.keyCode is 40
        me.moveNext()
      else
        me.keysPressedCount++
        $me = $ @

        setTimeout(
          ->
            me.keysPressedCount--
            me.setFilter $me.val() if me.keysPressedCount is 0
          me.filterDelay
        )

    value = @el.val()

    @setItems items
    @setValue value
    @setTitle title

  # public methods

  setItems: (items) ->
    if not (items instanceof Array)
      jcake.log "The parameter for 'setItems' is not a valid Array"
      return @el

    @items = items
    
    $items = @panel.find ".jcake-combo-items"
    $items.empty()

    @el.empty()

    for item, i in items
      $item = $ "<span class='jcake-combo-item' />"
      $item.text item.text
      $item.data "index", i

      $option = $ "<option />"
      $option.val item.value
      $option.text item.text

      $items.append $item
      @el.append $option

    @setValue(if items.length then items[0].value else null)

    me = @

    $items.find(".jcake-combo-item").on("click", ->
      me.selectItem $(@).data("index")
    ).on("mouseover", ->
      $item = $ @
      $item.parent().find(".jcake-combo-item").removeClass "jcake-combo-item-hover"
      $item.addClass "jcake-combo-item-hover"
    )

    return @el

  setTitle: (title) ->
    title = if title? then String(title) else ""
    @panel.cakePanel "setTitle", title

    return @el

  setValue: (value) ->
    if @items? and @items.length
      index = -1

      for item, i in @items
        if item.value is String(value)
          index = i
          break

      if index > -1
        $items = @panel.find(".jcake-combo-items").find ".jcake-combo-item"
        $items.removeClass "jcake-combo-item-selected"
        $items.eq(index).addClass "jcake-combo-item-selected"

        @el.val(value).change()
        @combo.find(".jcake-combo-text").text @items[index].text

      return @el
    
    @el.val(null).change()
    @combo.find(".jcake-combo-text").text "-"

    return @el

  getValue: ->
    return @el.val()

  # end

  selectCurrentItem: ->
    $item = @panel.find ".jcake-combo-item-hover"

    if $item.length
      @selectItem $item.data "index"

  selectItem: (index) ->
    if index > -1 and index < @items.length
      @setValue @items[index].value
      @hidePanel()

  showPanel: ->
    @setFilter ""
    @focusSelected()
    @panel.cakePanel "show"
    @panel.find(".jcake-combo-search").val("").focus()
    @scrollToFocusedTop()

  hidePanel: ->
    @panel.cakePanel "hide"

  moveNext: ->
    $current = @panel.find ".jcake-combo-item-hover"
    
    if $current.length
      $next = $current.nextAll().not ".jcake-combo-item-hidden"

      if $next.length
        $next = $next.eq 0
        $current.removeClass "jcake-combo-item-hover"
        $next.addClass "jcake-combo-item-hover"
    else
      $current = @panel.find(".jcake-combo-item").not ".jcake-combo-item-hidden"

      if $current.length
        $current.eq(0).addClass "jcake-combo-item-hover"

    @scrollToFocusedBottom()

  movePrevious: ->
    $current = @panel.find ".jcake-combo-item-hover"
    
    if $current.length
      $prev = $current.prevAll().not ".jcake-combo-item-hidden"

      if $prev.length
        $prev = $prev.eq 0
        $current.removeClass "jcake-combo-item-hover"
        $prev.addClass "jcake-combo-item-hover"
    else
      $current = @panel.find(".jcake-combo-item").not ".jcake-combo-item-hidden"

      if $current.length
        $current.eq(0).addClass "jcake-combo-item-hover"

    @scrollToFocusedTop()

  scrollToFocusedTop: ->
    $focused = @panel.find ".jcake-combo-item-hover"

    if $focused.length 
      if not @isItemFullyVisible($focused)
        $container = $focused.closest ".jcake-combo-items"
        $container.scrollTop($focused.position().top + $container.scrollTop())
    else
      $container.scrollTop 0

  scrollToFocusedBottom: ->
    $focused = @panel.find ".jcake-combo-item-hover"

    if $focused.length
      if not @isItemFullyVisible($focused)
        $container = $focused.closest ".jcake-combo-items"
        $container.scrollTop($container.scrollTop() + (($focused.position().top + $focused.outerHeight(no)) - $container.outerHeight(no)))
    else
      $container.scrollTop 0

  isItemFullyVisible: ($item) ->
    $container = $item.closest ".jcake-combo-items"

    return $item.position().top >= 0 and $item.position().top + $item.outerHeight(no) <= $container.outerHeight(no)

  focusFirst: ->
    @panel.find(".jcake-combo-item").removeClass "jcake-combo-item-hover"
    $items = @panel.find(".jcake-combo-item").not ".jcake-combo-item-hidden"

    if $items.length
      $items.eq(0).addClass "jcake-combo-item-hover"

  focusSelected: ->
    @panel.find(".jcake-combo-item").removeClass "jcake-combo-item-hover"
    @panel.find(".jcake-combo-item-selected").addClass "jcake-combo-item-hover"

  setFilter: (value) ->
    if @items? and @items.length
      value = value.toLowerCase()

      if value isnt @lastFilter
        @lastFilter = value

        $panelItems = @panel.find ".jcake-combo-item"
        $panelItems.removeClass "jcake-combo-item-hidden"

        if value.length
          for item, i in @items
            if item.text.toLowerCase().indexOf(value) < 0
              $panelItems.eq(i).addClass "jcake-combo-item-hidden"

        @focusFirst()
