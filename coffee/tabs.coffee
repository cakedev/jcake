jcake.plugins.tabs =
  pluginManager: null

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeTabs = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "getCurrent"
            pm.notify "Not implemented yet"
          else
            pm.notify "'#{action}' is not a valid action for cakeTabs"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @

  create: ($obj, params) ->
    me = @

    direction = if params.direction? then params.direction else "top"

    $obj.each ->
      tabControl = new TabControl $(@), direction
      me.pluginManager.addComponent tabControl

class TabControl
  constructor: (@el, @direction) ->
    @currentTabIndex = 0

    @el.addClass "jcake-tabs"

    tabHeaderClass = if @direction is "bottom" then "jcake-tabHeader-bottom" else "jcake-tabHeader-top"

    $tabHeadersContainer = $ "<div class='jcake-tabHeaders-container'></div>'"
    $tabs = @el.children "div"

    if $tabs.length
      tabHeadersContent = ""

      for i in [0...$tabs.length]
        $tab = $tabs.eq i
        $tab.addClass "jcake-tab"
        
        tabTitle = if $tab.attr "title" then $tab.attr "title" else i
        $tab.removeAttr "title"

        tabHeadersContent += "<td><span class='jcake-tabHeader #{tabHeaderClass}'>#{tabTitle}</span></td>"

      if @direction is "bottom"
        @el.append $tabHeadersContainer
      else
        @el.prepend $tabHeadersContainer

      $tabHeadersContainer.append "<table><tr>#{tabHeadersContent}</tr></table>"
      $tabHeaders = $tabHeadersContainer.find ".jcake-tabHeader"

      me = @

      for i in [0...$tabHeaders.length]
        $tabHeaders.eq(i).data "cakedevIndex", i
        $tabHeaders.eq(i).on "click", ->
          $currentTabControl = $(@).closest ".jcake-tabs"
          $headersContainer = $(@).closest ".jcake-tabHeaders-container"

          me.currentTabIndex = $(@).data "cakedevIndex"
          me.setCurrentTab()

      @currentTabIndex = 0
      @setCurrentTab()

  setCurrentTab: ->
    $headers = @el.children(".jcake-tabHeaders-container").find ".jcake-tabHeader"
    $headers.removeClass "jcake-selected-tab"
    $headers.eq(@currentTabIndex).addClass "jcake-selected-tab"

    @el.children(".jcake-tab").hide().eq(@currentTabIndex).show()
