jcake.plugin(
  "cakeTabs"
  [ "setTab", "getTab", "getCurrentIndex", "getCurrentTab" ]
  ($el, props) ->
    props = if props? then props else {}

    direction = if props.direction? then props.direction else "top"

    return new Tabs $el, direction
  ->
    $(".x-jcake-tabs").each ->
      $el = $ @

      $el.cakeTabs
        direction: $el.data "direction"
)

class Tabs
  constructor: (@el, @direction) ->
    @el.addClass "jcake-tabs"
    @tabs = @el.children "div"
    @headers = $ "<ul class='jcake-tabs-headers clearfix' />"

    $tabswrapper = $ "<div class='jcake-tabs-tabswrapper' />"
    @el.append $tabswrapper

    if direction is "bottom"
      @headers.addClass "jcake-tabs-headers-bottom"
      @el.append @headers
    else
      @headers.addClass "jcake-tabs-headers-top"
      @el.prepend @headers

    me = @

    for i in [0...@tabs.length]
      $tab = @tabs.eq(i).hide()

      $header = $ "<li class='jcake-tabs-header' />"
      $header
        .data("index", i)
        .text($tab.attr("title"))
        .on("click", ->
          me.setTab $(@).data "index"
        )

      @headers.append $header

      $tab.removeAttr("title")
      $tabswrapper.append $tab

    @setTab 0

  setTab: (index) ->
    if index > -1 and index < @tabs.length and index isnt @currentIndex
      @currentIndex = index

      $tabheaders = @headers.find ".jcake-tabs-header"
      $tabheaders.removeClass "jcake-tabs-header-selected"
      $tabheaders.eq(index).addClass "jcake-tabs-header-selected"

      @tabs.hide()
      @tabs.eq(index).show()

      @el.trigger "tabchange", [ @tabs.eq(index), index ]

    return @el

  getTab: (index) ->
    return @tabs.eq(index)

  getCurrentIndex: ->
    return @currentIndex

  getCurrentTab: ->
    return @tabs.eq(@currentIndex)
