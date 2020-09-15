const express = require('express')
const morgan = require('morgan') // logging
const app = express()
const func = require('./index')

app.use(express.json())
app.use(morgan('dev'));
app.post('/typeform-import-response', func.handler)

module.exports = app
