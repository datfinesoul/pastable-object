let po = require('../lib/index')
let data = require('./test.json')

order = ['direction', 'date', 'start', 'end', 'duration', 'caller']
alias = ['Type', 'Date', 'Start', 'End', 'Min(s)', 'Caller']

// Only provide an array of objects
let result = po.fixedColumns(data)
console.log(result)

// Provide data, and a list of fields we want
let result2 = po.fixedColumns(data, order)
console.log(result2)

// data, list of fields, and some aliases with a new delimiter
let result3 = po.fixedColumns(data, order, alias, ' | ')
console.log(result3)

// Mismatch alias with desired fields
let result4 = po.fixedColumns(data, order, [1, 2, 3, 4])
console.log(result4)

// Invalid desired fields
let result5 = po.fixedColumns(data, ['direction', 'caller', '---'])
console.log(result5)
