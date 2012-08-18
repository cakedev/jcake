class Table
  constructor: (@element, @fields, @fieldNames, @data, @maxRecords, @selectable, @editable, @erasable) ->
    @currentPage = 0

cake.table =
  tables: []

  invoke: (action, params) ->
    if action?
      if cake.table[action]?
        return cake.table[action].call @, params
      else
        console.log "'#{action}' is not a valid action for table"
        return @
    else
      return cake.table.create.call @, params

  create: (params) ->
    fields = if params.fields? then params.fields else []
    fieldNames = if params.fieldNames? then params.fieldNames else {}
    data = if params.data? then params.data else []
    maxRecords = if params.maxRecords? then params.maxRecords else 20
    selectable = if params.selectable? then params.selectable else no
    editable = if params.editable? then params.editable else no
    erasable = if params.erasable? then params.erasable else no

    @each ->
      $table = $ @
      $table.addClass "-cakedev-table"

      table = new Table $table, fields, fieldNames, data, maxRecords, selectable, editable, erasable

      cake.table.tables.push table
      
      $wrapper = $ "<div class='-cakedev-table-wrapper' />"
      $records = $ "<table class='-cakedev-table-records' />"
      $pages = $ "<div class='-cakedev-table-pages' />"

      $wrapper.append $records
      $table.append $wrapper
      $table.append $pages

      cake.table.setRecords.call $table

  setHeaders: ->
    $headers = $ "<tr />"
    $headers.append "<th />"

    for field in @fields
      fieldName = if @fieldNames[field]? then @fieldNames[field] else field
      $headers.append "<th>#{fieldName}</th>"

    @element.find(".-cakedev-table-records").append $headers

  setRecords: ->
    table = cake.table.getCurrentElement.call @

    $records = table.element.find ".-cakedev-table-records"
    $records.empty()

    cake.table.setHeaders.call table

    start = table.currentPage * table.maxRecords
    end = start + table.maxRecords

    for i in [start...end]
      if i >= table.data.length
        break

      $record = $ "<tr />";
      $record.append "<td class='-cakedev-table-recordActions' />"

      for field in table.fields
        value = if table.data[i][field]? then table.data[i][field] else ""
        $record.append "<td>#{value}</td>"

      $records.append $record

    $records.find("tr:last td").css "border", "none"

    cake.table.setPages.call table
    cake.table.setSelectable.call table if table.selectable
    cake.table.setEditable.call table if table.editable
    cake.table.setErasable.call table if table.erasable

  setPages: ->
    me = @
    $pages = @element.children ".-cakedev-table-pages"
    $pages.empty()

    pagesCount = Math.ceil(@data.length / @maxRecords)

    for i in [0...pagesCount]
      $page = $ "<a class='-cakedev-table-page' href='#'>#{i + 1}</a>"

      $page.on "click", ->
        $currentPage = $ @
        $siblings = $currentPage.parent().children ".-cakedev-table-page"

        for j in [0...$siblings.length]
          if $siblings.eq(j).get(0) is $currentPage.get(0)
            cake.table.setPage.call me, j
            break;

        no
      
      $pages.append $page

    $pages.children(".-cakedev-table-page").eq(@currentPage).addClass "-cakedev-table-currentPage"
    cake.table.setNavigationControls.call @

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

  setNavigationControls: ->
    me = @
    $pages = @element.children ".-cakedev-table-pages"

    $previous = $ "<a href='#'>&laquo; Anterior</a>"
    $next = $ "<a href='#'>Siguiente &raquo;</a>"
    $beginning = $ "<a href='#'>Ir al inicio</a>"
    $end = $ "<a href='#'>Ir al final</a>"

    lastPage = Math.ceil(@data.length / @maxRecords) - 1

    $previous.on "click", ->
      cake.table.setPage.call me, me.currentPage - 1 if me.currentPage > 0
      no
    $beginning.on "click", ->
      cake.table.setPage.call me, 0
      no
    $next.on "click", ->
      cake.table.setPage.call me, me.currentPage + 1 if me.currentPage < lastPage
      no
    $end.on "click", ->
      cake.table.setPage.call me, lastPage
      no

    $pages
      .prepend($previous)
      .prepend($beginning)
      .append($next)
      .append($end)

  setPage: (index) ->
    @currentPage = index
    cake.table.setRecords.call @element

  getCurrentElement: ->
    currentTable = null
    for table in cake.table.tables
      if table.element.get(0) is @get(0)
        currentTable = table

    currentTable
