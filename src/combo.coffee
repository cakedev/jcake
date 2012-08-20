jcakedev.plugins.combo =
  pluginManager: null,

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
            console.log "Under development..."
          else
            console.log "'#{action}' is not a valid action for cakeCombo"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @


  create: ($elements, params) ->
    me = @

    if params.options? and params.options.length
      options = params.options
      delegate = params.delegate
      defaultValue = params.defaultValue

      $elements.each ->
        combo = new Combo me.pluginManager.newID(), $(@), options, delegate
        combo.setValue defaultValue if defaultValue?

        me.pluginManager.addElement combo
    else
      console.log "No options were defined for combo(s)"
      $elements

  getValue: ($element) ->
    combo = @pluginManager.getElement $element.data "jcakedevId"

    if combo?
      combo.getValue()
    else
      null

class Combo
  constructor: (@id, @element, @options, @delegate) ->
    @element.data "jcakedevId", @id
    @selectedIndex = 0

    @element.addClass "-cakedev-combo"

    @element.append(
      "<table>" +
        "<tr>" +
          "<td class='-cakedev-combo-optionText'></td>" +
          "<td class='-cakedev-combo-arrow'><div class='-cakedev-arrow -cakedev-arrow-down-black'></div></td>" +
        "</tr>" +
      "</table>"
    )

    @setOptions()
    @setCurrentOption()

    me = @

    @element.on "mouseenter", ->
      me.showList(yes)

    @element.on "mouseleave", ->
      me.hideList(yes)

  showList: (animate) ->
    $el = @element.children(".-cakedev-combo-list-container")
    $el.stop().show()
    if animate
      $el.stop().animate { opacity: 1.0 }, 200
    else
      $el.css "opacity", 1.0

  hideList: (animate) ->
    $el = @element.children(".-cakedev-combo-list-container")
    if animate
      $el.stop().animate { opacity: 0 }, 200, -> $el.hide()
    else
      $el.stop().hide()
      $el.css "opacity", 0

  setOptions: ->
    me = @
    $listContainer = $ "<div class='-cakedev-combo-list-container' />"
    $list = $ "<ul />"

    for option in @options
      $list.append "<li>#{option.text}</li>"

    $listContainer.append $list

    $list.children("li").each (index) ->
      $(@).on "click", (event) ->
        if me.selectedIndex isnt index
          if typeof me.delegate is "function"
            me.delegate.call me.element, me.options[index]

          me.setValue me.options[index].value
          me.hideList(no)

          true

    @element.append $listContainer

  setCurrentOption: ->
    @element.children("table").find(".-cakedev-combo-optionText").text @options[@selectedIndex].text

    $options = @element.children(".-cakedev-combo-list-container").children("ul").children "li"
    $options.removeClass "-cakedev-combo-selectedOption"
    $options.eq(@selectedIndex).addClass "-cakedev-combo-selectedOption"

  setValue: (value) ->
    if @getValue() isnt value
      for option, i in @options
        if option.value is value
          @selectedIndex = i
          break

      @setCurrentOption()

  getValue: ->
    @options[@selectedIndex].value
