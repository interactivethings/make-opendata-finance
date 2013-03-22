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
)()