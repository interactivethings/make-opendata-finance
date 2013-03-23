#= require_self
#
#= require jquery/jquery
#= require jquery-ui/ui/jquery-ui.custom.js
#
#= require lodash/lodash
#= require handlebars/handlebars
#= require backbone/backbone
#= require backbone.queryparams/backbone.queryparams
#
#= require d3/d3
#
#= require xdate/index
#
#= require select2/select2
#= require bootstrap/docs/assets/js/bootstrap
#= require bootstrap-editable/bootstrap-editable/js/bootstrap-editable
#
#= require topojson/topojson
#= require queue-async/queue

###
# This is the import map for all shared files (our own and vendor libraries)
###

# Define application namespace and base config
window.app =
  config:
    googleAnalyticsAccount: null
