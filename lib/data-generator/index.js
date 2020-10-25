const config = require('./config')()
const log = require('./util/logger')({
  debugLoggingEnabled: config.debug
})
const fetch = require('./util/fetch')({
  log
})
const jwt = require('./util/jwt')({
  jwtKey: config.jwtKey
})
const buildTRMAPI = require('trm-api')({
  graphqlURL: config.graphqlURL,
  token: jwt.admin(),
  fetch,
  log
})
const generateTechies = require('./lib/techies')
const { Command } = require('commander')

const program = new Command()

const generate = program
  .command('generate')
  .description('Generate fake data')

generate
  .command('techies <n>')
  .description('Generate techies')
  .requiredOption('--semester <uuid>', 'Semester UUID')
  .requiredOption('--location <name>', 'Location')
  .action(async (n, opts) => {
    await generateTechies({
      semester: opts.semester,
      location: opts.location,
      n,
      buildTRMAPI,
      log
    })
  })

generate
  .command('token <location>')
  .description('Generate a JWT')
  .action(location => {
    console.info(jwt.user({ location }))
  })

program.parse(process.argv)
