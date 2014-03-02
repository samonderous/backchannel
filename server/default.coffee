
module.exports = 

  hostname: 'localhost'
  port: 3001

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

