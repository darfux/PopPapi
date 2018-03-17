# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener("turbolinks:load", ->
  @show_repeat = (elm)->
      id = $(elm).attr("data")
      text = $(elm).html()
      $.get("repeat/#{id}", (data)->
        console.log data
        $("#repeat-text-title").html(text)
        $("#repeat-text-content").html(data)
      )
)
