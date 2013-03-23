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
)()