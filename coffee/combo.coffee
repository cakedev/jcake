jcake.plugins.combo =
  pluginManager: null

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeCombo = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "getValue"
            return me.getValue @
          when "setValue"
            me.setValue @, args[1]
          else
            pm.notify "'#{action}' is not a valid action for cakeCombo"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @

  create: ($obj, params) ->
    me = @

    if params.options? and params.options.length
      options = params.options
      delegate = params.delegate
      defaultValue = params.defaultValue

      $obj.each ->
        combo = new Combo $(@), options, delegate
        combo.setValue defaultValue if defaultValue?

        me.pluginManager.addComponent combo
    else
      @pluginManager.notify "No options were defined for cakeCombo"

  getValue: ($obj) ->
    if $obj.length > 1
      values =
        for i in [0...$obj.length]
          $el = $obj.eq i

          combo = @pluginManager.getComponent $el
          continue if not combo?

          combo.getValue()
    else
      combo = @pluginManager.getComponent $obj
      if combo? then combo.getValue() else null

  setValue: ($obj, value) ->
    for i in [0...$obj.length]
      $el = $obj.eq i

      combo = @pluginManager.getComponent $el
      combo.setValue(value) if combo?

class Combo
  constructor: (@el, @options, @delegate) ->
    @selectedIndex = 0
    @el.addClass "jcake-combo"

    $comboElement = $ "<table class='jcake-combo-element' />"
    $comboElement.append(
      "<tr>" +
        "<td class='jcake-combo-optionText'></td>" +
        "<td class='jcake-combo-arrow'><span class='jcake-arrow jcake-arrow-down-black'></span></td>" +
      "</tr>"
    )

    @el.append $comboElement

    @setOptions()
    @setCurrentOption()

    me = @

    $comboElement.on "mouseenter", ->
      me.showList yes
      me.setFocus yes

    $comboElement.on "mouseleave", (event) ->
      $target = if event.toElement? then $(event.toElement) else $(event.relatedTarget)

      if (not $target.hasClass("jcake-combo-list-container") and not $target.closest(".jcake-combo-list-container").length)
        me.hideList yes
        me.setFocus no

      yes

  showList: (animate) ->
    $el = @el.children(".jcake-combo-list-container")
    $el.stop().show()
    if animate
      $el.animate { opacity: 1.0 }, 200
    else
      $el.css "opacity", 1.0

  hideList: (animate) ->
    $el = @el.children(".jcake-combo-list-container")
    if animate
      $el.stop().animate { opacity: 0 }, 200, -> $el.hide()
    else
      $el.stop().hide()
      $el.css "opacity", 0

  setOptions: ->
    me = @
    $listContainer = $ "<div class='jcake-combo-list-container' />"
    $list = $ "<ul />"

    for option in @options
      $list.append "<li>#{option.text}</li>"

    $listContainer.append $list

    $list.children("li").each (index) ->
      $(@).on "click", (event) ->
        if me.selectedIndex isnt index
          if typeof me.delegate is "function"
            me.delegate.call me.el, me.options[index]

          me.setValue me.options[index].value
          me.setFocus no
          me.hideList no

          yes

    $listContainer.on "mouseleave", (event) ->
      $target = if event.toElement? then $(event.toElement) else $(event.relatedTarget)

      if (not $target.hasClass("jcake-combo-element") and not $target.closest(".jcake-combo-element").length)
        me.hideList yes
        me.setFocus no

      yes

    @el.append $listContainer

  setCurrentOption: ->
    @el.children("table").find(".jcake-combo-optionText").text @options[@selectedIndex].text

    $options = @el.children(".jcake-combo-list-container").children("ul").children "li"
    $options.removeClass "jcake-combo-selectedOption"
    $options.eq(@selectedIndex).addClass "jcake-combo-selectedOption"

  setFocus: (focus) ->
    if focus
      @el.children(".jcake-combo-element").addClass "jcake-combo-focused"
    else
      @el.children(".jcake-combo-element").removeClass "jcake-combo-focused"

  setValue: (value) ->
    if @getValue() isnt value
      for option, i in @options
        if option.value is value
          @selectedIndex = i
          break

      @setCurrentOption()

  getValue: ->
    @options[@selectedIndex].value
