(->
  $("a#panel_toggle").click ->
    panel = $(".panel")
    if panel.hasClass("folded")
      $(".section").not(".title").slideDown "normal", ->
        $(".section").not(".title").children().animate opacity: 1
        $(".title").removeClass "last"
        panel.toggleClass("folded")
        panel.toggleClass("unfolded")
    else
      $(".section").not(".title").children().animate
        opacity: 0,
        "normal", ->
          $(".section").not(".title").slideUp()
          $(".title").addClass "last"
          panel.toggleClass("folded")
          panel.toggleClass("unfolded")

  setUpEditable = ->
    $.fn.editable.defaults.mode = "inline"
    $.fn.editable.defaults.showbuttons = false
    $.fn.editable.defaults.url = (params) ->
      d = new $.Deferred
      if params.value is "abc"
        d.reject "error message"
      else
        console.log(params)

    $('#social-group').editable(
      type: "select2",
      value: 2,
      source: [
        {id: '1', text: 'Married without children'},
        {id: '2', text: 'Married with two children'},
        {id: '3', text: 'Single, fuck yeah!'}
      ],
      select2:
        width: 300
    )
    $('#income-group').editable(
      type: "select2",
      value: 1,
      source: [
        {id: '1', text: '10000 – 20000'},
        {id: '2', text: '20000 – 40000'},
        {id: '3', text: '40000 – 80000'}
      ]
    )
    $('#municipality').editable(
      type: "select2",
      value: 1,
      source: [
        {id: '1', text: 'Egliswil'},
        {id: '2', text: 'Lenzburg'},
        {id: '3', text: 'Aarau'}
      ]
    )
  setUpEditable()

)()