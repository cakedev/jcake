jcake.plugins.table =
  pluginManager: null

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeTable = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "getSelected"
            pm.notify "Not implemented yet"
          when "setData"
            me.setData @, args[1]
          when "setLoading"
            me.setLoading @
          when "removeLoading"
            me.removeLoading @
          else
            pm.notify "'#{action}' is not a valid action for cakeTable"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      @

  create: ($obj, params) ->
    me = @

    fields = if params.fields? then params.fields else []
    fieldNames = if params.fieldNames? then params.fieldNames else {}
    data = if params.data? then params.data else []
    maxRecords = if params.maxRecords? then params.maxRecords else 20
    formats = if params.formats? then params.formats else {}
    selectable = if params.selectable? then params.selectable else no
    editable = if params.editable? then params.editable else no
    erasable = if params.erasable? then params.erasable else no
    emptyMessage = if params.emptyMessage? then params.emptyMessage else "..."
    onEdit = params.onEdit
    onErase = params.onErase

    $obj.each ->
      table = new Table $(@), fields, fieldNames, data, maxRecords, formats, selectable, editable, erasable, emptyMessage, onEdit, onErase
      me.pluginManager.addComponent table

  setData: ($obj, data) ->
    if data instanceof Array
      for i in [0...$obj.length]
        table = @pluginManager.getComponent $obj.eq(i)
        table.setData(data) if table?

  setLoading: ($obj) ->
    for i in [0...$obj.length]
      table = @pluginManager.getComponent $obj.eq(i)
      table.setLoading() if table?

  removeLoading: ($obj) ->
    for i in [0...$obj.length]
      table = @pluginManager.getComponent $obj.eq(i)
      table.removeLoading() if table?

class Table
  constructor: (@el, @fields, @fieldNames, @data, @maxRecords, @formats, @selectable, @editable, @erasable, @emptyMessage, @onEdit, @onErase) ->
    @loading = no
    @currentPage = 0
    @el.addClass "jcake-table"

    $wrapper = $ "<div class='jcake-table-wrapper' />"
    $records = $ "<table class='jcake-table-records' />"
    $pages = $ "<div class='jcake-table-pages' />"

    $wrapper.append $records
    $wrapper.append "<div class='jcake-table-loading' />"
    $wrapper.append "<div class='jcake-table-message'>#{@emptyMessage}</div>"
    @el.append $wrapper
    @el.append $pages

    @setRecords()

  setData: (data) ->
    @data = data
    @currentPage = 0
    @setRecords() if not @loading

  clearData: ->
    setData []

  showEmptyMessage: ->
    @el.children(".jcake-table-wrapper").children(".jcake-table-message").show()

  hideEmptyMessage: ->
    @el.children(".jcake-table-wrapper").children(".jcake-table-message").hide()

  getValueWithFormat: (field, value) ->
    if typeof @formats[field] is "function"
      valueWithFormat = @formats[field].call value, value
      value = valueWithFormat if valueWithFormat?
    
    if value? then value else ""

  setRecords: ->
    $records = @el.find ".jcake-table-records"
    $records.empty()

    @setHeaders()
    @hideEmptyMessage()

    if @data.length
      start = @currentPage * @maxRecords
      end = start + @maxRecords

      for i in [start...end]
        if i >= @data.length
          break

        $record = $ "<tr />";
        $record.append "<td class='jcake-table-recordActions' />"

        for field in @fields
          value = @getValueWithFormat field, @data[i][field]

          $record.append "<td>#{value}</td>"

        $records.append $record

      @setSelectable() if @selectable
      @setEditable() if @editable
      @setErasable() if @erasable

      $records.find("tr:last td").css "border", "none"
    else
      @showEmptyMessage()

    @setPages()

  setHeaders: ->
    $headers = $ "<tr />"
    $headers.append "<th />"

    for field in @fields
      fieldName = if @fieldNames[field]? then @fieldNames[field] else field
      $headers.append "<th>#{fieldName}</th>"

    @el.find(".jcake-table-records").append $headers

  setPages: ->
    me = @
    $pages = @el.children ".jcake-table-pages"
    $pages.empty()

    pagesCount = Math.ceil(@data.length / @maxRecords)

    for i in [0...pagesCount]
      $page = $ "<a class='jcake-table-page' href='#'>#{i + 1}</a>"
      $page.data "pageIndex", i

      $page.on "click", ->
        index = $(@).data "pageIndex"
        if index isnt me.currentPage
          me.setPage index
        no
      
      $pages.append $page

    $pages.children(".jcake-table-page").eq(@currentPage).addClass "jcake-table-currentPage"

    if @data.length
      @setNavigationControls()
      @setInfo()

  setNavigationControls: ->
    me = @
    $pages = @el.children ".jcake-table-pages"

    $previous = $ "<a href='#'>&laquo; Anterior</a>"
    $next = $ "<a href='#'>Siguiente &raquo;</a>"
    $beginning = $ "<a href='#'>Ir al inicio</a>"
    $end = $ "<a href='#'>Ir al final</a>"

    lastPage = Math.ceil(@data.length / @maxRecords) - 1
    lastPage = 0 if lastPage < 0

    $previous.on "click", ->
      me.setPage(me.currentPage - 1) if me.currentPage > 0
      no
    $beginning.on "click", ->
      me.setPage 0
      no
    $next.on "click", ->
      me.setPage(me.currentPage + 1) if me.currentPage < lastPage
      no
    $end.on "click", ->
      me.setPage lastPage
      no

    $pages
      .prepend($end)
      .prepend($next)
      .prepend($previous)
      .prepend($beginning)

  setInfo: ->
    beginning = @currentPage * @maxRecords
    end = beginning + @maxRecords
    end = @data.length if end > @data.length

    @el.children(".jcake-table-pages").append "<span class='jcake-table-info'>Mostrando #{beginning + 1} a #{end} de #{@data.length}</span>"

  setPage: (index) ->
    @currentPage = index
    @setRecords()

  setSelectable: ->
    no

  setEditable: ->
    $actions = @el.find(".jcake-table-records").find ".jcake-table-recordActions"
    currentIndex = @currentPage * @maxRecords

    me = @
    
    for i in [0...$actions.length]
      $action = $ "<span class='jcake-table-action jcake-edit-icon' />"
      $action.data "cakedevIndex", currentIndex
      $action.on "click", ->
        me.raiseOnEdit $(@).data("cakedevIndex")

      $actions.eq(i).append $action
      currentIndex++

  raiseOnEdit: (index) ->
    if typeof @onEdit is "function"
      @onEdit.call @el, @data[index], index

  setErasable: ->
    $actions = @el.find(".jcake-table-records").find ".jcake-table-recordActions"
    currentIndex = @currentPage * @maxRecords

    me = @
    
    for i in [0...$actions.length]
      $action = $ "<span class='jcake-table-action jcake-trash-icon' />"
      $action.data "cakedevIndex", currentIndex
      $action.on "click", ->
        me.raiseOnErase $(@).data("cakedevIndex")

      $actions.eq(i).append $action
      currentIndex++

  raiseOnErase: (index) ->
    if typeof @onErase is "function"
      @onErase.call @el, @data[index], index

  clearRecords: ->
    @el.find(".jcake-table-records").find("tr").not(":first").remove()
    @el.children(".jcake-table-pages").empty()
    @hideEmptyMessage()

  setLoading: ->
    @clearRecords()
    @el.children(".jcake-table-wrapper").children(".jcake-table-loading").show()
    @loading = yes

  removeLoading: ->
    @el.children(".jcake-table-wrapper").children(".jcake-table-loading").hide()
    @setRecords()
    @loading = no
