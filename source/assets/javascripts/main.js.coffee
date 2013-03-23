#= require tangle/Tangle.js
#= require tangle/TangleKit/mootools.js
#= require tangle/TangleKit/sprintf.js
#= require tangle/TangleKit/BVTouchable.js
#= require tangle/TangleKit/TangleKit.js

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

  setUpTangle = ->
    element = document.getElementById("tangle")
    tangle = new Tangle(element,
      initialize: ->
        @CHF = 4
        @caloriesPerCookie = 50
      update: ->
        @TFD = @CHF * @caloriesPerCookie
      )
  setUpTangle()

  setUpEditable = ->
    $.fn.editable.defaults.mode = "inline"
    $('#social-group').editable(
      showbuttons: false,
      type: "select2",
      value: 2,
      source: [
        {id: '1', text: 'Married without children'},
        {id: '2', text: 'Married with two children'},
        {id: '3', text: 'Single, fuck yeah!'}
      ]
    )
    $('#income-group').editable(
      showbuttons: false,
      type: "select2",
      value: 1,
      source: [
        {id: '1', text: '10000 – 20000'},
        {id: '2', text: '20000 – 40000'},
        {id: '3', text: '40000 – 80000'}
      ]
    )
    $('#municipality').editable(
      showbuttons: false,
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