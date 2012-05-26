class TabControl
  constructor: (@element) ->
    @tabs = []
    @currentTab = null
    @direction = "top"
    @bgcolor = null

cake.tabs =
  tabControls: []

  invoke: (action, params) ->
    if action?
      if cake.tabs[action]?
        cake.tabs[action].call @, params
      else
        console.log "'#{action}' is not a valid action for tabs"
        return @
    else
      return cake.tabs.create.call @, params

  create: (params) ->
    @each ->
      $tabControl = $ @
      $tabControl.addClass "-cakedev-tabs" if not $tabControl.hasClass "-cakedev-tabs"

      tabControl = new TabControl $tabControl
      cake.tabs.tabControls.push tabControl

      if params?
        tabControl.direction = params.direction if params.direction?
        tabControl.bgcolor = params.bgcolor if params.bgcolor?

      tabHeaderClass = if tabControl.direction is "bottom" then "-cakedev-tabHeader-bottom" else "-cakedev-tabHeader-top"

      $tabControl.css "background-color", tabControl.bgcolor if tabControl.bgcolor?

      $tabHeadersContainer = $ "<div class='-cakedev-tabHeaders-container'></div>'"
      $tabs = $tabControl.children "div"

      if $tabs.length
        tabHeadersContent = ""

        for el, i in $tabs
          $tab = $tabs.eq i
          $tab.addClass "-cakedev-tab" if not $tab.hasClass "-cakedev-tab"
          
          tabTitle = if $tab.attr "title" then $tab.attr "title" else i
          $tab.removeAttr "title"

          tabHeadersContent += "<td><span class='-cakedev-tabHeader #{tabHeaderClass}'>#{tabTitle}</span></td>"
          tabControl.tabs.push $tab

        if tabControl.direction is "bottom"
          $tabControl.append $tabHeadersContainer
        else
          $tabControl.prepend $tabHeadersContainer

        $tabHeadersContainer.append "<table><tr>#{tabHeadersContent}</tr></table>"
        $tabHeaders = $tabHeadersContainer.find ".-cakedev-tabHeader"

        for el, i in $tabHeaders
          $tabHeaders.eq(i).on "click", ->
            $currentTabControl = $(@).closest ".-cakedev-tabs"
            $headersContainer = $(@).closest ".-cakedev-tabHeaders-container"

            index = 0
            $headers = $headersContainer.find ".-cakedev-tabHeader"

            for el, j in $headers
              if $headers.eq(j).get(0) is $(@).get(0)
                index = j
                break

            $headers.removeClass("-cakedev-selected-tab").eq(index).addClass "-cakedev-selected-tab"
            $currentTabControl.children(".-cakedev-tab").hide()
            $currentTab = $currentTabControl.children(".-cakedev-tab").eq(index).show()

            tabControl.currentTab = $currentTab
            true

        $tabHeadersContainer.find(".-cakedev-tabHeader").eq(0).addClass "-cakedev-selected-tab"
        $tabControl.children(".-cakedev-tab").not(":eq(0)").hide()

        tabControl.currentTab = $tabControl.children(".-cakedev-tab").eq 0
      true

  getActiveTab: ->
    tabControl = cake.tabs.getCurrentElement.call @
    if tabControl? then tabControl.currentTab else null

  getCurrentElement: ->
    element = null
    for tab in cake.tabs.tabControls
      if tab.element.get(0) == @get(0)
        element = tab
        break
    element
