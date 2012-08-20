jcakedev.plugins.table =
  pluginManager: null

  init: (pm) ->
    @pluginManager = pm
    me = @

    $.fn.cakeTable = (args...) ->
      if typeof args[0] is "string"
        action = args[0]

        switch action
          when "getSelected"
            console.log "Under development..."
          else
            console.log "'#{action}' is not a valid action for cakeTable"
      else
        me.create @, if typeof args[0] is "object" then args[0] else {}
      
      return @

  create: ($elements, params) ->
    me = @

    fields = if params.fields? then params.fields else []
    fieldNames = if params.fieldNames? then params.fieldNames else {}
    data = if params.data? then params.data else []
    maxRecords = if params.maxRecords? then params.maxRecords else 20
    selectable = if params.selectable? then params.selectable else no
    editable = if params.editable? then params.editable else no
    erasable = if params.erasable? then params.erasable else no

    $elements.each ->
      table = new Table me.pluginManager.newID(), $(@), fields, fieldNames, data, maxRecords, selectable, editable, erasable
      me.pluginManager.addElement table

class Table
  constructor: (@id, @element, @fields, @fieldNames, @data, @maxRecords, @selectable, @editable, @erasable) ->
    @element.data "jcakedevId", @id
    @currentPage = 0

    @element.addClass "-cakedev-table"

    $wrapper = $ "<div class='-cakedev-table-wrapper' />"
    $records = $ "<table class='-cakedev-table-records' />"
    $pages = $ "<div class='-cakedev-table-pages' />"

    $wrapper.append $records
    @element.append $wrapper
    @element.append $pages

    @setRecords()

  setRecords: ->
    $records = @element.find ".-cakedev-table-records"
    $records.empty()

    @setHeaders()

    start = @currentPage * @maxRecords
    end = start + @maxRecords

    for i in [start...end]
      if i >= @data.length
        break

      $record = $ "<tr />";
      $record.append "<td class='-cakedev-table-recordActions' />"

      for field in @fields
        value = if @data[i][field]? then @data[i][field] else ""
        $record.append "<td>#{value}</td>"

      $records.append $record

    $records.find("tr:last td").css "border", "none"

    @setPages()
    @setSelectable() if @selectable
    @setEditable() if @editable
    @setErasable() if @erasable

  setHeaders: ->
    $headers = $ "<tr />"
    $headers.append "<th />"

    for field in @fields
      fieldName = if @fieldNames[field]? then @fieldNames[field] else field
      $headers.append "<th>#{fieldName}</th>"

    @element.find(".-cakedev-table-records").append $headers

  setPages: ->
    me = @
    $pages = @element.children ".-cakedev-table-pages"
    $pages.empty()

    pagesCount = Math.ceil(@data.length / @maxRecords)

    for i in [0...pagesCount]
      $page = $ "<a class='-cakedev-table-page' href='#'>#{i + 1}</a>"
      $page.data "pageIndex", i

      $page.on "click", ->
        me.setPage $(@).data("pageIndex")
        no
      
      $pages.append $page

    $pages.children(".-cakedev-table-page").eq(@currentPage).addClass "-cakedev-table-currentPage"
    @setNavigationControls()

  setNavigationControls: ->
    me = @
    $pages = @element.children ".-cakedev-table-pages"

    $previous = $ "<a href='#'>&laquo; Anterior</a>"
    $next = $ "<a href='#'>Siguiente &raquo;</a>"
    $beginning = $ "<a href='#'>Ir al inicio</a>"
    $end = $ "<a href='#'>Ir al final</a>"

    lastPage = Math.ceil(@data.length / @maxRecords) - 1

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
      .prepend($previous)
      .prepend($beginning)
      .append($next)
      .append($end)

  setPage: (index) ->
    @currentPage = index
    @setRecords()

  setSelectable: ->
    no

  setEditable: ->
    $actions = @element.find(".-cakedev-table-records").find ".-cakedev-table-recordActions"
    
    for i in [0...$actions.length]
      $actions.eq(i).append "<span class='-cakedev-table-action -cakedev-edit-icon' />"

  setErasable: ->
    $actions = @element.find(".-cakedev-table-records").find ".-cakedev-table-recordActions"
    
    for i in [0...$actions.length]
      $actions.eq(i).append "<span class='-cakedev-table-action -cakedev-trash-icon' />"
