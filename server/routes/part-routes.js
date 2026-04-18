const Router = require('express')
const router = new Router()

const partController = require("../controllers/part-controller")
const checkRoleMiddleware = require('../middleware/check-role-middleware')

router.post('/new', checkRoleMiddleware("manager"), partController.addNew)
router.delete('/remove', checkRoleMiddleware("manager"), partController.remove)
router.get('/:id', checkRoleMiddleware("manager"), partController.findOne)
router.get('/', checkRoleMiddleware("manager"), partController.findAll)

module.exports = router