"use strict"
_ = require 'lodash'

fixedColumns = (data, fields=[], headers=[], delimiter=' ') =>
  order = fields.slice 0
  alias = headers.slice 0
  # default metadata object if order is populated
  if not _.isEmpty(alias) and order.length isnt alias.length
    console.log 'hello'
    metadata = _.reduce order, (r, v, i) =>
      r[v] = index: i, alias: order[i]
      r
    , {}
    alias = []
  metadata ?= {}

  result = [] # transformed rows from data
  for row in data
    for key, value of row # loop through all fields in the object in the current row
      # index of the field is either based on provided fields, or generated if none were provided
      orderIndex = if _.isEmpty(fields) then Object.keys(metadata).length else _.findIndex order, (v) => v is key
      # if fields were provided, and new field is found, ignore it
      continue if orderIndex is -1
      # create metadata if no fields were provided
      metadata[key] ?= index: orderIndex, alias: key
      # track any keys that have not been discovered before, assuming no set fields were provided
      order.push key if key not in order and _.isEmpty fields
      metadata[key].type = typeof value
      switch metadata[key].type
        when 'string' then metadata[key].max = _.max [0, metadata[key].max, value.length]
        when 'number' then metadata[key].max = _.max [0, metadata[key].max, value.toString().length]
        else metadata[key].max = 0

  # if no headers were provided, or fields were discovered, make them the same as the known keys
  alias = order.slice 0 if _.isEmpty alias
  remove = [] # elements that will be skipped

  # remove any keys that are either not provided, have 0 length across the board, or are undesired
  for key, value of metadata
    if (_.isEmpty(fields) or key in fields) and value.max
      value.max = _.max [value.max, alias[value.index].length]
      switch value.type
        when 'string' then alias[value.index] = _.padEnd alias[value.index], value.max, ' '
        when 'number' then alias[value.index] = _.padStart alias[value.index], value.max, ' '
    else
      remove.push value.index
  remove.sort().reverse()
  for i in remove
    order.splice i, 1
    alias.splice i, 1

  # remove any fields that are requested, but not in the data at all
  remove = []
  for v, i in order
    if v not of metadata
      remove.push i
  remove.sort().reverse()
  for i in remove
    order.splice i, 1
    alias.splice i, 1

  # pad the fields, add the delimiter, and add a header row
  result = _(data)
  .chain()
  .map (row) =>
    result = []
    for key in order
      switch metadata[key].type
        when 'string' then result.push _.padEnd row[key], metadata[key].max, ' '
        when 'number' then result.push _.padStart row[key], metadata[key].max, ' '
    result.join delimiter
  .tap (rows) =>
    rows.unshift alias.join delimiter
  .join '\n'
  .value()

module.exports = exports = {
  fixedColumns
}
