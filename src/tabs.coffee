jcakedev.plugins.tabs =
  pluginManager: null

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeTabs = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "getCurrent"
            @pm.notify "Not implemented yet"
          else
            @pm.notify "'#{action}' is not a valid action for cakeTabs"
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

    @el.addClass "-cakedev-tabs"

    tabHeaderClass = if @direction is "bottom" then "-cakedev-tabHeader-bottom" else "-cakedev-tabHeader-top"

    $tabHeadersContainer = $ "<div class='-cakedev-tabHeaders-container'></div>'"
    $tabs = @el.children "div"

    if $tabs.length
      tabHeadersContent = ""

      for i in [0...$tabs.length]
        $tab = $tabs.eq i
        $tab.addClass "-cakedev-tab"
        
        tabTitle = if $tab.attr "title" then $tab.attr "title" else i
        $tab.removeAttr "title"

        tabHeadersContent += "<td><span class='-cakedev-tabHeader #{tabHeaderClass}'>#{tabTitle}</span></td>"

      if @direction is "bottom"
        @el.append $tabHeadersContainer
      else
        @el.prepend $tabHeadersContainer

      $tabHeadersContainer.append "<table><tr>#{tabHeadersContent}</tr></table>"
      $tabHeaders = $tabHeadersContainer.find ".-cakedev-tabHeader"

      me = @

      for i in [0...$tabHeaders.length]
        $tabHeaders.eq(i).data "cakedevIndex", i
        $tabHeaders.eq(i).on "click", ->
          $currentTabControl = $(@).closest ".-cakedev-tabs"
          $headersContainer = $(@).closest ".-cakedev-tabHeaders-container"

          me.currentTabIndex = $(@).data "cakedevIndex"
          me.setCurrentTab()

      @currentTabIndex = 0
      @setCurrentTab()

  setCurrentTab: ->
    $headers = @el.children(".-cakedev-tabHeaders-container").find ".-cakedev-tabHeader"
    $headers.removeClass "-cakedev-selected-tab"
    $headers.eq(@currentTabIndex).addClass "-cakedev-selected-tab"

    @el.children(".-cakedev-tab").hide().eq(@currentTabIndex).show()
