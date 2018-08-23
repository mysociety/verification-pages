/* global $, wgUserName */
'use strict'

$(document).ready(function () {
  var recordDecision = function (anchor, data) {
    var url = anchor.attr('href')

    $.ajax({
      type: 'POST',
      url: url,
      data: data
    })
  }

  $('.verification-js-actionable').each(function () {
    var row = $(this)
    var yesButton = $('.verification-yes', row)
    var noButton = $('.verification-no', row)

    var statementData = row.data()
    var handleClick = function (status) {
      return function (e) {
        e.preventDefault()
        var anchor = $(this).parent('a')
        recordDecision(anchor, $.extend({}, statementData, {
          status: status,
          user: wgUserName
        }))
      }
    }

    noButton.show().on('click', handleClick(false))
    yesButton.show().on('click', handleClick(true))
  })
})
