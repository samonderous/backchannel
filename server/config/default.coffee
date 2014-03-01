
module.exports = 

  hostname: 'hashchatapp.com'
  port: 8080

  db:
    name: 'database'
    user: 'username'
    pass: 'password'

    options:
      dialect: 'sqlite'
      storage: 'data/db.sqlite'

  bcrypt:
    salt:
      length: 10

